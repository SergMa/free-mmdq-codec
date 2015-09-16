/******************************************************************************/
/* MMDQ-CODEC                                                                 */
/* mmdq_codec.c                                                               */
/* (c) Sergei Mashkin, 2015                                                   */
/******************************************************************************/

#include  "mmdq_codec.h"

#define MYLOGDEVICE 0 //0=MYLOGDEVICE_NOLOGS
#include <mylog.h>

#include  <math.h>
#include  <stdio.h>
#include  <wave/g711super.h>

/*****************************************************************************/
/* DEFINITIONS                                                               */
/*****************************************************************************/


/******************************************************************************/
/* CONSTANTS                                                                  */
/******************************************************************************/


/******************************************************************************/
/* PRIVATE FUNCTIONS                                                          */
/******************************************************************************/

//------------------------------------------------------------------------------
//integer power of integer value
int power_int( int x, int pow )
{
    int i;
    int res;
    
    if(pow<0) {
        return 0; //error
    }
    else if(pow==0) {
        return 1;
    }
    else {
        res = 1;
        for(i=0; i<pow; i++) {
            res *= x;
        }
        return res;
    }
}

//------------------------------------------------------------------------------
//Calculate  round(a/b) for integer a,b
int32_t div_round( int32_t a, int32_t b )
{
    int32_t res;
    
    res = (a<<1)/b;
    if (res & 1)
        res = (res>>1) + 1;
    else
        res = res>>1;
    return res;
}

#define PWR0  (1.000)
#define PWR1  (1.100)
#define PWR2  (1.200)
#define PWR3  (1.200)

//------------------------------------------------------------------------------
//INPUTS:  x=[-1.0..+1.0]
//OUTPUTS: y=[-1.0..+1.0]
double compand( double x, int law )
{
    switch(law)
    {
    case 0:
        if (x>=0)
            return  pow(  x, PWR0 );
        else
            return -pow( -x, PWR0 );

    case 1:
        if (x>=0)
            return  pow(  x, 1/PWR1 );
        else
            return -pow( -x, 1/PWR1 );

    case 2:
        if (x>=0 && x<=0.5)
            return (     0.5 * pow( 2*(  x) , 1/PWR2 ));
        else if (x>0.5)
            return ( 1 - 0.5 * pow( 2*(1-x) , 1/PWR2 ));
        else if (x>=-0.5)
            return (   - 0.5 * pow( 2*( -x) , 1/PWR2 ));
        else
            return (-1 + 0.5 * pow( 2*(1+x) , 1/PWR2 ));

    case 3:
        if (x>=0)
            return  (1 - pow( 1-x , 1/PWR3 ) );
        else
            return -(1 - pow( 1+x , 1/PWR3 ) );

    default:
        MYLOG_ERROR("Unexpected value: law=%d", law);
        return 0;
    }
}

//------------------------------------------------------------------------------
//INPUTS:  x=[-1.0..+1.0]
//OUTPUTS: y=[-1.0..+1.0]
double expand( double x, int law )
{
    switch(law)
    {
    case 0:
        if (x>=0)
            return  pow(  x, 1/PWR0 );
        else
            return -pow( -x, 1/PWR0 );

    case 1:
        if (x>=0)
            return  pow(  x, PWR1 );
        else
            return -pow( -x, PWR1 );

    case 2:
        if (x>=0 && x<=0.5)
            return (     0.5 * pow( 2*(  x) , PWR2 ));
        else if (x>0.5)
            return ( 1 - 0.5 * pow( 2*(1-x) , PWR2 ));
        else if (x>=-0.5)
            return (   - 0.5 * pow( 2*( -x) , PWR2 ));
        else
            return (-1 + 0.5 * pow( 2*(1+x) , PWR2 ));

    case 3:
        if (x>=0)
            return  (1 - pow( 1-x , PWR3 ) );
        else
            return -(1 - pow( 1+x , PWR3 ) );

    default:
        MYLOG_ERROR("Unexpected value: law=%d", law);
        return 0;
    }
}

/******************************************************************************/
/* FUNCTIONS                                                                  */
/******************************************************************************/

//------------------------------------------------------------------------------
int mmdq_codec_init ( struct mmdq_codec_s * codec,
                      int samples_per_frame,
                      int bits_per_sample,
                      int smooth,
                      int decoder_only )
{
    uint32_t i;
    uint8_t  dv;
    uint8_t  s;
    int32_t  a;
    double   sss;
    int32_t  ddd;
    int      databits;

    // Check input arguments
    if (codec==NULL) {
        MYLOG_ERROR("Invalid codec=NULL");
        return -1;
    }
    if (samples_per_frame<SAMPLES_PER_FRAME_MIN ||
        samples_per_frame>SAMPLES_PER_FRAME_MAX) {
        MYLOG_ERROR("Invalid samples_per_frame=%d",samples_per_frame);
        return -1;
    }
    if (bits_per_sample<BITS_PER_SAMPLE_MIN ||
        bits_per_sample>BITS_PER_SAMPLE_MAX) {
        MYLOG_ERROR("Invalid bits_per_sample=%d",bits_per_sample);
        return -1;
    }
    if (smooth<1 || smooth>SMOOTH_MAX) {
        MYLOG_ERROR("Invalid smooth=%d. Must be [0..%d]", bits_per_sample, SMOOTH_MAX-1 );
        return -1;
    }

    // Set enc fields
    codec->samples_per_frame = samples_per_frame;
    codec->bits_per_sample   = bits_per_sample;
    codec->smooth            = smooth;
    codec->decoder_only      = decoder_only;
    codec->factor            = 1 << codec->bits_per_sample; //power_int( 2 , codec->bits_per_sample );
    codec->h                 = FIXP / codec->samples_per_frame;
    codec->unpackmask        = (1<<codec->bits_per_sample)-1; //bits_per_samples ones: 000011..111

    databits = 8+8+1+ (codec->samples_per_frame-1) * codec->bits_per_sample;
    codec->databytes = databits / 8;
    if( databits % 8 )
        codec->databytes ++;

    codec->databytesnopack = 1 + 1 + 1 + (codec->samples_per_frame-1);

    // Clear tables
    codec->divtable = NULL;

    for(s=0; s<SMOOTH_MAX; s++)
        codec->enctable[s] = NULL;

    for(s=0; s<SMOOTH_MAX; s++)
        codec->dectable[s] = NULL;

    // fill table for 1/ampdv, where
    // ampdv=[0...2*MAXX]
    // values=[0..MAXX]
    codec->divtable = calloc( 2*MAXX+1, sizeof(int32_t) );
    if(codec->divtable==NULL) {
        MYLOG_ERROR("Could not allocate memory for codec->encdivtable");
        goto exit_fail;
    }
    codec->divtable[0] = 0;
    for(i=1; i<2*MAXX+1; i++) {
        //this will decrease error of integer division see encoder(), decoder():
        if(i<2*MAXX/256)
            codec->divtable[i] = trunc( (double)FIXP / i );
        else
            codec->divtable[i] = trunc( (double)FIXP / (i/256.0) );
    }

    // fill encode tables
    if(!decoder_only) {
        // inputs=dvoice/ampdv=[-FIXP..+FIXP]
        // values=[0..(codec->factor-1)]
        for(s=0; s<SMOOTH_MAX; s++) {
            //allocate
            codec->enctable[s] = calloc( 2*FIXP+1, sizeof(int8_t) );
            if(codec->enctable[s] == NULL) {
                MYLOG_ERROR("Could not allocate memory for codec->enctable[%d]", s);
                goto exit_fail;
            }
            //fill
            for(a=-FIXP; a<=FIXP; a++) {
                sss = compand( (double)a/FIXP, s ); //sss=[-FIXP..+FIXP]
                ddd = trunc( sss*(codec->factor/2) + codec->factor/2 );
                if (ddd > codec->factor-1)
                    ddd = codec->factor-1;
                codec->enctable[s][a+FIXP] = ddd;
            }
        }
    }
    
    // fill decode tables
    // inputs=[0..(dec.factor-1)]
    // returns=[-FIXP..+FIXP]
    for(s=0; s<SMOOTH_MAX; s++) {
        //allocate
        codec->dectable[s] = calloc( codec->factor, sizeof(int32_t) );
        if(codec->dectable[s] == NULL) {
            MYLOG_ERROR("Could not allocate memory for codec->dectable[%d]", s);
            goto exit_fail;
        }
        //fill
        for(dv=0; dv < codec->factor; dv++) {
            sss = expand( 2.0*((dv+0.5)/codec->factor - 0.5) , s );
            codec->dectable[s][dv] = round( sss * FIXP );
        }
    }
    
    MYLOG_DEBUG("MMDQ-encoder has been successfully initialized!");
    return 0;

exit_fail:
    if (codec->divtable) {
        free(codec->divtable);
        codec->divtable = NULL;
    }
    for(s=0; s<SMOOTH_MAX; s++) {
        if (codec->enctable[s]) {
            free(codec->enctable[s]);
            codec->enctable[s] = NULL;
        }
    }
    for(s=0; s<SMOOTH_MAX; s++) {
        if (codec->dectable[s]) {
            free(codec->dectable[s]);
            codec->dectable[s] = NULL;
        }
    }
    return -1;
}

//------------------------------------------------------------------------------
int  mmdq_framebytes ( struct mmdq_codec_s * codec )
{
    //Check input arguments
    if(codec==NULL) {
        MYLOG_ERROR("Invalid argument: codec=NULL");
        return 0;
    }

    return codec->databytes;
}

//------------------------------------------------------------------------------
int  mmdq_encode ( struct mmdq_codec_s * codec,
                   int16_t * voice, int samples,
                   uint8_t * data, int datasize, int * bytes )
{
    int16_t   minv;
    int16_t   maxv;
    int32_t   diffv;
    int       i;
    int32_t   minrv;
    int32_t   maxrv;
#ifdef MINMAX_OPTIMIZATION
    int       imin;
    int       imax;
#endif
    int32_t   dv [SAMPLES_PER_FRAME_MAX-1];
    int32_t   mindv;
    int32_t   maxdv;

    int32_t   a;
    int32_t   b;
    int32_t   ampdv;
    int       smin;
    int32_t   errmin;
    int32_t   div;
    int       s;
    int16_t   edata [SMOOTH_MAX] [DATA_SIZE_MAX];
    int32_t   sss;
    int       pos;
    uint32_t  bitshift;
    int       bitcntr;

    int32_t   n_dvoice;
    int32_t   n_voice;
    int32_t   r_voice [SAMPLES_PER_FRAME_MAX];
    int32_t   r_dvoice;
    int32_t   ce_dvoice;

    int32_t   maxerror;
    int32_t   dr;
    int32_t   srnv;
    int32_t   snv;
    int32_t   err;

    /* commented for speed
    //Check input arguments
    if(codec==NULL) {
        MYLOG_ERROR("Invalid argument: codec=NULL");
        return -1;
    }
    if(codec->decoder_only) {
        MYLOG_ERROR("Codec has been initialized without encoder part");
        return -1;
    }
    if(voice==NULL) {
        MYLOG_ERROR("Invalid argument: voice=NULL");
        return -1;
    }
    if(samples!=codec->samples_per_frame) {
        MYLOG_ERROR("Invalid argument: samples=%d (codec->samples_per_frame=%d)",
                    samples, codec->samples_per_frame);
        return -1;
    }
    if(data==NULL) {
        MYLOG_ERROR("Invalid argument: data=NULL");
        return -1;
    }
    if(datasize<=0) {
        MYLOG_ERROR("Invalid argument: datasize=%d", datasize);
        return -1;
    }
    if(bytes==NULL) {
        MYLOG_ERROR("Invalid argument: bytes=NULL");
        return -1;
    }
    */

    //==========================================================================

    //Calculate minv,maxv,diffv
    minv = maxv = voice[0];
    #ifdef MINMAX_OPTIMIZATION
    imin = imax = 0;
    #endif
    for(i=1; i<codec->samples_per_frame; i++) {
        if (voice[i]<minv) {
            minv = voice[i];
            #ifdef MINMAX_OPTIMIZATION
            imin = i;
            #endif
        }
        else if (voice[i]>maxv) {
            maxv = voice[i];
            #ifdef MINMAX_OPTIMIZATION
            imax = i;
            #endif
        }
    }
    diffv = maxv - minv;
    
    //get differencies of voice samples, mindv,maxdv,diffdv
    dv[0] = voice[1] - voice[0];
    mindv = maxdv = dv[0];
    for(i=1; i<codec->samples_per_frame-1; i++) {
        dv[i] = voice[i+1] - voice[i];
        if (dv[i] < mindv)
            mindv = dv[i];
        else if (dv[i] > maxdv)
            maxdv = dv[i];
    }
    //diffdv = maxdv - mindv;
    
    //calculate ampdv
    a = abs(mindv);
    b = abs(maxdv);
    if (a>=b)
        ampdv = a;
    else
        ampdv = b;
    
    //==========================================================================
    //quantize dv[i]
        
    // ampdv=[0..2*maxx]
    // div=[0..FIXP]
    smin   = 0;   //we will find minimal error too
    errmin = 0;   //
    div = codec->divtable[ ampdv ];
    
    for(s=0; s<codec->smooth; s++) {
        edata[s][0] = minv;  //do not swap minx,maxx here for mmdq_decode_nounpack()
        edata[s][1] = maxv;
        edata[s][2] = s;     //store smooth here for mmdq_decode_nounpack()

        //encode with selected smooth
        n_voice = 0;
        r_voice[0] = 0;

        if(ampdv < 2*MAXX/256) {
            //K = 1
            for(i=0; i<codec->samples_per_frame-1; i++) {
                //true normalized dvoice
                // dv[i]=[-2*MAXX..+2*MAXX]
                // div=[0..FIXP]
                // n_dvoice=[-FIXP..+FIXP]
                n_dvoice = dv[i] * (int)div;

                //true restored normalized voice
                n_voice = n_voice + n_dvoice;

                //get diff between true and companded/expanded normalized voices
                r_dvoice = n_voice - r_voice[i];
                //if( abs(r_dvoice) > error )
                //    error = abs(r_dvoice);
                
                //compand/expand voice
                // dv[i]=[-2*MAXX..+2*MAXX]
                // div=[0..FIXP]
                sss = r_dvoice;
                if(sss>FIXP)
                    sss = FIXP;
                else if(sss<-FIXP)
                    sss = -FIXP;
                edata[s][3+i] = codec->enctable[s][sss + FIXP];
                
                //dv[i]  = [0..FACTOR-1]
                //dec.table = [-FIXP..+FIXP]
                ce_dvoice = codec->dectable[s][ edata[s][3+i] ];
                
                //restore voice
                r_voice[i+1] = r_voice[i] + ce_dvoice;
            }
        }
        else {
            //K = 256
            for(i=0; i<codec->samples_per_frame-1; i++) {
                //true normalized dvoice
                // dv[i]=[-2*MAXX..+2*MAXX]
                // div=[0..FIXP]
                // n_dvoice=[-FIXP..+FIXP]
                n_dvoice = (dv[i] * (int)div) >> 8;

                //true restored normalized voice
                n_voice = n_voice + n_dvoice;

                //get diff between true and companded/expanded normalized voices
                r_dvoice = n_voice - r_voice[i];
                //if( abs(r_dvoice) > error )
                //    error = abs(r_dvoice);
                
                //compand/expand voice
                // dv[i]=[-2*MAXX..+2*MAXX]
                // div=[0..FIXP]
                sss = r_dvoice;
                if(sss>FIXP)
                    sss = FIXP;
                else if(sss<-FIXP)
                    sss = -FIXP;
                edata[s][3+i] = codec->enctable[s][sss + FIXP];
                
                //dv[i]  = [0..FACTOR-1]
                //dec.table = [-FIXP..+FIXP]
                ce_dvoice = codec->dectable[s][ edata[s][3+i] ];
                
                //restore voice
                r_voice[i+1] = r_voice[i] + ce_dvoice;
            }
        }

        if(codec->smooth==1) {
            smin = 0;
            break;
        }
        else {
            #ifdef MINMAX_OPTIMIZATION
            //use imin,imax to estimate min(r_voice),max(r_voice)
            minrv = r_voice[imin];
            maxrv = r_voice[imax];
            #else
            //find min(r_voice), max(r_voice)
            minrv = maxrv = r_voice[0];
            for(i=1; i < codec->samples_per_frame; i++) {
                if(r_voice[i] < minrv)
                    minrv = r_voice[i];
                else if(r_voice[i] > maxrv)
                    maxrv = r_voice[i];
            }
            #endif
        
            //decode for selected smooth, returns error
            dr = maxrv - minrv;
            maxerror = 0;
            for(i=0; i < codec->samples_per_frame; i++) {
                srnv = diffv*(r_voice[i] - minrv) + dr*minv;
                snv  = dr*voice[i];
                err = abs(srnv - snv);

#if BEST_SMOOTH_VER==0
                if(err > maxerror)
                    maxerror = err;
#elif BEST_SMOOTH_VER==1
                maxerror += err;
#endif

#if defined(SKIP_BAD_SMOOTH)
                if( (s>0) && (maxerror>errmin) )
                    break; //stop error estimation!
#endif
            }
            if (s==0 || (maxerror < errmin) ) {
                errmin = maxerror;
                smin = s;
            }
        }
    }

    if(smin&1) { //smooth(bit0)==1
        edata[smin][0] = maxv;
        edata[smin][1] = minv;
    }
    edata[smin][2] >>= 1; //smooth(bit1)
    
    
    //==========================================================================
    //bit-pack data[smin] into data[]
    pos = 0;

    data[pos++] = linear2alaw( edata[smin][0] );
    data[pos++] = linear2alaw( edata[smin][1] );

    bitshift = 0;
    bitcntr  = 0;
    bitshift = (bitshift << 1) | edata[smin][2]; //smooth(bit1)
    bitcntr++;

    for (i=0; i<codec->samples_per_frame-1; i++) {
        bitshift = (bitshift << codec->bits_per_sample) | edata[smin][3+i];
        bitcntr += codec->bits_per_sample;
        if(bitcntr >= 8) {
            bitcntr -= 8;
            data[pos++] = bitshift >> bitcntr;
        }
    }
    if(bitcntr>0) {
        //fill add bits with zeros
        data[pos++] = bitshift << (8-bitcntr);
        //bitcntr -= 8;
    }

    //MYLOG_DEBUG("encoded data has been packed into %d bytes", pos);

    *bytes = pos;
    return 0;
}

//------------------------------------------------------------------------------
int  mmdq_decode ( struct mmdq_codec_s * codec,
                   uint8_t * data, int bytes,
                   int16_t * voice, int voicesize, int * samples )
{
    int      i;
    int32_t  minv;
    int32_t  maxv;
    int32_t  tmpv;
    int32_t  diffv;
    int32_t  voicemin;
    int32_t  voicemax;
    int32_t  voicediff;
    int32_t  voicediff_n;
    int      s;
    int      smooth0;
    int      smooth1;
    int32_t  div;
    uint8_t  dv[SAMPLES_PER_FRAME_MAX-1];
    int32_t  voice2[SAMPLES_PER_FRAME_MAX];
    int64_t  diffv_xh;

    int      pos;
    uint32_t bitshift;
    int      bitcntr;
    int      dvpos;

    /* Commented for speed
    //Check input arguments
    if(codec==NULL) {
        MYLOG_ERROR("Invalid argument: codec=NULL");
        return -1;
    }
    if(data==NULL) {
        MYLOG_ERROR("Invalid argument: data=NULL");
        return -1;
    }
    if(bytes<=0) {
        MYLOG_ERROR("Invalid argument: bytes=%d", bytes);
        return -1;
    }
    if(voice==NULL) {
        MYLOG_ERROR("Invalid argument: voice=NULL");
        return -1;
    }
    if(voicesize<=0) {
        MYLOG_ERROR("Invalid argument: voicesize=%d", voicesize);
        return -1;
    }
    if(samples==NULL) {
        MYLOG_ERROR("Invalid argument: samples=NULL");
        return -1;
    }
    */

    //==========================================================================
    //bit-unpack from data[] into minx, maxx, smooth1, dv[]
    pos = 0;
    minv = alaw2linear( data[pos++] );
    maxv = alaw2linear( data[pos++] );
    if (minv > maxv) {
        smooth0 = 1;
        tmpv = minv;
        minv = maxv;
        maxv = tmpv;
    }
    else {
        smooth0 = 0;
    }
    smooth1 = (data[pos]>>7) & 1;
    s = (smooth1<<1) | smooth0;
    diffv = maxv - minv;
    
    bitshift = data[pos++] & 0x7F;
    bitcntr = 7;
    dvpos = 0;
    for(;;) {
        bitshift = (bitshift << 8) | data[pos++];
        bitcntr += 8;
        
        while(bitcntr >= codec->bits_per_sample)
        {
            bitcntr -= codec->bits_per_sample;
            dv[dvpos++] = (bitshift >> bitcntr) & codec->unpackmask;

            if( dvpos >= (codec->samples_per_frame-1) )
                break;
        }
        
        if( dvpos >= (codec->samples_per_frame-1) )
            break;
    }
    
    //==========================================================================
    //Reconstruct voice in relative coordinates
    voicemin = voicemax = voice2[0] = 0;
    for(i=0; i < codec->samples_per_frame-1; i++) {
        // dvoice(i)  = [0..dec.factor-1]
        // codec->table0 = [-FIXP..+FIXP]
        voice2[i+1] = voice2[i] + codec->dectable[s][ dv[i] ];
        
        if (voice2[i+1]<voicemin)
            voicemin = voice2[i+1];
        else if (voice2[i+1]>voicemax)
            voicemax = voice2[i+1];
    }

    //==========================================================================
    // Scale/shift absolute voice by minv,maxv reference points
    voicediff = voicemax - voicemin;

    //voicemin_n  = (voicemin  * codec->h) / FIXP;
    voicediff_n = ((int64_t)voicediff * codec->h) / FIXP;
    diffv_xh    = ((int64_t)diffv * codec->h) / FIXP;

    div = codec->divtable[ voicediff_n ];  //div=[0..2*FIXP]

    if (voicediff_n < 2*MAXX/256 ) {
        //K=1
        for (i=0; i<codec->samples_per_frame; i++) {
            voice[i] = minv + (int32_t)(diffv_xh * (voice2[i] - voicemin) * div / FIXP);
        }
    }
    else {
        //K=256
        for (i=0; i<codec->samples_per_frame; i++) {
            voice[i] = minv + (int32_t)(diffv_xh * (voice2[i] - voicemin) * div / (FIXP * 256));
        }
    }

    *samples = codec->samples_per_frame;
    
    return 0;
}


