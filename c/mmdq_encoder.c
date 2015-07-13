/******************************************************************************/
/* MMDQ-ENCODER                                                               */
/* mmdq_encoder.c                                                             */
/* (c) Sergei Mashkin, 2015                                                   */
/******************************************************************************/

#include  "mmdq_encoder.h"
#include  <math.h>
#include  <stdio.h>

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
//Calculate  round(a/b) for integer a,b
int32_t div_round( int32_t a, int32_t b )
{
    int32_t res;
    
    res = (a<<1)/b;
    if (res & 1)
        res = res>>1 + 1;
    else
        res = res>>1;
    return res;
}

//------------------------------------------------------------------------------
//INPUTS:  x=[-1.0..+1.0]
//OUTPUTS: y=[-1.0..+1.0]
int32_t compand( double x, int law )
{
    switch(law)
    {
    case 0:
        return x;

    case 1:
        if x>=0
            return  pow(  x, 1/1.2 );
        else
            return -pow( -x, 1/1.2 );
        return;

    case 2:
        if x>=0
            return  pow(  x, 1/1.4 );
        else
            return -pow( -x, 1/1.4 );
        return;

    case 3:
        if x>=0
            return  pow(  x, 1/1.8 );
        else
            return -pow( -x, 1/1.8 );
        return;

    default:
        MYLOG_ERROR("Unexpected value: law=%d", law);
        return 0;
    }
}

/******************************************************************************/
/* FUNCTIONS                                                                  */
/******************************************************************************/

//------------------------------------------------------------------------------
int mmdq_encoder_init ( struct mmdq_encoder_s * enc,
                        int samples_per_frame,
                        int bits_per_sample,
                        int smooth_on )
{
    int i;
    int s;
    int32_t b;
    int32_t sss;
    int err;

    // Check input arguments
    if (enc==NULL) {
        MYLOG_ERROR("Invalid enc=NULL");
        return -1;
    }
    if (samples_per_frame<1 || samples_per_frame>1000) {
        MYLOG_ERROR("Invalid samples_per_frame=%d",samples_per_frame);
        return -1;
    }
    if (bits_per_sample<1 || bits_per_sample>1000) {
        MYLOG_ERROR("Invalid bits_per_sample=%d",bits_per_sample);
        return -1;
    }
    if (smooth_on!=0 && smooth_on!=1) {
        MYLOG_ERROR("Invalid smooth_on=%d",smooth_on);
        return -1;
    }

    // Set enc fields
    enc->samples_per_frame = samples_per_frame;
    enc->bits_per_sample = bits_per_sample;
    enc->smooth_on = smooth_on;
    enc->factor = pow(2,enc->bits_per_sample);

    // Clear tables
    if (enc->divtable) {
        free(enc->divtable);
        enc->divtable = NULL;
    }
    for(s=0; s<4; s++) {
        if (enc->enctable[s]) {
            free(enc->enctable[s]);
            enc->enctable[s] = NULL;
        }
    }

    // fill table for 1/ampdv, where
    // ampdv=[0...2*MAXX]
    // values=[0..2*MAXX]
    enc->divtable = calloc( 2*MAXX+1, sizeof(int32_t) );
    if(enc->divtable==NULL) {
        MYLOG_ERROR("Could not allocate memory for enc->divtable (%d bytes)", (2*MAXX+1)*sizeof(int32_t) );
        goto exit_fail;
    }
    enc->divtable[0] = 0;
    for(i=1; i<2*MAXX+1; i++) {
        enc->divtable[i] = 4*MAXX*MAXX / i;
    }

    // fill encode tables
    // inputs=dvoice/ampdv=[-MAXX..+MAXX], values=[0..(enc->factor-1)]
    for(s=0; s<4; s++) {
        enc->enctable[s] = calloc( 2*MAXX+1, sizeof(int32_t) );
        if(enc->enctable[s] = NULL) {
            MYLOG_ERROR("Could not allocate memory for enc->enctable[%d] (%d bytes)", s, (2*MAXX+1)*sizeof(int32_t) );
            goto exit_fail;
        }
        for(i=-MAXX; i<=MAXX; i++) {
            b = MAXX * compand( double(i)/MAXX, s ) + MAXX; // b=[0..2*MAXX]
            //sss = round( double(enc->factor) * b / (2*MAXX) );
            sss = div_round( enc->factor * b , 2*MAXX );
            enc->enctable[s][i+MAXX] = sss;
        }
    }

    MYLOG_DEBUG("MMDQ-encoder has been successfully initialized!");
    return 0;

exit_fail:
    if (enc->divtable) {
        free(enc->divtable);
        enc->divtable = NULL;
    }
    for(i=0; i<4; i++) {
        if (enc->enctable[i]) {
            free(enc->enctable[i]);
            enc->enctable[i] = NULL;
        }
    }
    return -1;
}

//------------------------------------------------------------------------------
int  mmdq_encoder ( struct mmdq_encoder_s * enc,
                    struct mmdq_decoder_s * dec,
                    int16_t * voice, int samples,
                    uint8_t ** data, int datasize, int * bytes )
{
    int     i;
    int     s;
    int16_t minx;
    int16_t maxx;
    int16_t diffx;
    int16_t dv[SAMPLES_PER_FRAME_MAX-1];
    uint8_t edata[SMOOTH_N][MMDQ_DATA_SIZE_MAX];
    int16_t error[SMOOTH_N];
    int     smooth1;
    int     smooth0;
    int     smin;
    int16_t errmin;

    //Check input arguments
    if(enc==NULL) {
        MYLOG_ERROR("Invalid argument: enc=NULL");
        return -1;
    }
    if(dec==NULL) {
        MYLOG_ERROR("Invalid argument: dec=NULL");
        return -1;
    }
    if(voice==NULL) {
        MYLOG_ERROR("Invalid argument: voice=NULL");
        return -1;
    }
    if(samples!=enc->samples_per_frame) {
        MYLOG_ERROR("Invalid argument: samples=%d (enc->samples_per_frame=%d)", samples, enc->samples_per_frame);
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

    //Calculate minx,maxx,diffx
    minx = maxx = voice[0];
    for(i=1; i<enc->samples_per_frame; i++) {
        if voice[i]<minx
            minx = voice[i];
        else if voice[i]>maxx
            maxx = voice[i];
    }
    diffx = maxx - minx;

    //get differencies of voice samples, mindv,maxdv,diffdv
    dv[0] = voice[1] - voice[0];
    mindv = maxdv = dv[0];
    for(i=1; i<enc->samples_per_frame-1; i++) {
        dv[i] = voice[i+1] - voice[i];
        if dv[i] < mindv
            mindv = dv[i];
        else if dv[i] > maxdv
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

    //quantize dv[i]
    if (diffdv==0) {
        //dv[i]==const
        smin = 0;
        errmin = 0;
        smooth0 = smin&1;
        smooth1 = (smin>>1)&1;
        edata[smin][0] = minx;
        edata[smin][1] = maxx;
        edata[smin][2] = smooth1;
        if (maxdv==0) {
            // We suppose, that enc->factor is even. So there is no enc.factor for dv=0
            for (i=0; i<enc->samples_per_frame-1; i+=2)
                data[smin][3+i] = enc.factor/2;
            for (i=1; i<enc->samples_per_frame-1; i+=2)
                data[smin][3+i] = enc.factor/2 - 1;
        }
        else if (maxdv>0) {
            for (i=0; i<enc->samples_per_frame-1; i++)
                data[smin][3+i] = enc.factor-1;
        }
        else { //maxdv<0
            for (i=0; i<enc->samples_per_frame-1; i++)
                data[smin][3+i] = 0;
        }
        //go-go-go
    }
    else {
        //really quantize dv[i]
        div = enc->divtable[ ampdv ]; //table for 2*MAXX/ampdv, where ampdv=[0...2*MAXX], table=[0..2*MAXX]

        for(s=0; s<4; s++) {
            //encode with selected smooth
            if(s&1) {
                data[s][0] = maxx; //smooth(bit0)==1
                data[s][1] = minx;
            }
            else {
                data[s][0] = minx; //smooth(bit0)==0
                data[s][1] = maxx;
            }
            data[s][2] = (s>>1)&1; //smooth(bit1)
            
            for(i=0; i<enc->samples_per_frame-1; i++) {
                // dvoice(i)=[-2*MAXX..+2*MAXX]
                // div=[0..MAXX]
                sss = dv[i] * div / (2*MAXX);  // sss=[-maxx..+maxx]
                data[s][3+i] = enc.table[s][sss + enc.maxx];
            }
            
            //decode for selected smooth
            bytes = ;
            err = mmdq_decoder_nopack( dec, data, bytes, voice2[s], sizeof(voice2[s]), &samples );
            if(err) {
                MYLOG_ERROR("mmdq_decoder() failed for s=%d",s);
                return -1;
            }
            
            //calculate error[s]=max(abs(voice[i]-voice[s][i]))
            error[s] = abs(voice[0] - voice[s][0]);
            for(i=1; i<enc->samples_per_frame; i++) {
                verr = abs(voice[0] - voice[s][0]);
                if (verr>error[s])
                    error[s] = verr;
            }
        }
        
        //find s0=s with minimal error
        smin = 0;
        errmin = error[0];
        for(s=1; s<4; s++) {
            if (error[s] < errmin) {
                errmin = error[s];
                smin = s;
            }
        }
        //go-go-go
    }
    
    //bit-pack data[smin] into data[]
    data[0] = linear2alaw( data[smin][0] );
    data[1] = linear2alaw( data[smin][1] );

    pos = 2;
    bitshift = (bitshift << 1) | data[smin][2]; //smooth(bit1)
    bitcntr++;

    for (i=0; i<enc->samples_per_frame-1; i++) {
        bitshift = (bitshift << enc->bits_per_sample) | data[smin][3+i];
        if(bitcntr >= 8) {
            bitcntr -= 8;
            data[pos++] = bitshift >> bitcntr;
        }
    }
    if(bitcntr>0) {
        data[pos++] = bitshift << (8-bitcntr);
    }
    MYLOG_DEBUG("encoded data has been packed into %d bytes", pos);
    bytes = pos;
    return 0;
}
