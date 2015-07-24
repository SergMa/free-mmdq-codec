/******************************************************************************/
/* SUPER-FAST G.711 UTILITES (PCMU,PCMA)                                      */
/*                                                                            */
/* (c) TODO: find authors                                                     */
/******************************************************************************/

/* Compilation of DAHDI, SpanDSP codes */

/*
 * SpanDSP - a series of DSP components for telephony
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License version 2.1,
 * as published by the Free Software Foundation.
 *
 * Written by Steve Underwood <steveu@coppice.org>
 * Copyright (C) 2001 Steve Underwood
 */

#include "g711super.h"

//======== DECOMPRESS FUNCTIONS ================================================

short MuLawDecompressTable[256] =
{
     -32124,-31100,-30076,-29052,-28028,-27004,-25980,-24956,
     -23932,-22908,-21884,-20860,-19836,-18812,-17788,-16764,
     -15996,-15484,-14972,-14460,-13948,-13436,-12924,-12412,
     -11900,-11388,-10876,-10364, -9852, -9340, -8828, -8316,
      -7932, -7676, -7420, -7164, -6908, -6652, -6396, -6140,
      -5884, -5628, -5372, -5116, -4860, -4604, -4348, -4092,
      -3900, -3772, -3644, -3516, -3388, -3260, -3132, -3004,
      -2876, -2748, -2620, -2492, -2364, -2236, -2108, -1980,
      -1884, -1820, -1756, -1692, -1628, -1564, -1500, -1436,
      -1372, -1308, -1244, -1180, -1116, -1052,  -988,  -924,
       -876,  -844,  -812,  -780,  -748,  -716,  -684,  -652,
       -620,  -588,  -556,  -524,  -492,  -460,  -428,  -396,
       -372,  -356,  -340,  -324,  -308,  -292,  -276,  -260,
       -244,  -228,  -212,  -196,  -180,  -164,  -148,  -132,
       -120,  -112,  -104,   -96,   -88,   -80,   -72,   -64,
        -56,   -48,   -40,   -32,   -24,   -16,    -8,     0,
      32124, 31100, 30076, 29052, 28028, 27004, 25980, 24956,
      23932, 22908, 21884, 20860, 19836, 18812, 17788, 16764,
      15996, 15484, 14972, 14460, 13948, 13436, 12924, 12412,
      11900, 11388, 10876, 10364,  9852,  9340,  8828,  8316,
       7932,  7676,  7420,  7164,  6908,  6652,  6396,  6140,
       5884,  5628,  5372,  5116,  4860,  4604,  4348,  4092,
       3900,  3772,  3644,  3516,  3388,  3260,  3132,  3004,
       2876,  2748,  2620,  2492,  2364,  2236,  2108,  1980,
       1884,  1820,  1756,  1692,  1628,  1564,  1500,  1436,
       1372,  1308,  1244,  1180,  1116,  1052,   988,   924,
        876,   844,   812,   780,   748,   716,   684,   652,
        620,   588,   556,   524,   492,   460,   428,   396,
        372,   356,   340,   324,   308,   292,   276,   260,
        244,   228,   212,   196,   180,   164,   148,   132,
        120,   112,   104,    96,    88,    80,    72,    64,
         56,    48,    40,    32,    24,    16,     8,     0
};

short ALawDecompressTable[256] =
{
     -5504, -5248, -6016, -5760, -4480, -4224, -4992, -4736,
     -7552, -7296, -8064, -7808, -6528, -6272, -7040, -6784,
     -2752, -2624, -3008, -2880, -2240, -2112, -2496, -2368,
     -3776, -3648, -4032, -3904, -3264, -3136, -3520, -3392,
     -22016,-20992,-24064,-23040,-17920,-16896,-19968,-18944,
     -30208,-29184,-32256,-31232,-26112,-25088,-28160,-27136,
     -11008,-10496,-12032,-11520,-8960, -8448, -9984, -9472,
     -15104,-14592,-16128,-15616,-13056,-12544,-14080,-13568,
     -344,  -328,  -376,  -360,  -280,  -264,  -312,  -296,
     -472,  -456,  -504,  -488,  -408,  -392,  -440,  -424,
     -88,   -72,   -120,  -104,  -24,   -8,    -56,   -40,
     -216,  -200,  -248,  -232,  -152,  -136,  -184,  -168,
     -1376, -1312, -1504, -1440, -1120, -1056, -1248, -1184,
     -1888, -1824, -2016, -1952, -1632, -1568, -1760, -1696,
     -688,  -656,  -752,  -720,  -560,  -528,  -624,  -592,
     -944,  -912,  -1008, -976,  -816,  -784,  -880,  -848,
      5504,  5248,  6016,  5760,  4480,  4224,  4992,  4736,
      7552,  7296,  8064,  7808,  6528,  6272,  7040,  6784,
      2752,  2624,  3008,  2880,  2240,  2112,  2496,  2368,
      3776,  3648,  4032,  3904,  3264,  3136,  3520,  3392,
      22016, 20992, 24064, 23040, 17920, 16896, 19968, 18944,
      30208, 29184, 32256, 31232, 26112, 25088, 28160, 27136,
      11008, 10496, 12032, 11520, 8960,  8448,  9984,  9472,
      15104, 14592, 16128, 15616, 13056, 12544, 14080, 13568,
      344,   328,   376,   360,   280,   264,   312,   296,
      472,   456,   504,   488,   408,   392,   440,   424,
      88,    72,   120,   104,    24,     8,    56,    40,
      216,   200,   248,   232,   152,   136,   184,   168,
      1376,  1312,  1504,  1440,  1120,  1056,  1248,  1184,
      1888,  1824,  2016,  1952,  1632,  1568,  1760,  1696,
      688,   656,   752,   720,   560,   528,   624,   592,
      944,   912,  1008,   976,   816,   784,   880,   848
};

//======== COMPRESS FUNCTIONS ==================================================

unsigned char MuLawCompressTable[16384];
unsigned char ALawCompressTable[16384];

//------------------------------------------------------------------------------
unsigned char MuLawALawRecompressTable[256];
unsigned char ALawMuLawRecompressTable[256];


#if !defined(top_bit)
//------------------------------------------------------------------------------
int top_bit(unsigned int bits)
{
    int res;

    if (bits == 0)
        return -1;
    res = 0;
    if (bits & 0xFFFF0000)
    {
        bits &= 0xFFFF0000;
        res += 16;
    }
    if (bits & 0xFF00FF00)
    {
        bits &= 0xFF00FF00;
        res += 8;
    }
    if (bits & 0xF0F0F0F0)
    {
        bits &= 0xF0F0F0F0;
        res += 4;
    }
    if (bits & 0xCCCCCCCC)
    {
        bits &= 0xCCCCCCCC;
        res += 2;
    }
    if (bits & 0xAAAAAAAA)
    {
        bits &= 0xAAAAAAAA;
        res += 1;
    }
    return res;
}
#endif

/*
 * Mu-law is basically as follows:
 *
 *      Biased Linear Input Code        Compressed Code
 *      ------------------------        ---------------
 *      00000001wxyza                   000wxyz
 *      0000001wxyzab                   001wxyz
 *      000001wxyzabc                   010wxyz
 *      00001wxyzabcd                   011wxyz
 *      0001wxyzabcde                   100wxyz
 *      001wxyzabcdef                   101wxyz
 *      01wxyzabcdefg                   110wxyz
 *      1wxyzabcdefgh                   111wxyz
 *
 * Each biased linear code has a leading 1 which identifies the segment
 * number. The value of the segment number is equal to 7 minus the number
 * of leading 0's. The quantization interval is directly available as the
 * four bits wxyz.  * The trailing bits (a - h) are ignored.
 *
 * Ordinarily the complement of the resulting code word is used for
 * transmission, and so the code word is complemented before it is returned.
 *
 * For further information see John C. Bellamy's Digital Telephony, 1982,
 * John Wiley & Sons, pps 98-111 and 472-476.
 */

/* Enable the trap as per the MIL-STD */
/* #define G711_ULAW_ZEROTRAP */

/* Bias for u-law encoding from linear. */
#define G711_ULAW_BIAS      0x84

//------------------------------------------------------------------------------
/* Encode a linear sample to u-law */
inline uint8_t  linear2mulaw2(int16_t sample)
{
    uint8_t u_val;
    int mask;
    int seg;

    /* Get the sign and the magnitude of the value. */
    if (sample >= 0)
    {
        sample = G711_ULAW_BIAS + sample;
        mask = 0xFF;
    }
    else
    {
        sample = G711_ULAW_BIAS - sample;
        mask = 0x7F;
    }

    seg = top_bit(sample | 0xFF) - 7;

    /*
     * Combine the sign, segment, quantization bits,
     * and complement the code word.
     */
    if (seg >= 8)
        u_val = (uint8_t) (0x7F ^ mask);
    else
        u_val = (uint8_t) (((seg << 4) | ((sample >> (seg + 3)) & 0xF)) ^ mask);
#if defined(G711_ULAW_ZEROTRAP)
    /* Optional ITU trap */
    if (u_val == 0)
        u_val = 0x02;
#endif
    return  u_val;
}

/*
 * A-law is basically as follows:
 *
 *      Linear Input Code        Compressed Code
 *      -----------------        ---------------
 *      0000000wxyza             000wxyz
 *      0000001wxyza             001wxyz
 *      000001wxyzab             010wxyz
 *      00001wxyzabc             011wxyz
 *      0001wxyzabcd             100wxyz
 *      001wxyzabcde             101wxyz
 *      01wxyzabcdef             110wxyz
 *      1wxyzabcdefg             111wxyz
 *
 * For further information see John C. Bellamy's Digital Telephony, 1982,
 * John Wiley & Sons, pps 98-111 and 472-476.
 */

/* The A-law alternate mark inversion mask */
#define G711_ALAW_AMI_MASK      0x55

//------------------------------------------------------------------------------
/* Encode a linear sample to A-law */
inline uint8_t  linear2alaw2(int16_t sample)
{
    int mask;
    int seg;
    
    if (sample >= 0)
    {
        /* Sign (bit 7) bit = 1 */
        mask = G711_ALAW_AMI_MASK | 0x80;
    }
    else
    {
        /* Sign (bit 7) bit = 0 */
        mask = G711_ALAW_AMI_MASK;
        sample = -sample - 1;
    }

    /* Convert the scaled magnitude to segment number. */
    seg = top_bit(sample | 0xFF) - 7;
    if (seg >= 8)
    {
        if (sample >= 0)
        {
            /* Out of range. Return maximum value. */
            return (uint8_t) (0x7F ^ mask);
        }
        /* We must be just a tiny step below zero */
        return (uint8_t) (0x00 ^ mask);
    }
    /* Combine the sign, segment, and quantization bits. */
    return (uint8_t) (((seg << 4) | ((sample >> ((seg)  ?  (seg + 3)  :  4)) & 0x0F)) ^ mask);
}


static char needinitg711 = 1;
//------------------------------------------------------------------------------
inline void init_g711(void)
{
    int           i;
    
    if(needinitg711)
    {
        needinitg711 = 0;
        
        // set up the reverse (mu-law,a-law) conversion table
        for(i = -32768; i < 32768; i += 4) {
            MuLawCompressTable[((unsigned short)(short)i) >> 2] = linear2mulaw2(i);
            ALawCompressTable [((unsigned short)(short)i) >> 2] = linear2alaw2 (i);
        }

        // set up recomression tables
        for(i=0; i<256; i++) {
            MuLawALawRecompressTable[i] = linear2alaw ( mulaw2linear(i) );
            ALawMuLawRecompressTable[i] = linear2mulaw(  alaw2linear(i) );
        }
    }
}

