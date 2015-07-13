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
#define SAMPLES_PER_FRAME_MAX  1000
#define BITS_PER_SAMPLE_MAX    8
#define DATA_SIZE_MAX          (SAMPLES_PER_FRAME_MAX+3)

struct mmdq_encoder_s {
    int       samples_per_frame;
    int       bits_per_sample;
    int       smooth_on;
    int       factor;
    int       bitrate;

    int32_t * divtable = NULL;
    uint8_t * enctable[4];
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
