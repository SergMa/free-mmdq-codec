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
int power( int x, int pow )
{
    int i;
    int res;

    if (pow<0) {
        return 0;
    }
    else if (pow==0) {
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
//INPUTS:  x=[-MAXX..+MAXX]
//OUTPUTS: y=[-MAXX..+MAXX]
int32_t compand( int32_t x, int law )
{

    switch(law)
    {
    case 1:
        // VER1: power 1.3 table
        // a = -1:0.01:1;
        // table = sign(a) .* abs(a) .^ (1/1.2);
        if x>=0
            y = x ^ (1/1.2)

        y = x


        return;

    case 2:

        return;

    case 3:

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
int  mmdq_encoder_init ( struct mmdq_encoder_s * enc,
                         int samples_per_frame,
                         int bits_per_sample,
                         int smooth_on )
{
    int i;
    int32_t a;
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
    enc->factor = power(2,enc->bits_per_sample);

    // fill table for 1/div, where div=[0...2*MAXX*1024]
    // values=[0..2*MAXX]
    if (enc->divtable) {
        free(enc->divtable);
        enc->divtable = NULL;
    }
    enc->divtable = calloc( 2*MAXX+1, sizeof(int32_t) );
    if(enc->divtable==NULL) {
        MYLOG_ERROR("Could not allocate memory for enc->divtable (%d bytes)", (2*MAXX+1)*sizeof(int32_t) );
        goto exit_fail;
    }
    enc->divtable[0] = 0;
    for(i=1; i<2*MAXX+1; i++) {
        enc->divtable[i] = 2*MAXX*1024/i;
    }

    // fill encode table0
    // inputs=dvoice/ampdv = [-MAXX..+MAXX]
    // values=[0..(enc->factor-1)]
    if (enc->enctable0) {
        free(enc->enctable0);
        enc->enctable0 = NULL;
    }
    enc->enctable0 = calloc( 2*MAXX+1, sizeof(int32_t) );
    if(enc->enctable0==NULL) {
        MYLOG_ERROR("Could not allocate memory for enc->enctable0 (%d bytes)", (2*MAXX+1)*sizeof(int32_t) );
        goto exit_fail;
    }
    for(a=-MAXX; a<=MAXX; a++) {
        b = a + MAXX; // b=[0..2*MAXX]

        //sss = round( enc->factor * b / (2*MAXX) );
        sss = 2 * enc->factor * b / (2*MAXX);
        if (sss & 1)
                sss = sss/2 + 1;
        else    sss = sss/2;

        if (sss > (enc->factor-1) ) {
            sss > (enc->factor-1);
        }
        enc->enctable0[a+MAXX] = sss;
    }

    // fill encode table1
    // inputs=dvoice/ampdv = [-MAXX..+MAXX]
    // values=[0..(enc->factor-1)]
    if (enc->enctable1) {
        free(enc->enctable1);
        enc->enctable1 = NULL;
    }
    enc->enctable1 = calloc( 2*MAXX+1, sizeof(int32_t) );
    if(enc->enctable1==NULL) {
        MYLOG_ERROR("Could not allocate memory for enc->enctable1 (%d bytes)", (2*MAXX+1)*sizeof(int32_t) );
        goto exit_fail;
    }
    for(a=-MAXX; a<=MAXX; a++) {
        //b = fix( maxx*compand(a/maxx,1) ) + maxx; %b=[0..2*maxx]
        b = compand(a,1) + MAXX; // b=[0..2*MAXX]

        //sss = round( enc->factor * b / (2*MAXX) );
        sss = 2 * enc->factor * b / (2*MAXX);
        if (sss & 1)
                sss = sss/2 + 1;
        else    sss = sss/2;

        if (sss > (enc->factor-1) ) {
            sss > (enc->factor-1);
        }
        enc->enctable1[a+MAXX] = sss;
    }

    // fill encode table2
    // inputs=dvoice/ampdv = [-MAXX..+MAXX]
    // values=[0..(enc->factor-1)]
    if (enc->enctable2) {
        free(enc->enctable2);
        enc->enctable2 = NULL;
    }
    enc->enctable2 = calloc( 2*MAXX+1, sizeof(int32_t) );
    if(enc->enctable2==NULL) {
        MYLOG_ERROR("Could not allocate memory for enc->enctable2 (%d bytes)", (2*MAXX+1)*sizeof(int32_t) );
        goto exit_fail;
    }
    for(a=-MAXX; a<=MAXX; a++) {
        //b = fix( maxx*compand(a/maxx,1) ) + maxx; %b=[0..2*maxx]
        b = compand(a,1) + MAXX; // b=[0..2*MAXX]

        //sss = round( enc->factor * b / (2*MAXX) );
        sss = 2 * enc->factor * b / (2*MAXX);
        if (sss & 1)
                sss = sss/2 + 1;
        else    sss = sss/2;

        if (sss > (enc->factor-1) ) {
            sss > (enc->factor-1);
        }
        enc->enctable2[a+MAXX] = sss;
    }

    // fill encode table3
    // inputs=dvoice/ampdv = [-MAXX..+MAXX]
    // values=[0..(enc->factor-1)]
    if (enc->enctable3) {
        free(enc->enctable3);
        enc->enctable3 = NULL;
    }
    enc->enctable3 = calloc( 2*MAXX+1, sizeof(int32_t) );
    if(enc->enctable3==NULL) {
        MYLOG_ERROR("Could not allocate memory for enc->enctable3 (%d bytes)", (2*MAXX+1)*sizeof(int32_t) );
        goto exit_fail;
    }
    for(a=-MAXX; a<=MAXX; a++) {
        //b = fix( maxx*compand(a/maxx,1) ) + maxx; %b=[0..2*maxx]
        b = compand(a,1) + MAXX; // b=[0..2*MAXX]

        //sss = round( enc->factor * b / (2*MAXX) );
        sss = 2 * enc->factor * b / (2*MAXX);
        if (sss & 1)
                sss = sss/2 + 1;
        else    sss = sss/2;

        if (sss > (enc->factor-1) ) {
            sss > (enc->factor-1);
        }
        enc->enctable3[a+MAXX] = sss;
    }

}

//------------------------------------------------------------------------------
int  mmdq_encoder      ( struct mmdq_encoder_s * enc,
                         int16_t * voice, int samples,
                         uint8_t * data, int datasize, int * bytes )
{



}
