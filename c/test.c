/******************************************************************************/
/* TEST PROGRAMM FOR FREE-MMDQ-CODEC                                          */
/* test.c                                                                     */
/* (c) Sergei Mashkin, 2015                                                   */
/******************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <wave.h>
#include <mmdq_codec.h>

void usage(void)
{
    char * usage_str =

    "Usage:\n"
    "  test --encode <spf> <bps> <smoothon> <sound.wav> <data.bin>\n"
    "    Encode <sound.wav> file with MMDQ-encoder, output result into <data.bin>.\n"
    "    <spf>      = 1..1000 - defines samples-per-frame parameter\n"
    "    <bps>      = 1..16   - defines bits-per-sample parameter\n"
    "    <smoothon> = 0,1     - defines if smooth functions will be enabled or disabled\n"
    "  test --decode <spf> <bps> <smoothon> <sound.wav> <data.bin>\n"
    "    Decode <data.bin> file with MMDQ-decoder, output result into <sound.wav>.\n"
    "    <spf>      = 1..1000 - defines samples-per-frame parameter\n"
    "    <bps>      = 1..16   - defines bits-per-sample parameter\n"
    "    <smoothon> = 0,1     - defines if smooth functions will be enabled or disabled\n"
    "  test --restore <spf> <bps> <smoothon> <sound.wav> <output.bin> <output.wav>\n"
    "    Make encode/decode test of MMDQ-encoder:\n"
    "    encode sound from <sound.wav>, put encoded data into <output.bin>,\n"
    "    decode encoded data back into <output.wav>.\n"
    "    <spf>      = 1..1000 - defines samples-per-frame parameter\n"
    "    <bps>      = 1..16   - defines bits-per-sample parameter\n"
    "    <smoothon> = 0,1     - defines if smooth functions will be enabled or disabled\n"
    "  test --help\n"
    "    Show this help message.\n"
    "\n";

    printf(usage_str);
    return;
}

#define ACTION_ENCODE   0
#define ACTION_DECODE   1
#define ACTION_RESTORE  2

int main( int argc, char **argv )
{
    struct mmdq_codec_s codec;
    int          spf;
    int          bps;
    int          smoothon;
    int          action;
    char       * inp_wave_filename = NULL;
    char       * out_wave_filename = NULL;
    char       * data_filename = NULL;
    wavefile_t * iwf = NULL; /* input sound file */
    wavefile_t * owf = NULL; /* output sound file */
    FILE       * df = NULL;  /* input/output data file */

    int          err;
    int16_t      x[SAMPLES_PER_FRAME_MAX];
    //int16_t      y[SAMPLES_PER_FRAME_MAX];
    uint8_t      data[DATA_SIZE_MAX];
    uint32_t     samples;
    int          rdsamples;
    int          bytes;
    uint32_t     processed;

    if(argc<=0) {
        printf("error: unexpected error\n");
        exit(EXIT_SUCCESS);
    }

    /**** Get and process command options ****/
    if(argc<=2 || argc>8) {
        printf("error: invalid number of arguments\n");
        usage();
        exit(EXIT_SUCCESS);
    }
    else if(argc==2 && 0==strcmp(argv[1],"--help")) {
        usage();
        exit(EXIT_SUCCESS);
    }
    else if(argc==7 && 0==strcmp(argv[1],"--encode")) {
        action   = ACTION_ENCODE;
        spf      = atoi(argv[2]);
        bps      = atoi(argv[3]);
        smoothon = atoi(argv[4]);
        inp_wave_filename = argv[5];
        out_wave_filename = NULL;
        data_filename = argv[6];
        //go-go-go
    }
    else if(argc==7 && 0==strcmp(argv[1],"--decode")) {
        action   = ACTION_DECODE;
        spf      = atoi(argv[2]);
        bps      = atoi(argv[3]);
        smoothon = atoi(argv[4]);
        inp_wave_filename = NULL;
        out_wave_filename = argv[5];
        data_filename = argv[6];
        //go-go-go
    }
    else if(argc==8 && 0==strcmp(argv[1],"--restore")) {
        action   = ACTION_RESTORE;
        spf      = atoi(argv[2]);
        bps      = atoi(argv[3]);
        smoothon = atoi(argv[4]);
        inp_wave_filename = argv[5];
        data_filename = argv[6];
        out_wave_filename = argv[7];
        //go-go-go
    }
    else {
        printf("error: invalid number of arguments\n");
        usage();
        exit(EXIT_SUCCESS);
    }

    /**** initialize variables ****/
    err = mmdq_codec_init( &codec, spf, bps, smoothon, 0 ); //decoder_only=0
    if(err<0) {
        printf("error: mmdq_codec_init() failed\n");
        goto exit_fail;
    }
    iwf = wavefile_create();
    if(!iwf) {
        printf("error: wavefile_create() failed for input\n");
        goto exit_fail;
    }
    owf = wavefile_create();
    if(!owf) {
        printf("error: wavefile_create() failed for output\n");
        goto exit_fail;
    }

    /**** Make action ****/
    switch(action)
    {

    case ACTION_ENCODE:

        /* open input wavefile, show file-info */
        err = wavefile_read_open( iwf, inp_wave_filename );
        if(err<0) {
            printf("error: could not open wavefile \"%s\"\n", inp_wave_filename);
            goto exit_fail;
        }
        printf("wavefile info:\n");
        printf("  filename : %s\n", inp_wave_filename);
        printf("  format   : ");
        switch( wavefile_get_wavetype( iwf ) ) {
        case WAVETYPE_MONO_8000HZ_PCM16:   printf("pcm16 8000 Hz\n"); break;
        case WAVETYPE_MONO_8000HZ_PCMA:    printf("pcma 8000 Hz\n"); break;
        case WAVETYPE_MONO_8000HZ_PCMU:    printf("pcmu 8000 Hz\n"); break;
        case WAVETYPE_MONO_8000HZ_GSM610:  printf("gsm0610 8000 Hz\n"); break;
        default:
            printf("unsupported\n");
            printf("error: only 8000 hz pcm16/pcma/pcmu/gsm formats are supported\n");
            goto exit_fail;
        }
        printf("  filesize : %u bytes\n", wavefile_get_bytes  ( iwf ) );
        printf("  length   : %u sec\n",   wavefile_get_seconds( iwf ) );
        samples = wavefile_get_samples( iwf );
        printf("  samples  : %u\n", samples );

        /* create/open output datafile */
        df = fopen(data_filename,"w");
        if(!df) {
            printf("error: could not create/open output datafile \"%s\"", data_filename);
            goto exit_fail;
        }

        /* main loop */
        processed = 0;
        while(1) {
            /* wavefile_read_voice() returns:
            *  0 = ok
            *  1 = end of file
            * -1 = error
            */
            err = wavefile_read_voice ( iwf, x, spf );  /* samples=spf */
            if(err<0) {
                printf("error: could not read sample from input file\n");
                break;
            }
            else if(err==1) {
                break;
            }

            /* encode samples */
            err = mmdq_encode( &codec, x, spf, data, sizeof(data), &bytes );
            if(err) {
                printf("error: mmdq_encode() failed!\n");
                goto exit_fail;
            }

            /* write encode data into file */
            err = fwrite( data, bytes, 1, df );
            if(err!=1) {
                printf("error: fwrite(data) failed!\n");
                goto exit_fail;
            }

            processed += spf;
        }
        printf("%u samples has been successfully processed\n", processed);

        break;

    case ACTION_DECODE:

        /* open input datafile */
        df = fopen(data_filename,"r");
        if(!df) {
            printf("error: could not open input datafile \"%s\"", data_filename);
            goto exit_fail;
        }

        /* open output wavefile */
        err = wavefile_write_open( owf, out_wave_filename, WAVETYPE_MONO_8000HZ_PCM16 );
        if(err<0) {
            printf("error: could not create wavefile \"%s\"\n", out_wave_filename);
            goto exit_fail;
        }

        /* main loop */
        processed = 0;
        while(1) {

            bytes = (8+8+1+(spf-1)*bps) / 8;  //TODO: zero add bits to full bytes
            /* read encode data from file */
            err = fread( data, bytes, 1, df );
            if(err!=1) {
                printf("error: fread(data) failed!\n");
                goto exit_fail;
            }

           /* wavefile_write_voice() returns:
            *  0 = ok
            *  1 = end of file
            * -1 = error
            */
            err = wavefile_write_voice ( iwf, x, spf );  /* samples=spf */
            if(err<0) {
                printf("error: could not read sample from input file\n");
                break;
            }
            else if(err==1) {
                break;
            }

            /* encode samples */
            err = mmdq_decode( &codec, data, bytes, x, sizeof(x), &rdsamples );
            if(err) {
                printf("error: mmdq_encode() failed!\n");
                goto exit_fail;
            }


            processed += spf;
        }
        printf("%u samples has been successfully processed\n", processed);


        break;

    case ACTION_RESTORE:

        //...

        break;

    default:
        printf("error: unexpected action %d\n", action);
        goto exit_fail;
    }

    exit(EXIT_SUCCESS);

exit_fail:
    if(iwf) {
        (void) wavefile_close( iwf );
        wavefile_destroy( iwf );
    }
    if(owf) {
        (void) wavefile_close( owf );
        wavefile_destroy( owf );
    }
    exit(EXIT_FAILURE);
}
