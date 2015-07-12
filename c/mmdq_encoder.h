/******************************************************************************/
/* MMDQ-ENCODER                                                               */
/* mmdq_encoder.h                                                             */
/* (c) Sergei Mashkin, 2015                                                   */
/******************************************************************************/

#ifndef MMDQ_ENCODER_H
#define MMDQ_ENCODER_H

#include  <my_fract.h>

/******************************************************************************/
/* DEFINITIONS                                                                */
/******************************************************************************/

#define MAXX 32768

struct mmdq_encoder_s {
    int       samples_per_frame;
    int       bits_per_sample;
    int       smooth_on;
    int       factor;
    int       bitrate;

    int32_t * divtable  = NULL;
    uint8_t * enctable0 = NULL;
    uint8_t * enctable1 = NULL;
    uint8_t * enctable2 = NULL;
    uint8_t * enctable3 = NULL;
};

/******************************************************************************/
/* FUNCTIONS                                                                  */
/******************************************************************************/

int  mmdq_encoder_init ( struct mmdq_encoder_s * enc,
                         int samples_per_frame,
                         int bits_per_sample,
                         int smooth_on );

int  mmdq_encoder      ( struct mmdq_encoder_s * enc,
                         int16_t * voice, int samples,
                         uint8_t * data, int datasize, int * bytes );

#endif /* MMDQ_ENCODER_H */
