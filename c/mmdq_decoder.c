/******************************************************************************/
/* MMDQ-DECODER                                                               */
/* mmdq_decoder.c                                                             */
/* (c) Sergei Mashkin, 2015                                                   */
/******************************************************************************/

#include  "mmdq_decoder.h"

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
//INPUTS:  x=[-1.0..+1.0]
//OUTPUTS: y=[-1.0..+1.0]
int32_t expand( double x, int law )
{
    switch(law)
    {
    case 0:
        return x;

    case 1:
        if x>=0
            return  pow(  x, 1.2 );
        else
            return -pow( -x, 1.2 );
        return;

    case 2:
        if x>=0
            return  pow(  x, 1.4 );
        else
            return -pow( -x, 1.4 );
        return;

    case 3:
        if x>=0
            return  pow(  x, 1.8 );
        else
            return -pow( -x, 1.8 );
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
int  mmdq_decoder_init ( struct mmdq_decoder_s * dec,
                         int samples_per_frame,
                         int bits_per_sample,
                         int smooth_on )
{
    int i;
    int s;
    int32_t a;
    int32_t b;
    int32_t sss;
    int err;

    // Check input arguments
    if (dec==NULL) {
        MYLOG_ERROR("Invalid dec=NULL");
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

    // Set dec fields
    dec->samples_per_frame = samples_per_frame;
    dec->bits_per_sample = bits_per_sample;
    dec->smooth_on = smooth_on;
    dec->factor = pow(2,dec->bits_per_sample);
    dec->h = MAXX / dec->samples_per_frame;

    // Clear tables
    if (dec->divtable) {
        free(dec->divtable);
        dec->divtable = NULL;
    }
    for(s=0; s<4; s++) {
        if (dec->dectable[s]) {
            free(dec->dectable[s]);
            dec->dectable[s] = NULL;
        }
    }

    // fill table for 1/div, where
    // div=[0...2*MAXX]
    // values=[0..2*MAXX]
    dec->divtable = calloc( 2*MAXX+1, sizeof(int32_t) );
    if(dec->divtable==NULL) {
        MYLOG_ERROR("Could not allocate memory for dec->divtable (%d bytes)", (2*MAXX+1)*sizeof(int32_t) );
        goto exit_fail;
    }
    dec->divtable[0] = 0;
    for(i=1; i<2*MAXX+1; i++) {
        dec->divtable[i] = 4*MAXX*MAXX / i;
    }

    // fill decode tables
    // inputs=dvoice/ampdv=[0..(dec->factor-1)], values=[-MAXX..+MAXX]
    for(s=0; s<4; s++) {
        dec->dectable[s] = calloc( dec->factor, sizeof(int32_t) );
        if(dec->dectable[s] = NULL) {
            MYLOG_ERROR("Could not allocate memory for dec->dectable[%d] (%d bytes)", s, dec->factor * sizeof(int32_t) );
            goto exit_fail;
        }
        for(i=0; i < dec->factor; i++) {
            sss = 2*MAXX*i/dec->factor - MAXX;
            dec->table[s][i] = MAXX*expand( double(sss)/MAXX, s );
        }
    }

    MYLOG_DEBUG("MMDQ-decoder has been successfully initialized!");
    return 0;

exit_fail:
    if (dec->divtable) {
        free(dec->divtable);
        dec->divtable = NULL;
    }
    for(s=0; s<4; s++) {
        if (dec->dectable[s]) {
            free(dec->dectable[s]);
            dec->dectable[s] = NULL;
        }
    }
    return -1;
}

//------------------------------------------------------------------------------
int  mmdq_decoder ( struct mmdq_decoder_s * dec,
                    uint8_t * data, int bytes,
                    int16_t * voice, int voicesize, int * samples )
{
    uint8_t dv[];


    //Check input arguments
    if(dec==NULL) {
        MYLOG_ERROR("Invalid argument: dec=NULL");
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

    //bit-unpack from data[] into minx, maxx, smooth1, dv[]
    minx = alaw2linear( data[0] );
    maxx = alaw2linear( data[1] );
    if (minx > maxx) {
        smooth0 = 1;
        tmpx = minx;
        minx = maxx;
        maxx = tmpx;
    }
    else {
        smooth0 = 0;
    }
    smooth1 = (data[2]>>7) & 1;

    smooth = (smooth1<<1)|smooth;
    
    pos = 2;
    bitcntr = 7;
    bitshift = data[pos++] & 0x7F;
    dvpos = 0;
    
    for(i=0; i<dec->samples_per_frame-1; i++) {
        bitshift = (bitshift << 8) | data[pos++];
        bitcntr += 8;
        
        while(bitcntr >= dec->bits_per_sample) {
            bitcntr -= dec->bits_per_samlpe;
            dv[dvpos++] = bitshift >> bitcntr;
        }
    }
    
    //Reconstrunct voice in relative coordinats
    voice[0] = 0;
    for(i=0; i<dec->samples_per_frame-1; i++) {
        // dv[i] = [0..dec.factor-1]
        // dec->table[] = [-maxx..+maxx]
        voice[i+1] = voice[i] + dec->table[smooth][ dv[i] ];
    }

    // Scale/shift absolute voice by minv,maxv reference points
    minv = maxv = voice[0];
    for (i=0; i<dec->samples_per_frame; i++) {
        if (voice[i]<minv)
            minv = voice[i];
        else if (voice[i]>maxv)
            maxv = voice[i];
    }
    diffv = maxv - minv;

    diffv_n = (diffv * dec->h) / MAXX;
    maxv_n  = (maxv  * dec->h) / MAXX;
    minv_n  = (minv  * dec->h) / MAXX;

    div = dec->divtable[voicediff_n];  //div=[0..2*maxx]
    
    for (i=0; i<dec->samples_per_frame; i++) {
        voice_n = (voice[i] * dec->h) / MAXX;
        voice[i] = minv + diffv * div * (voice_n - minv_n) / (4*MAXX*MAXX);
    }
    
    return 0;
}

//------------------------------------------------------------------------------
//mmdq_decoder version without bit-unpacking (for use in mmdq_encoder)
int  mmdq_decoder_nopack ( struct mmdq_decoder_s * dec,
                           uint8_t * data, int bytes,
                           int16_t * voice, int voicesize, int * samples )
{
    minx = alaw2linear( data[0] );
    maxx = alaw2linear( data[1] );
    if (minx>maxx) {
        tmpx = minx;
        minx = maxx;
        maxx = tmpx;
        smooth0 = 0;
    }
    else {
        smooth0 = 0;
    }
    smooth1 = data[2];

    //Reconstrunct voice in relative coordinats
    voice[0] = 0;
    for(i=0; i<dec->samples_per_frame-1; i++) {
        // dv[i] = [0..dec.factor-1]
        // dec->table[] = [-maxx..+maxx]
        voice[i+1] = voice[i] + dec->table[smooth][ data[3+i] ];
    }

    // Scale/shift absolute voice by minv,maxv reference points
    minv = maxv = voice[0];
    for (i=0; i<dec->samples_per_frame; i++) {
        if (voice[i]<minv)
            minv = voice[i];
        else if (voice[i]>maxv)
            maxv = voice[i];
    }
    diffv = maxv - minv;

    diffv_n = (diffv * dec->h) / MAXX;
    maxv_n  = (maxv  * dec->h) / MAXX;
    minv_n  = (minv  * dec->h) / MAXX;

    div = dec->divtable[voicediff_n];  //div=[0..2*maxx]
    
    for (i=0; i<dec->samples_per_frame; i++) {
        voice_n = (voice[i] * dec->h) / MAXX;
        voice[i] = minv + diffv * div * (voice_n - minv_n) / (4*MAXX*MAXX);
    }
    
    return 0;
}









