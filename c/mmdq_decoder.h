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
    fract32          hf100_xdelay;
    fract32          hf100_ydelay;
    struct fir_s     filter   [SUBBANDS];
};

/******************************************************************************/
/* FUNCTIONS                                                                  */
/******************************************************************************/

int  mmdq_decoder_init ( struct mmdq_decoder_s * enc );
int  mmdq_decoder      ( struct mmdq_decoder_s * enc, int16_t * x );

#endif /* MMDQ_DECODER_H */
