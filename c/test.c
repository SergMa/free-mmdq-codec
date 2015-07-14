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
#include <g711super.h>
#include <math.h>

//------------------------------------------------------------------------------
void usage(void)
{
    char * usage_str =

    "Usage:\n"
    "\n"
    "  test --mmdq-encode <spf> <bps> <smoothon> <sound.wav> <data.bin>\n"
    "    Encode <sound.wav> with MMDQ-encoder, output result into <data.bin>.\n"
    "    <spf>      = 1..1000 - samples-per-frame parameter\n"
    "    <bps>      = 1..16   - bits-per-sample parameter\n"
    "    <smoothon> = 0|1     - if smooth functions will be enabled or disabled\n"
    "\n"
    "  test --mmdq-decode <spf> <bps> <smoothon> <data.bin> <sound.wav>\n"
    "    Decode <data.bin> with MMDQ-decoder, output result into <sound.wav>.\n"
    "    <spf>      = 1..1000 - samples-per-frame parameter\n"
    "    <bps>      = 1..16   - bits-per-sample parameter\n"
    "    <smoothon> = 0|1     - if smooth functions will be enabled or disabled\n"
    "\n"
    "  test --g726-encode <bitrate> <sound.wav> <data.bin>\n"
    "    Encode <sound.wav> with G726-encoder, output result into <data.bin>.\n"
    "    <bitrate>  = 16|24|32|40 - G.726 bitrate parameter, kbit/sec\n"
    "\n"
    "  test --g726-decode <bitrate> <data.bin> <sound.wav>\n"
    "    Decode <data.bin> with G726-decoder, output result into <sound.wav>.\n"
    "    <bitrate>  = 16|24|32|40 - G.726 bitrate parameter, kbit/sec\n"
    "\n"
    "  test --g711-encode <law> <sound.wav> <data.bin>\n"
    "    Encode <sound.wav> with G711-encoder, output result into <data.bin>.\n"
    "    <law> = alaw|ulaw - A-law or mu-law\n"
    "\n"
    "  test --g711-decode <law> <data.bin> <sound.wav>\n"
    "    Decode <data.bin> with G711-decoder, output result into <sound.wav>.\n"
    "    <law> = alaw|ulaw - A-law or mu-law\n"
    "\n"
    "  test --mse <samples> <shift> <sound1.wav> <sound2.wav>\n"
    "    Compare <sound1.wav> and <sound2.wav> and calculate MSE (Mean Squared\n"
    "    Error). MSE will be calculated for N samples, where N is minimal length\n"
    "    of files.\n"
    "    <samples> = number of samples to compare (0-compare N samples - see above).\n"
    "    If <samples> is bigger than N, N samples will be compared.\n"
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
#define ACTION_G711_ENCODE   4
#define ACTION_G711_DECODE   5
#define ACTION_MSE           6

#define G711_ALAW            0
#define G711_ULAW            1

int main( int argc, char **argv )
{
    struct mmdq_codec_s codec;
    g726_state          g726;
    
    int          spf;
    int          bps;
    int          smoothon;
    int          action;
    int          bitrate;
    int          g711law;
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

    int16_t      x1;
    int16_t      x2;
    int16_t      maxamp1;
    int16_t      maxamp2;
    int16_t      diffx;
    int16_t      diffxmax;
    
    double       diffxn;
    double       diffxnmax;
    double       summ;
    double       summn;

    int          compare_samples;


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
    else if(argc==5 && 0==strcmp(argv[1],"--g711-encode")) {
        action   = ACTION_G711_ENCODE;
        spf      = 2;
        bps      = 1;
        smoothon = 0;
        if( 0==strcmp(argv[2],"alaw") ) {
            g711law = G711_ALAW;
        }
        else if( 0==strcmp(argv[2],"ulaw") ) {
            g711law = G711_ULAW;
        }
        else {
            printf("error: invalid g711 <law>=%s argument", argv[2]);
            goto exit_fail;
        }
        inp_wave_filename = argv[3];
        out_wave_filename = NULL;
        data_filename = argv[4];
        //go-go-go
    }
    else if(argc==5 && 0==strcmp(argv[1],"--g711-decode")) {
        action   = ACTION_G711_DECODE;
        spf      = 2;
        bps      = 1;
        smoothon = 0;
        if( 0==strcmp(argv[2],"alaw") ) {
            g711law = G711_ALAW;
        }
        else if( 0==strcmp(argv[2],"ulaw") ) {
            g711law = G711_ULAW;
        }
        else {
            printf("error: invalid g711 <law>=%s argument", argv[2]);
            goto exit_fail;
        }
        inp_wave_filename = NULL;
        data_filename = argv[3];
        out_wave_filename = argv[4];
        //go-go-go
    }
    else if(argc==5 && 0==strcmp(argv[1],"--mse")) {
        action   = ACTION_MSE;
        spf      = 2;
        bps      = 1;
        smoothon = 0;
        compare_samples = atoi(argv[2]);
        inp_wave_filename = argv[3]; //<sound1.wav>
        out_wave_filename = argv[4]; //<sound2.wav>
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

            processed ++;
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

            processed ++;
        }
        printf("%u samples has been successfully processed\n", processed);

        break;

    case ACTION_G711_ENCODE:

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
            if (g711law == G711_ALAW) {
                data[0] = linear2alaw( x[0] );
            }
            else if (g711law == G711_ULAW) {
                data[0] = linear2mulaw( x[0] );
            }
            else {
                printf("error: unsupported G.711 law=%d\n", g711law);
                goto exit_fail;
            }

            /* write encode data into file */
            err = fwrite( data, 1, 1, df ); //bytes = 1
            if(err!=1) {
                printf("error: fwrite(data) failed!\n");
                goto exit_fail;
            }

            processed ++;
        }
        printf("%u samples has been successfully processed\n", processed);

        break;

    case ACTION_G711_DECODE:

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
            if (g711law == G711_ALAW) {
                x[0] = alaw2linear( data[0] );
            }
            else if (g711law == G711_ULAW) {
                x[0] = mulaw2linear( data[0] );
            }
            else {
                printf("error: unsupported G.711 law=%d\n", g711law);
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

            processed ++;
        }
        printf("%u samples has been successfully processed\n", processed);

        break;

    case ACTION_MSE:

        /* open input wavefile 1, show file-info */
        err = wavefile_read_open( iwf, inp_wave_filename );
        if(err<0) {
            printf("error: could not open wavefile \"%s\"\n", inp_wave_filename);
            goto exit_fail;
        }
        printf("wavefile 1 info:\n");
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


        /* open input wavefile 2, show file-info */
        err = wavefile_read_open( owf, out_wave_filename );
        if(err<0) {
            printf("error: could not open wavefile \"%s\"\n", out_wave_filename);
            goto exit_fail;
        }
        printf("wavefile 2 info:\n");
        printf("  filename : %s\n", out_wave_filename);
        printf("  format   : ");
        switch( wavefile_get_wavetype( owf ) ) {
        case WAVETYPE_MONO_8000HZ_PCM16:   printf("pcm16 8000 Hz\n"); break;
        case WAVETYPE_MONO_8000HZ_PCMA:    printf("pcma 8000 Hz\n"); break;
        case WAVETYPE_MONO_8000HZ_PCMU:    printf("pcmu 8000 Hz\n"); break;
        case WAVETYPE_MONO_8000HZ_GSM610:  printf("gsm0610 8000 Hz\n"); break;
        default:
            printf("unsupported\n");
            printf("error: only 8000 hz pcm16/pcma/pcmu/gsm formats are supported\n");
            goto exit_fail;
        }
        printf("  filesize : %u bytes\n", wavefile_get_bytes  ( owf ) );
        printf("  length   : %u sec\n",   wavefile_get_seconds( owf ) );
        samples = wavefile_get_samples( owf );
        printf("  samples  : %u\n", samples );


        /* main loop */
        summ = 0.0;
        summn = 0.0;
        diffxmax = 0;
        diffxnmax = 0.0;
        processed = 0;
        maxamp1 = 0;
        maxamp2 = 0;
        while(1) {
            /* wavefile_read_voice() returns:
            *  0 = ok
            *  1 = end of file
            * -1 = error
            */
            err = wavefile_read_voice ( iwf, &x1, 1 );  /* samples=1 */
            if(err<0) {
                printf("error: could not read sample from input file 1\n");
                break;
            }
            else if(err==1) {
                break; //eof
            }

            err = wavefile_read_voice ( owf, &x2, 1 );  /* samples=1 */
            if(err<0) {
                printf("error: could not read sample from input file 2\n");
                break;
            }
            else if(err==1) {
                break; //eof
            }

            if ( abs(x1) > maxamp1 )
                maxamp1 = abs(x1);
            if ( abs(x2) > maxamp2 )
                maxamp2 = abs(x2);

            //calc diffx, summ
            diffx = x1 - x2;
            if(diffx > diffxmax)
                diffxmax = diffx;
            summ += (double)(diffx * diffx);

            diffxn = diffx/32768.0;
            if(diffxn > diffxnmax)
                diffxnmax = diffxn;
            summn += (double)(diffxn * diffxn);

            processed ++;

            //limit number of samples to compare
            if(compare_samples>0 && processed>=compare_samples) {
                printf("compare samples=%d\n", compare_samples);
                break;
            }
        }
        printf("%u samples has been successfully processed\n", processed);

        summ = summ / (double)processed;
        summn = summn / (double)processed;

        printf("Compare \"%s\" vs \"%s\" results:\n", inp_wave_filename, out_wave_filename );
        printf("samples    : %12u\n", processed);
        printf("max amp1   : %12d\n", maxamp1);
        printf("max amp2   : %12d\n", maxamp2);
        printf("max diffx  : %12d\n", diffxmax);
        printf("MSE        : %12.6f\n", summ);
        printf("n max amp1 : %12.6f\n", maxamp1/32768.0);
        printf("n max amp2 : %12.6f\n", maxamp2/32768.0);
        printf("n max diffx: %12.6f\n", diffxnmax);
        printf("n MSE      : %12.6f\n", summn);
        printf("\n");

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
