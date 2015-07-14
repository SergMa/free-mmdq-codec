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
#include <g72x.h>

void usage(void)
{
    char * usage_str =

    "Usage:\n"
    "\n"
    "  test --mmdq-encode <spf> <bps> <smoothon> <sound.wav> <data.bin>\n"
    "    Encode <sound.wav> file with MMDQ-encoder, output result into <data.bin>.\n"
    "    <spf>      = 1..1000 - defines samples-per-frame parameter\n"
    "    <bps>      = 1..16   - defines bits-per-sample parameter\n"
    "    <smoothon> = 0,1     - defines if smooth functions will be enabled or disabled\n"
    "\n"
    "  test --mmdq-decode <spf> <bps> <smoothon> <data.bin> <sound.wav>\n"
    "    Decode <data.bin> file with MMDQ-decoder, output result into <sound.wav>.\n"
    "    <spf>      = 1..1000 - defines samples-per-frame parameter\n"
    "    <bps>      = 1..16   - defines bits-per-sample parameter\n"
    "    <smoothon> = 0,1     - defines if smooth functions will be enabled or disabled\n"
    "\n"
    "  test --g726-encode <bitrate> <sound.wav> <data.bin>\n"
    "    Encode <sound.wav> file with G726-encoder, output result into <data.bin>.\n"
    "    <bitrate>  = 16|24|32|40 - defines G.726 bitrate parameter, kbit/sec\n"
    "\n"
    "  test --g726-decode <bitrate> <data.bin> <sound.wav>\n"
    "    Decode <data.bin> file with G726-decoder, output result into <sound.wav>.\n"
    "    <bitrate>  = 16|24|32|40 - defines G.726 bitrate parameter, kbit/sec\n"
    "\n"
    "  test --mse <sound1.wav> <sound2.wav>\n"
    "    Calculate MSE (Mean Squared Error) of difference <sound1.wav> and <sound2.wav>.\n"
    "    MSE will be calculated for N samples, where N is minimal length of files.\n"
    "\n"
    "  test --help\n"
    "    Show this help message.\n"
    "\n";

    printf(usage_str);
    return;
}

#define ACTION_MMDQ_ENCODE   0
#define ACTION_MMDQ_DECODE   1
#define ACTION_G726_ENCODE   2
#define ACTION_G726_DECODE   3
#define ACTION_MSE           4

int main( int argc, char **argv )
{
    struct mmdq_codec_s codec;
    g726_state          g726;
    
    int          spf;
    int          bps;
    int          smoothon;
    int          action;
    int          bitrate;
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
    int          wrsamples;
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
    else if(argc==7 && 0==strcmp(argv[1],"--mmdq-encode")) {
        action   = ACTION_MMDQ_ENCODE;
        spf      = atoi(argv[2]);
        bps      = atoi(argv[3]);
        smoothon = atoi(argv[4]);
        inp_wave_filename = argv[5];
        out_wave_filename = NULL;
        data_filename = argv[6];
        //go-go-go
    }
    else if(argc==7 && 0==strcmp(argv[1],"--mmdq-decode")) {
        action   = ACTION_MMDQ_DECODE;
        spf      = atoi(argv[2]);
        bps      = atoi(argv[3]);
        smoothon = atoi(argv[4]);
        inp_wave_filename = NULL;
        data_filename = argv[5];
        out_wave_filename = argv[6];
        //go-go-go
    }
    else if(argc==5 && 0==strcmp(argv[1],"--g726-encode")) {
        action   = ACTION_G726_ENCODE;
        spf      = 2;
        bps      = 1;
        smoothon = 0;
        bitrate  = atoi(argv[2]);
        inp_wave_filename = argv[3];
        out_wave_filename = NULL;
        data_filename = argv[4];
        //go-go-go
    }
    else if(argc==5 && 0==strcmp(argv[1],"--g726-decode")) {
        action   = ACTION_G726_DECODE;
        spf      = 2;
        bps      = 1;
        smoothon = 0;
        bitrate  = atoi(argv[2]);
        inp_wave_filename = NULL;
        data_filename = argv[3];
        out_wave_filename = argv[4];
        //go-go-go
    }
    else if(argc==4 && 0==strcmp(argv[1],"--mse")) {
        action   = ACTION_MSE;
        inp_wave_filename = argv[2]; //<sound1.wav>
        out_wave_filename = argv[3]; //<sound2.wav>
        data_filename = NULL;
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
    
    g726_init_state( &g726 );
    
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

    case ACTION_MMDQ_ENCODE:

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

    case ACTION_MMDQ_DECODE:

        /* open input datafile */
        df = fopen(data_filename,"r");
        if(!df) {
            printf("error: could not open input datafile \"%s\"\n", data_filename);
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
                if(feof(df)) {
                    //end of file has been reached
                    break;
                }
                printf("error: fread(data) failed!\n");
                goto exit_fail;
            }

            /* decode samples */
            err = mmdq_decode( &codec, data, bytes, x, sizeof(x), &wrsamples );
            //err = 0;
            //wrsamples = spf;
            if(err) {
                printf("error: mmdq_encode() failed!\n");
                goto exit_fail;
            }

           /* wavefile_write_voice() returns:
            *  0 = ok
            *  1 = end of file
            * -1 = error
            */
            err = wavefile_write_voice ( owf, x, wrsamples );
            if(err<0) {
                printf("error: could not write sample to output wave-file\n");
                break;
            }
            else if(err==1) {
                break;
            }


            processed += spf;
        }
        printf("%u samples has been successfully processed\n", processed);


        break;

    case ACTION_G726_ENCODE:

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
            err = wavefile_read_voice ( iwf, x, 1 );  /* samples=1 */
            if(err<0) {
                printf("error: could not read sample from input file\n");
                break;
            }
            else if(err==1) {
                break;
            }

            /* encode sample */
            switch(bitrate) {
            case 16:
                data[0] = g726_16_encoder( x[0], &g726 );
                break;
            case 24:
                data[0] = g726_24_encoder( x[0], &g726 );
                break;
            case 32:
                data[0] = g726_32_encoder( x[0], &g726 );
                break;
            case 40:
                data[0] = g726_40_encoder( x[0], &g726 );
                break;
            default:
                printf("error: unsupported G.726 bitrate=%d\n", bitrate);
                goto exit_fail;
            }

            /* write encode data into file */
            err = fwrite( data, 1, 1, df ); //bytes = 1
            if(err!=1) {
                printf("error: fwrite(data) failed!\n");
                goto exit_fail;
            }

            processed += spf;
        }
        printf("%u samples has been successfully processed\n", processed);

        break;

    case ACTION_G726_DECODE:

        /* open input datafile */
        df = fopen(data_filename,"r");
        if(!df) {
            printf("error: could not open input datafile \"%s\"\n", data_filename);
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

            /* read encode data from file */
            err = fread( data, 1, 1, df ); //bytes=1
            if(err!=1) {
                if(feof(df)) {
                    //end of file has been reached
                    break;
                }
                printf("error: fread(data) failed!\n");
                goto exit_fail;
            }

            /* decode sample */
            switch(bitrate) {
            case 16:
                x[0] = g726_16_decoder( data[0], &g726 );
                break;
            case 24:
                x[0] = g726_24_decoder( data[0], &g726 );
                break;
            case 32:
                x[0] = g726_32_decoder( data[0], &g726 );
                break;
            case 40:
                x[0] = g726_40_decoder( data[0], &g726 );
                break;
            default:
                printf("error: unsupported G.726 bitrate=%d\n", bitrate);
                goto exit_fail;
            }
            
           /* wavefile_write_voice() returns:
            *  0 = ok
            *  1 = end of file
            * -1 = error
            */
            err = wavefile_write_voice ( owf, x, 1 ); //wrsamples=1
            if(err<0) {
                printf("error: could not write sample to output wave-file\n");
                break;
            }
            else if(err==1) {
                break;
            }

            processed += spf;
        }
        printf("%u samples has been successfully processed\n", processed);


        break;

    case ACTION_MSE:

        //...

        break;

    default:
        printf("error: unexpected action %d\n", action);
        goto exit_fail;
    }

    if(iwf) {
        (void) wavefile_close( iwf );
        wavefile_destroy( iwf );
    }
    if(owf) {
        (void) wavefile_close( owf );
        wavefile_destroy( owf );
    }
    if(df) {
        fclose(df);
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
    if(df) {
        fclose(df);
    }
    exit(EXIT_FAILURE);
}
