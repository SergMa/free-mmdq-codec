/******************************************************************************/
/* MMDQ-CODEC                                                                 */
/* mmdq_codec.h                                                             */
/* (c) Sergei Mashkin, 2015                                                   */
/******************************************************************************/

#ifndef MMDQ_CODEC_H
#define MMDQ_CODEC_H

#include  <my_fract.h>
#include  <wave/types.h>

/******************************************************************************/
/* DEFINITIONS                                                                */
/******************************************************************************/

#define BEST_SMOOTH_VER        0  //0 - ver.0: calculate error[s]=max(abs(voice[i]-voice[s][i]))
//#define BEST_SMOOTH_VER      1  //1 - ver.1: calculate error[s]=sum(abs(voice[i]-voice[s][i]))


#define FIXP                   (2*32768)

#define MAXX                   32768    /* must be power of 2 */
#define SAMPLES_PER_FRAME_MIN  2
#define SAMPLES_PER_FRAME_MAX  1000
#define BITS_PER_SAMPLE_MIN    1
#define BITS_PER_SAMPLE_MAX    8
#define DATA_SIZE_MAX          (SAMPLES_PER_FRAME_MAX+3)
#define SMOOTH_MAX             4

struct mmdq_codec_s {
    int        samples_per_frame;
    int        bits_per_sample;
    int        smooth;
    int        factor;
    int        bitrate;
    int        decoder_only;
    int32_t    h;
    uint32_t   unpackmask;      //used in decoder for unpacking bits
    int        databytes;       //size of encoded frame, bytes
    int        databytesnopack; //size of no-bit-packed encoded frame, bytes

    int32_t  * divtable;
    int8_t   * enctable[SMOOTH_MAX];
    int32_t  * dectable[SMOOTH_MAX];
};

/******************************************************************************/
/* FUNCTIONS                                                                  */
/******************************************************************************/

int  mmdq_codec_init ( struct mmdq_codec_s * codec,
                       int samples_per_frame,
                       int bits_per_sample,
                       int smooth,
                       int decoder_only );

int  mmdq_framebytes ( struct mmdq_codec_s * codec );

int  mmdq_encode     ( struct mmdq_codec_s * codec,
                       int16_t * voice, int samples,
                       uint8_t * data, int datasize, int * bytes );

int  mmdq_decode     ( struct mmdq_codec_s * codec,
                       uint8_t * data, int bytes,
                       int16_t * voice, int voicesize, int * samples );

#endif /* MMDQ_CODEC_H */
