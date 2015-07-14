/******************************************************************************/
/* MMDQ-CODEC                                                                 */
/* mmdq_codec.c                                                               */
/* (c) Sergei Mashkin, 2015                                                   */
/******************************************************************************/

#include  "mmdq_codec.h"
#include  <math.h>
#include  <stdio.h>
#include  <wave/mylog.h>
#include  <wave/g711super.h>

/*****************************************************************************/
/* DEFINITIONS                                                               */
/*****************************************************************************/

int  mmdq_decode_nounpack ( struct mmdq_codec_s * dec,
                            int16_t * data, int bytes,
                            int16_t * voice, int voicesize, int * samples );


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

//------------------------------------------------------------------------------
//INPUTS:  x=[-1.0..+1.0]
//OUTPUTS: y=[-1.0..+1.0]
double compand( double x, int law )
{
    switch(law)
    {
    case 0:
        return x;

    case 1:
        if (x>=0)
            return  pow(  x, 1/1.2 );
        else
            return -pow( -x, 1/1.2 );

    case 2:
        if (x>=0)
            return  pow(  x, 1/1.4 );
        else
            return -pow( -x, 1/1.4 );

    case 3:
        if (x>=0)
            return  pow(  x, 1/1.8 );
        else
            return -pow( -x, 1/1.8 );

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
        return x;

    case 1:
        if (x>=0)
            return  pow(  x, 1.2 );
        else
            return -pow( -x, 1.2 );

    case 2:
        if (x>=0)
            return  pow(  x, 1.4 );
        else
            return -pow( -x, 1.4 );

    case 3:
        if (x>=0)
            return  pow(  x, 1.8 );
        else
            return -pow( -x, 1.8 );

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
                      int smooth_on,
                      int decoder_only )
{
    int32_t  i;
    uint8_t  s;
    int32_t  b;
    int32_t  sss;
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

    // Set enc fields
    codec->samples_per_frame = samples_per_frame;
    codec->bits_per_sample   = bits_per_sample;
    codec->smooth_on         = smooth_on;
    codec->decoder_only      = decoder_only;
    codec->factor            = 1 << codec->bits_per_sample; //power_int( 2 , codec->bits_per_sample );
    //codec->h               = div_round( MAXX, codec->samples_per_frame );
    codec->h                 = round( (double)MAXX / codec->samples_per_frame );
    codec->unpackmask        = (1<<codec->bits_per_sample)-1; //bits_per_samples ones: 000011..111

    databits = 8+8+1+ (codec->samples_per_frame-1) * codec->bits_per_sample;
    codec->databytes = databits / 8;
    if( databits % 8 )
        codec->databytes ++;

    codec->databytesnopack = 1 + 1 + 1 + (codec->samples_per_frame-1);

    // Clear tables
    codec->divtable = NULL;
    for(s=0; s<SMOOTH_N; s++)
        codec->enctable[s] = NULL;

    // fill table for 1/ampdv, where
    // ampdv=[0...2*MAXX]
    // values=[0..MAXX]
    codec->divtable = calloc( 2*MAXX+1, sizeof(int32_t) );
    if(codec->divtable==NULL) {
        MYLOG_ERROR("Could not allocate memory for codec->divtable");
        goto exit_fail;
    }
    codec->divtable[0] = 0;
    for(i=1; i<2*MAXX+1; i++) {
        codec->divtable[i] = 2*MAXX*MAXX / i;
    }

    // fill encode tables
    if(!decoder_only) {
        // inputs=dvoice/ampdv=[-MAXX..+MAXX], values=[0..(codec->factor-1)]
        for(s=0; s<SMOOTH_N; s++) {
            //allocate
            codec->enctable[s] = calloc( 2*MAXX+1, sizeof(int32_t) );
            if(codec->enctable[s] == NULL) {
                MYLOG_ERROR("Could not allocate memory for codec->enctable[%d]", s);
                goto exit_fail;
            }
            //fill
            for(i=-(int)MAXX; i<=(int)MAXX; i++) {
                b = MAXX * compand( (double)(i)/MAXX, s ) + MAXX; // b=[0..2*MAXX]
                //sss = div_round( codec->factor * b , 2*MAXX );
                sss = round( (double)(codec->factor * b) / (2*MAXX) );
                if (sss > (codec->factor-1))
                    sss = codec->factor-1;
                codec->enctable[s][i+MAXX] = sss;
                
                //printf("s=%6d, i=%6d, b=%6d, sss=%10d\n", s, i, b, sss);
            }
        }
    }
    
    // fill decode tables
    // inputs=dvoice/ampdv=[0..(dec->factor-1)], values=[-MAXX..+MAXX]
    for(s=0; s<SMOOTH_N; s++) {
        //allocate
        codec->dectable[s] = calloc( codec->factor, sizeof(int32_t) );
        if(codec->dectable[s] == NULL) {
            MYLOG_ERROR("Could not allocate memory for codec->dectable[%d]", s);
            goto exit_fail;
        }
        //fill
        for(i=0; i < codec->factor; i++) {
            sss = (2*MAXX*i) / codec->factor - MAXX;
            codec->dectable[s][i] = MAXX * expand( (double)(sss)/MAXX, s );
            //printf("s=%6d, i=%6d, sss=%10d dectable=%6d\n", s, i, sss, codec->dectable[s][i] );
        }
    }
    
    MYLOG_DEBUG("MMDQ-encoder has been successfully initialized!");
    return 0;

exit_fail:
    if (codec->divtable) {
        free(codec->divtable);
        codec->divtable = NULL;
    }
    for(s=0; s<SMOOTH_N; s++) {
        if (codec->enctable[s]) {
            free(codec->enctable[s]);
            codec->enctable[s] = NULL;
        }
    }
    for(s=0; s<SMOOTH_N; s++) {
        if (codec->dectable[s]) {
            free(codec->dectable[s]);
            codec->dectable[s] = NULL;
        }
    }
    return -1;
}

//------------------------------------------------------------------------------
int  mmdq_encode ( struct mmdq_codec_s * codec,
                   int16_t * voice, int samples,
                   uint8_t * data, int datasize, int * bytes )
{
    int16_t   minx;
    int16_t   maxx;
    //int16_t  diffx;
    int       i;
    int16_t   dv [SAMPLES_PER_FRAME_MAX-1];
    int16_t   mindv;
    int16_t   maxdv;
    int16_t   diffdv;
    int16_t   a;
    int16_t   b;
    int16_t   ampdv;
    int       smin;
    int16_t   errmin;
    int       smooth1;
    uint32_t  div;
    int       s;
    int16_t   edata [SMOOTH_N] [DATA_SIZE_MAX];
    int16_t   sss;
    int16_t   voice2 [SMOOTH_N] [SAMPLES_PER_FRAME_MAX];
    int       samples2;
    int16_t   error [SMOOTH_N];
    int16_t   verr;

    int       err;
    int       pos;
    uint32_t  bitshift;
    int       bitcntr;

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

    //==========================================================================

    //Calculate minx,maxx,diffx
    minx = maxx = voice[0];
    for(i=1; i<codec->samples_per_frame; i++) {
        if (voice[i]<minx)
            minx = voice[i];
        else if (voice[i]>maxx)
            maxx = voice[i];
    }
    //diffx = maxx - minx;

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
    diffdv = maxdv - mindv;

    //calculate ampdv
    a = abs(mindv);
    b = abs(maxdv);
    if (a>=b)
        ampdv = a;
    else
        ampdv = b;

    //printf("minx=%6d, maxx=%6d, mindv=%6d, diffdv=%6d, ampdv=%6d\n",
    //       minx, maxx, mindv, diffdv, ampdv);

    //==========================================================================
    //quantize dv[i]
    if (diffdv==0)
    {
        //===== dv[i]==const =======================
        smin    = 0;
        errmin  = 0;
        smooth1 = 0;
        edata[smin][0] = minx;
        edata[smin][1] = maxx;
        edata[smin][2] = smooth1;
        if (maxdv==0) {
            // We suppose, that codec->factor is even. So there is no enc.factor for dv=0
            for (i=0; i<codec->samples_per_frame-1; i+=2)
                edata[smin][3+i] = codec->factor/2;
            for (i=1; i<codec->samples_per_frame-1; i+=2)
                edata[smin][3+i] = codec->factor/2 - 1;
        }
        else if (maxdv>0) {
            for (i=0; i<codec->samples_per_frame-1; i++)
                edata[smin][3+i] = codec->factor-1;
        }
        else { //maxdv<0
            for (i=0; i<codec->samples_per_frame-1; i++)
                edata[smin][3+i] = 0;
        }
        //go-go-go
    }
    else
    {
        //===== really quantize dv[i] ==============
        
        div = codec->divtable[ ampdv ]; //table for 2*MAXX*MAXX/ampdv, where ampdv=[0...2*MAXX], div=[0..MAXX]

        //printf("ampdv=%6d, div=%6lu\n", ampdv, div);


        for(s=0; s<4; s++) {
            //encode with selected smooth
            if(s&1) {
                edata[s][0] = maxx; //smooth(bit0)==1
                edata[s][1] = minx;
            }
            else {
                edata[s][0] = minx; //smooth(bit0)==0
                edata[s][1] = maxx;
            }
            edata[s][2] = (s>>1)&1; //smooth(bit1)
            
            for(i=0; i<codec->samples_per_frame-1; i++) {
                // dv[i]=[-2*MAXX..+2*MAXX]
                // div=[0..MAXX]
                sss = dv[i] * div / (2*MAXX);  // sss=[-maxx..+maxx]
                edata[s][3+i] = codec->enctable[s][sss + MAXX];

                //printf("s=%6d, i=%6d, dv[i]=%6d, div=%10lu, edata[s][3+i]=%6d\n",
                //        s, i, dv[i], div, edata[s][3+i] );
            }
            
            //decode for selected smooth
            err = mmdq_decode_nounpack( codec,
                                        edata[s], codec->databytesnopack,
                                        voice2[s], sizeof(voice2[s]), &samples2 );
            if(err) {
                MYLOG_ERROR("mmdq_decoder() failed for s=%d",s);
                return -1;
            }
            
            //calculate error[s]=max(abs(voice[i]-voice[s][i]))
            error[s] = abs(voice[0] - voice2[s][0]);
            for (i=1; i<codec->samples_per_frame; i++) {
                verr = abs(voice[i] - voice2[s][i]);
                if (verr > error[s])
                    error[s] = verr;
            }
        }
        
        //find s0=s with minimal error
        smin   = 0;
        errmin = error[0];
        for (s=1; s<SMOOTH_N; s++) {
            if (error[s] < errmin) {
                errmin = error[s];
                smin = s;
            }
        }
        //go-go-go
    }
    
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
        bitcntr += 3;
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
//mmdq_decode version without bit-unpacking (for use in mmdq_encoder)
int  mmdq_decode_nounpack ( struct mmdq_codec_s * dec,
                             int16_t * edata, int bytes,
                             int16_t * voice, int voicesize, int * samples )
{
    int16_t    minx;
    int16_t    maxx;
    int16_t    tmpx;
    int        smooth0;
    int        smooth1;
    int        smooth;
    int32_t    minv;
    int32_t    maxv;
    int32_t    diffv;
    int        i;
    int32_t    minv_n;
    int32_t    diffv_n;
    uint32_t   div;
    int32_t    voice_n;
    int32_t    voice2[SAMPLES_PER_FRAME_MAX];

    minx = edata[0];
    maxx = edata[1];
    if (minx>maxx) {
        tmpx = minx;
        minx = maxx;
        maxx = tmpx;
        smooth0 = 0;
    }
    else {
        smooth0 = 0;
    }
    smooth1 = edata[2];
    smooth = (smooth1<<1) | smooth0;

    //==========================================================================
    //Reconstrunct voice in relative coordinats
    voice2[0] = 0;
    for(i=0; i < dec->samples_per_frame-1; i++) {
        // dv[i] = [0..dec.factor-1]
        // dec->table[] = [-maxx..+maxx]
        voice2[i+1] = voice2[i] + dec->dectable[smooth][ edata[3+i] ];
        //printf("i=%6d, dv[i]=%6d, voice2[i+1]=%6ld\n", i, codec->dectable[smooth][ edata[3+i] ], voice2[i+1]);
    }

    //==========================================================================
    // Scale/shift absolute voice by minv,maxv reference points
    minv = maxv = voice2[0];
    for (i=0; i<dec->samples_per_frame; i++) {
        if (voice2[i]<minv)
            minv = voice2[i];
        else if (voice2[i]>maxv)
            maxv = voice2[i];
    }
    diffv = maxv - minv;

    minv_n  = (minv  * dec->h) / MAXX;
    diffv_n = (diffv * dec->h) / MAXX;

    div = dec->divtable[diffv_n];  //div=[0..2*MAXX]
    
    for (i=0; i<dec->samples_per_frame; i++) {
        voice_n = (voice2[i] * dec->h) / MAXX;
        //diffv=[0..2*MAXX]
        //div  =[0..2*MAXX]
        voice[i] = minv + diffv * div * (voice_n - minv_n) / MAXXMAXX4;
    }
    
    return 0;
}

//------------------------------------------------------------------------------
int  mmdq_decode ( struct mmdq_codec_s * codec,
                   uint8_t * data, int bytes,
                   int16_t * voice, int voicesize, int * samples )
{
    int      i;
    int16_t  minx;
    int16_t  maxx;
    int16_t  tmpx;
    //int16_t  diffx;
    int32_t  minv;
    int32_t  maxv;
    int32_t  diffv;
    int32_t  minv_n;
    int32_t  diffv_n;
    int      smooth;
    int      smooth0;
    int      smooth1;
    uint32_t div;
    int32_t  voice_n;
    int16_t  dv[SAMPLES_PER_FRAME_MAX-1];
    int32_t  voice2[SAMPLES_PER_FRAME_MAX];

    int      pos;
    uint32_t bitshift;
    int      bitcntr;
    int      dvpos;


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

    //==========================================================================
    //bit-unpack from data[] into minx, maxx, smooth1, dv[]
    pos = 0;
    minx = alaw2linear( data[pos++] );
    maxx = alaw2linear( data[pos++] );
    if (minx > maxx) {
        smooth0 = 1;
        tmpx = minx;
        minx = maxx;
        maxx = tmpx;
    }
    else {
        smooth0 = 0;
    }
    smooth1 = (data[pos]>>7) & 1;
    smooth = (smooth1<<1) | smooth0;
    
    bitshift = data[pos++] & 0x7F;
    bitcntr = 7;
    dvpos = 0;
    for(;;) {
        bitshift = (bitshift << 8) | data[pos++];
        bitcntr += 8;
        
        while(bitcntr >= codec->bits_per_sample) {
            bitcntr -= codec->bits_per_sample;
            dv[dvpos++] = (bitshift >> bitcntr) & codec->unpackmask;

            if( dvpos >= (codec->samples_per_frame-1) )
                break;
        }
        if( dvpos >= (codec->samples_per_frame-1) )
            break;
    }

    // printf("data[%2d]: ", bytes);
    // for(i=0; i<bytes; i++) {
    //     printf("%02X ", data[i]);
    // }
    // printf(", minx=%6d, maxx=%6d, smooth0=%d, smooth1=%d , dv[]: ",
    //     minx, maxx, smooth0, smooth1);
    // for(i=0; i<codec->samples_per_frame-1; i++) {
    //     printf("%02X ", dv[i]);
    // }
    // printf("\n");

    //==========================================================================
    //Reconstrunct voice in relative coordinats
    voice2[0] = 0;
    for(i=0; i<codec->samples_per_frame-1; i++) {
        // dv[i] = [0..codec->factor-1]
        // codec->table[] = [-maxx..+maxx]
        voice2[i+1] = voice2[i] + codec->dectable[smooth][ dv[i] ];
        //printf("i=%6d, dv[i]=%6d, dvoice[i]=%6d, voice2[i+1]=%6ld\n", i, dv[i], codec->dectable[smooth][ dv[i] ], voice2[i+1]);
    }

    //==========================================================================
    // Scale/shift absolute voice by minv,maxv reference points
    minv = maxv = voice2[0];
    for (i=0; i<codec->samples_per_frame; i++) {
        if (voice2[i]<minv)
            minv = voice2[i];
        else if (voice2[i]>maxv)
            maxv = voice2[i];
    }
    diffv = maxv - minv;

    diffv_n = ((int64_t)diffv * (int64_t)codec->h) / MAXX;
    minv_n  = ((int64_t)minv  * (int64_t)codec->h) / MAXX;

    div = codec->divtable[diffv_n];  //div=[0..2*maxx]
    
    for (i=0; i<codec->samples_per_frame; i++) {
        voice_n = ((int64_t)voice2[i] * (int64_t)codec->h) / MAXX;
        voice[i] = minv + (int64_t)diffv * (int64_t)div * (voice_n - minv_n) / MAXXMAXX4;

        //printf("i=%3d, voice2[i]=%6ld, codec->h=%6ld, voice_n=%6ld, minv_n=%6d, diffv=%6d, voice[i]=%6d\n",
        //        i, voice2[i], codec->h, voice_n, minv_n, diffv, voice[i] );
    }

    *samples = codec->samples_per_frame;
    
    return 0;
}


