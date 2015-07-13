/******************************************************************************/
/* MMDQ-DECODER                                                               */
/* mmdq_decoder.h                                                             */
/* (c) Sergei Mashkin, 2015                                                   */
/******************************************************************************/

#ifndef MMDQ_DECODER_H
#define MMDQ_DECODER_H

#include  <my_fract.h>

/******************************************************************************/
/* DEFINITIONS                                                                */
/******************************************************************************/

struct mmdq_decoder_s {
    int       samples_per_frame;
    int       bits_per_sample;
    int       smooth_on;
    int       factor;
    int       bitrate;
    int       h;

    int32_t * divtable = NULL;
    uint8_t * dectable[4];
};

/******************************************************************************/
/* FUNCTIONS                                                                  */
/******************************************************************************/

int  mmdq_decoder_init ( struct mmdq_decoder_s * dec,
                         int samples_per_frame,
                         int bits_per_sample,
                         int smooth_on );

int  mmdq_decoder      ( struct mmdq_decoder_s * dec,
                         uint8_t * data, int bytes,
                         int16_t * voice, int voicesize, int * samples );

int  mmdq_decoder_nopack ( struct mmdq_decoder_s * dec,
                           int16_t minx, int16_t maxx, int smooth, uint8_t * dv,
                           int16_t * voice );

#endif /* MMDQ_DECODER_H */
