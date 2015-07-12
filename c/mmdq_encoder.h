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

struct mmdq_encoder_s {
    fract32          hf100_xdelay;
    fract32          hf100_ydelay;
    struct fir_s     filter   [SUBBANDS];
};

/******************************************************************************/
/* FUNCTIONS                                                                  */
/******************************************************************************/

int  mmdq_encoder_init ( struct mmdq_encoder_s * enc );
int  mmdq_encoder      ( struct mmdq_encoder_s * enc, int16_t * x );

#endif /* MMDQ_ENCODER_H */
