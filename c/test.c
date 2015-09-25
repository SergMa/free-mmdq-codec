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
#include <ima_adpcm.h>
#include <g72x.h>
#include <g711super.h>
#include <math.h>
#include <sys/time.h>
#include <time.h>

//------------------------------------------------------------------------------
void usage(void)
{
    char * usage_str =

    "Usage:\n"
    "\n"
    "  test --mmdq-encode <spf> <bps> <smooth> <sound.wav> <data.bin>\n"
    "    Encode <sound.wav> with MMDQ-encoder, output result into <data.bin>.\n"
    "    <spf>    = 1..1000 - samples-per-frame parameter\n"
    "    <bps>    = 1..16   - bits-per-sample parameter\n"
    "    <smooth> = 1..4    - number of smooth-tables to use\n"
    "\n"
    "  test --mmdq-decode <spf> <bps> <smooth> <data.bin> <sound.wav>\n"
    "    Decode <data.bin> with MMDQ-decoder, output result into <sound.wav>.\n"
    "    <spf>    = 1..1000 - samples-per-frame parameter\n"
    "    <bps>    = 1..16   - bits-per-sample parameter\n"
    "    <smooth> = 1..4    - number of smooth-tables to use\n"
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
    "  test --dvi4-encode <sound.wav> <data.bin>\n"
    "    Encode <sound.wav> with IMA-ADPCM-DVI4-encoder, output result into <data.bin>.\n"
    "    <law> = alaw|ulaw - A-law or mu-law\n"
    "\n"
    "  test --dvi4-decode <data.bin> <sound.wav>\n"
    "    Decode <data.bin> with IMA-ADPCM-DVI4-decoder, output result into <sound.wav>.\n"
    "    <law> = alaw|ulaw - A-law or mu-law\n"
    "\n"
    "  test --mse <samples> <sound1.wav> <sound2.wav>\n"
    "    Compare <sound1.wav> and <sound2.wav> and calculate MSE (Mean Squared\n"
    "    Error). MSE will be calculated for N samples, where N is minimal length\n"
    "    of files.\n"
    "    <samples> = number of samples to compare (0-compare N samples - see above).\n"
    "    If <samples> is bigger than N, N samples will be compared.\n"
    "\n"
    "  test --convert <sound1.wav> <format> <sound2.wav>\n"
    "    Convert <sound1.wav> into <sound2.wav> with defined <format> of wave-file.\n"
    "    Supported values of <format>:\n"
    "    pcm16    = 8000 Hz 16 bit PCM\n"
    "    pcma     = 8000 Hz 8 bit A-law PCM\n"
    "    pcmu     = 8000 Hz 8 bit mu-law PCM\n"
    "    imaadpcm = 8000 Hz IMA/DVI APCM\n"
    "    gsm      = 8000 Hz GSM 0610\n"
    "\n"
    "  test --speed\n"
    "    Speed test of MMDQ, G.726, G.711 codecs.\n"
    "\n"
    "  test --help\n"
    "    Show this help message.\n"
    "\n";

    printf(usage_str);
    return;
}

#define ACTION_MMDQ_ENCODE  0
#define ACTION_MMDQ_DECODE  1
#define ACTION_G726_ENCODE  2
#define ACTION_G726_DECODE  3
#define ACTION_G711_ENCODE  4
#define ACTION_G711_DECODE  5
#define ACTION_DVI4_ENCODE  6
#define ACTION_DVI4_DECODE  7
#define ACTION_MSE          8
#define ACTION_CONVERT      9
#define ACTION_SPEED_TEST   10

#define G711_ALAW           0
#define G711_ULAW           1

//------------------------------------------------------------------------------
//Measure time utils
unsigned long long t_before_ms;  //global variable

void start_time( void )
{
    struct timeval  tv;
    gettimeofday(&tv, NULL);
    t_before_ms = 1000*tv.tv_sec + tv.tv_usec/1000;
    return;
}

unsigned long long stop_time( void )
{
    struct timeval  tv;
    unsigned long long t_after_ms;
    gettimeofday(&tv, NULL);
    t_after_ms = 1000*tv.tv_sec + tv.tv_usec/1000;
    return (t_after_ms - t_before_ms);
}

//------------------------------------------------------------------------------
//Show wavefile info
void print_waveinfo( wavefile_t * wf )
{
    uint32_t samples;
    
    if(!wf) {
        printf("error: wf=NULL");
        return;
    }
    
    printf("wavefile info:\n");
    printf("  filename : %s\n", wf->filename);
    printf("  format   : ");
    switch( wavefile_get_wavetype( wf ) ) {
    case WAVETYPE_MONO_8000HZ_PCM16:      printf("pcm16 8000 Hz\n"); break;
    case WAVETYPE_MONO_8000HZ_PCMA:       printf("pcma 8000 Hz\n"); break;
    case WAVETYPE_MONO_8000HZ_PCMU:       printf("pcmu 8000 Hz\n"); break;
    case WAVETYPE_MONO_8000HZ_IMA_ADPCM:  printf("ima-adpcm 8000 Hz\n"); break;
    case WAVETYPE_MONO_8000HZ_GSM610:     printf("gsm0610 8000 Hz\n"); break;
    default:
        printf("unsupported\n");
        printf("error: only 8000 hz pcm16/pcma/pcmu/ima-adpcm/gsm formats are supported\n");
        return;
    }
    printf("  filesize : %u bytes\n", wavefile_get_bytes  ( wf ) );
    printf("  length   : %u sec\n",   wavefile_get_seconds( wf ) );
    samples = wavefile_get_samples( wf );
    printf("  samples  : %u\n", samples );
    return;
}

#define VOICE_BUFF_SAMPLES  (1*8000) //voicebuf[] is used for speed testing
#define VOICE_BUFF_AMP      32000
#define SPEED_TEST_SAMPLES  (3600*8000) //length of speed test voice, samples

//------------------------------------------------------------------------------
int main( int argc, char **argv )
{
    struct mmdq_codec_s codec;
    g726_state          g726;
    ima_adpcm_state_t   imaadpcm;
    
    int          spf;
    int          bps;
    int          smooth;
    int          action;
    int          bitrate;
    int          g711law;
    int          convertformat;
    char       * inp_wave_filename = NULL;
    char       * out_wave_filename = NULL;
    char       * data_filename = NULL;
    wavefile_t * iwf = NULL; // input sound file
    wavefile_t * owf = NULL; // output sound file
    FILE       * df = NULL;  // input/output data file

    int          err;
    int16_t      x[SAMPLES_PER_FRAME_MAX];
    //int16_t      y[SAMPLES_PER_FRAME_MAX];
    uint8_t      data[DATA_SIZE_MAX];
    int          wrsamples;
    int          bytes;
    uint32_t     processed;

    int16_t      x1;
    int16_t      x2;
    int16_t      diffx;
    int16_t      diffxmax;
    double       diffxn;
    double       diffxnmax;
    double       mse;

    int          compare_samples;

    unsigned long long t_ms;

    int          i;
    int          xi;
    int          voicebufi;
    int16_t      voicebuf[VOICE_BUFF_SAMPLES];


    if(argc<=0) {
        printf("error: unexpected error\n");
        exit(EXIT_SUCCESS);
    }

    /**** Get and process command options ****/
    if(argc<2 || argc>8) {
        printf("error: invalid number of arguments\n");
        usage();
        exit(EXIT_SUCCESS);
    }
    else if(argc==2 && 0==strcmp(argv[1],"--help")) {
        usage();
        exit(EXIT_SUCCESS);
    }
    else if(argc==7 && 0==strcmp(argv[1],"--mmdq-encode")) {
        action = ACTION_MMDQ_ENCODE;
        spf          = atoi(argv[2]);
        bps          = atoi(argv[3]);
        smooth     = atoi(argv[4]);
        inp_wave_filename = argv[5];
        data_filename     = argv[6];
        //go-go-go
    }
    else if(argc==7 && 0==strcmp(argv[1],"--mmdq-decode")) {
        action = ACTION_MMDQ_DECODE;
        spf          = atoi(argv[2]);
        bps          = atoi(argv[3]);
        smooth     = atoi(argv[4]);
        data_filename     = argv[5];
        out_wave_filename = argv[6];
        //go-go-go
    }
    else if(argc==5 && 0==strcmp(argv[1],"--g726-encode")) {
        action = ACTION_G726_ENCODE;
        bitrate      = atoi(argv[2]);
        inp_wave_filename = argv[3];
        data_filename     = argv[4];
        //go-go-go
    }
    else if(argc==5 && 0==strcmp(argv[1],"--g726-decode")) {
        action = ACTION_G726_DECODE;
        bitrate      = atoi(argv[2]);
        data_filename     = argv[3];
        out_wave_filename = argv[4];
        //go-go-go
    }
    else if(argc==5 && 0==strcmp(argv[1],"--g711-encode")) {
        action = ACTION_G711_ENCODE;
        if     ( 0==strcmp(argv[2],"alaw") )
            g711law = G711_ALAW;
        else if( 0==strcmp(argv[2],"ulaw") )
            g711law = G711_ULAW;
        else {
            printf("error: invalid g711 <law>=%s argument", argv[2]);
            goto exit_fail;
        }
        inp_wave_filename = argv[3];
        data_filename     = argv[4];
        //go-go-go
    }
    else if(argc==5 && 0==strcmp(argv[1],"--g711-decode")) {
        action = ACTION_G711_DECODE;
        if     ( 0==strcmp(argv[2],"alaw") )
            g711law = G711_ALAW;
        else if( 0==strcmp(argv[2],"ulaw") )
            g711law = G711_ULAW;
        else {
            printf("error: invalid g711 <law>=%s argument", argv[2]);
            goto exit_fail;
        }
        data_filename     = argv[3];
        out_wave_filename = argv[4];
        //go-go-go
    }
    else if(argc==4 && 0==strcmp(argv[1],"--dvi4-encode")) {
        action = ACTION_DVI4_ENCODE;
        inp_wave_filename = argv[2];
        data_filename     = argv[3];
        //go-go-go
    }
    else if(argc==4 && 0==strcmp(argv[1],"--dvi4-decode")) {
        action = ACTION_DVI4_DECODE;
        data_filename     = argv[2];
        out_wave_filename = argv[3];
        //go-go-go
    }
    else if(argc==5 && 0==strcmp(argv[1],"--mse")) {
        action = ACTION_MSE;
        compare_samples = atoi(argv[2]);
        inp_wave_filename    = argv[3]; //<sound1.wav>
        out_wave_filename    = argv[4]; //<sound2.wav>
        //go-go-go
    }
    else if(argc==5 && 0==strcmp(argv[1],"--convert")) {
        action = ACTION_CONVERT;
        inp_wave_filename = argv[2]; //<sound1.wav>
        if     ( 0==strcmp(argv[3],"pcm") )
            convertformat = WAVETYPE_MONO_8000HZ_PCM16;
        else if( 0==strcmp(argv[3],"pcma") )
            convertformat = WAVETYPE_MONO_8000HZ_PCMA;
        else if( 0==strcmp(argv[3],"pcmu") )
            convertformat = WAVETYPE_MONO_8000HZ_PCMU;
        else if( 0==strcmp(argv[3],"ima-adpcm") )
            convertformat = WAVETYPE_MONO_8000HZ_IMA_ADPCM;
        else if( 0==strcmp(argv[3],"gsm") )
            convertformat = WAVETYPE_MONO_8000HZ_GSM610;
        else {
            printf("error: invalid <format>=%s argument", argv[3]);
            goto exit_fail;
        }
        out_wave_filename    = argv[4]; //<sound2.wav>
        //go-go-go
    }
    else if(argc==2 && 0==strcmp(argv[1],"--speed")) {
        action = ACTION_SPEED_TEST;
        //go-go-go
    }
    else {
        printf("error: invalid number of arguments\n");
        usage();
        exit(EXIT_SUCCESS);
    }

    // initialize variables
    init_g711();
    
    // Make action
    switch(action)
    {

    case ACTION_MMDQ_ENCODE:

        // initialize variables
        err = mmdq_codec_init( &codec, 0, spf, bps, smooth, 0 ); //decoder_only=0
        if(err<0) {
            printf("error: mmdq_codec_init() failed\n");
            goto exit_fail;
        }
        iwf = wavefile_create();
        if(!iwf) {
            printf("error: wavefile_create() failed for input\n");
            goto exit_fail;
        }

        // open input wavefile
        err = wavefile_read_open( iwf, inp_wave_filename );
        if(err<0) {
            printf("error: could not open wavefile \"%s\"\n", inp_wave_filename);
            goto exit_fail;
        }
        //print_waveinfo( iwf );

        // create/open output datafile
        df = fopen(data_filename,"w");
        if(!df) {
            printf("error: could not create/open output datafile \"%s\"", data_filename);
            goto exit_fail;
        }

        // main loop
        processed = 0;
        start_time();
        while(1) {
            /* wavefile_read_voice() returns:
            *  0 = ok
            *  1 = end of file
            * -1 = error
            */
            err = wavefile_read_voice ( iwf, x, spf );  // samples=spf
            if(err<0) {
                printf("error: could not read sample from input file\n");
                break;
            }
            else if(err==1) {
                break;
            }

            // encode samples
            err = mmdq_encode( &codec, x, spf, data, sizeof(data), &bytes );
            if(err) {
                printf("error: mmdq_encode() failed!\n");
                goto exit_fail;
            }

            // write encode data into file
            err = fwrite( data, bytes, 1, df );
            if(err!=1) {
                printf("error: fwrite(data) failed!\n");
                goto exit_fail;
            }

            processed += spf;
        }
        t_ms = stop_time();
        printf("%u samples has been processed in %llu ms\n", processed, t_ms);
        break;

    case ACTION_MMDQ_DECODE:

        // initialize variables
        err = mmdq_codec_init( &codec, 0, spf, bps, smooth, 0 ); //decoder_only=0
        if(err<0) {
            printf("error: mmdq_codec_init() failed\n");
            goto exit_fail;
        }
        owf = wavefile_create();
        if(!owf) {
            printf("error: wavefile_create() failed for output\n");
            goto exit_fail;
        }

        // open input datafile
        df = fopen(data_filename,"r");
        if(!df) {
            printf("error: could not open input datafile \"%s\"\n", data_filename);
            goto exit_fail;
        }

        // open output wavefile
        err = wavefile_write_open( owf, out_wave_filename, WAVETYPE_MONO_8000HZ_PCM16 );
        if(err<0) {
            printf("error: could not create wavefile \"%s\"\n", out_wave_filename);
            goto exit_fail;
        }

        // main loop
        processed = 0;
        start_time();
        while(1) {

            //bytes = (8+8+1+(spf-1)*bps) / 8;  //TODO: zero add bits to full bytes
            bytes = mmdq_framebytes( &codec );
            
            // read encode data from file
            err = fread( data, bytes, 1, df );
            if(err!=1) {
                if(feof(df)) {
                    //end of file has been reached
                    break;
                }
                printf("error: fread(data) failed!\n");
                goto exit_fail;
            }

            // decode samples
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
        t_ms = stop_time();
        printf("%u samples has been processed in %llu ms\n", processed, t_ms);
        break;

    case ACTION_G726_ENCODE:

        g726_init_state( &g726 );
        
        iwf = wavefile_create();
        if(!iwf) {
            printf("error: wavefile_create() failed for input\n");
            goto exit_fail;
        }

        // open input wavefile, show file-info
        err = wavefile_read_open( iwf, inp_wave_filename );
        if(err<0) {
            printf("error: could not open wavefile \"%s\"\n", inp_wave_filename);
            goto exit_fail;
        }
        //print_waveinfo( iwf );

        // create/open output datafile
        df = fopen(data_filename,"w");
        if(!df) {
            printf("error: could not create/open output datafile \"%s\"", data_filename);
            goto exit_fail;
        }

        // main loop
        processed = 0;
        start_time();
        while(1) {
            /* wavefile_read_voice() returns:
            *  0 = ok
            *  1 = end of file
            * -1 = error
            */
            err = wavefile_read_voice ( iwf, x, 1 );  // samples=1
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
        t_ms = stop_time();
        printf("%u samples has been processed in %llu ms\n", processed, t_ms);
        break;

    case ACTION_G726_DECODE:

        g726_init_state( &g726 );
        
        owf = wavefile_create();
        if(!owf) {
            printf("error: wavefile_create() failed for output\n");
            goto exit_fail;
        }

        // open input datafile
        df = fopen(data_filename,"r");
        if(!df) {
            printf("error: could not open input datafile \"%s\"\n", data_filename);
            goto exit_fail;
        }

        // open output wavefile
        err = wavefile_write_open( owf, out_wave_filename, WAVETYPE_MONO_8000HZ_PCM16 );
        if(err<0) {
            printf("error: could not create wavefile \"%s\"\n", out_wave_filename);
            goto exit_fail;
        }

        // main loop
        processed = 0;
        start_time();
        while(1) {

            // read encode data from file
            err = fread( data, 1, 1, df ); //bytes=1
            if(err!=1) {
                if(feof(df)) {
                    //end of file has been reached
                    break;
                }
                printf("error: fread(data) failed!\n");
                goto exit_fail;
            }

            // decode sample
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
        t_ms = stop_time();
        printf("%u samples has been processed in %llu ms\n", processed, t_ms);
        break;

    case ACTION_G711_ENCODE:

        iwf = wavefile_create();
        if(!iwf) {
            printf("error: wavefile_create() failed for input\n");
            goto exit_fail;
        }

        // open input wavefile, show file-info
        err = wavefile_read_open( iwf, inp_wave_filename );
        if(err<0) {
            printf("error: could not open wavefile \"%s\"\n", inp_wave_filename);
            goto exit_fail;
        }
        //print_waveinfo( iwf );

        // create/open output datafile
        df = fopen(data_filename,"w");
        if(!df) {
            printf("error: could not create/open output datafile \"%s\"", data_filename);
            goto exit_fail;
        }

        // main loop
        processed = 0;
        start_time();
        while(1) {
            /* wavefile_read_voice() returns:
            *  0 = ok
            *  1 = end of file
            * -1 = error
            */
            err = wavefile_read_voice ( iwf, x, 1 );  // samples=1
            if(err<0) {
                printf("error: could not read sample from input file\n");
                break;
            }
            else if(err==1) {
                break;
            }

            // encode sample
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

            // write encode data into file
            err = fwrite( data, 1, 1, df ); //bytes = 1
            if(err!=1) {
                printf("error: fwrite(data) failed!\n");
                goto exit_fail;
            }

            processed ++;
        }
        t_ms = stop_time();
        printf("%u samples has been processed in %llu ms\n", processed, t_ms);
        break;

    case ACTION_G711_DECODE:

        owf = wavefile_create();
        if(!owf) {
            printf("error: wavefile_create() failed for output\n");
            goto exit_fail;
        }

        // open input datafile
        df = fopen(data_filename,"r");
        if(!df) {
            printf("error: could not open input datafile \"%s\"\n", data_filename);
            goto exit_fail;
        }

        // open output wavefile
        err = wavefile_write_open( owf, out_wave_filename, WAVETYPE_MONO_8000HZ_PCM16 );
        if(err<0) {
            printf("error: could not create wavefile \"%s\"\n", out_wave_filename);
            goto exit_fail;
        }

        // main loop
        processed = 0;
        start_time();
        while(1) {

            // read encode data from file
            err = fread( data, 1, 1, df ); //bytes=1
            if(err!=1) {
                if(feof(df)) {
                    //end of file has been reached
                    break;
                }
                printf("error: fread(data) failed!\n");
                goto exit_fail;
            }

            // decode sample
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
        t_ms = stop_time();
        printf("%u samples has been processed in %llu ms\n", processed, t_ms);
        break;

    case ACTION_DVI4_ENCODE:

        ima_adpcm_init( &imaadpcm, IMA_ADPCM_DVI4, 2 ); //chunksize=2 samples

        iwf = wavefile_create();
        if(!iwf) {
            printf("error: wavefile_create() failed for input\n");
            goto exit_fail;
        }

        // open input wavefile, show file-info
        err = wavefile_read_open( iwf, inp_wave_filename );
        if(err<0) {
            printf("error: could not open wavefile \"%s\"\n", inp_wave_filename);
            goto exit_fail;
        }
        //print_waveinfo( iwf );

        // create/open output datafile
        df = fopen(data_filename,"w");
        if(!df) {
            printf("error: could not create/open output datafile \"%s\"", data_filename);
            goto exit_fail;
        }

        // main loop
        processed = 0;
        start_time();
        while(1) {
            /* wavefile_read_voice() returns:
            *  0 = ok
            *  1 = end of file
            * -1 = error
            */
            err = wavefile_read_voice ( iwf, x, 2 );  // samples=2
            if(err<0) {
                printf("error: could not read sample from input file\n");
                break;
            }
            else if(err==1) {
                break;
            }

            /* encode sample. Returns: The number of bytes of IMA ADPCM data produced. */
            err = ima_adpcm_encode( &imaadpcm, data, x, 2 );

            /* write encode data into file */
            err = fwrite( data, err, 1, df ); //bytes = err
            if(err!=1) {
                printf("error: fwrite(data) failed!\n");
                goto exit_fail;
            }

            processed += 2;
        }
        t_ms = stop_time();
        printf("%u samples has been processed in %llu ms\n", processed, t_ms);
        break;

    case ACTION_DVI4_DECODE:

        ima_adpcm_init( &imaadpcm, IMA_ADPCM_DVI4, 2 ); //chunksize=2 samples
        
        owf = wavefile_create();
        if(!owf) {
            printf("error: wavefile_create() failed for output\n");
            goto exit_fail;
        }

        // open input datafile
        df = fopen(data_filename,"r");
        if(!df) {
            printf("error: could not open input datafile \"%s\"\n", data_filename);
            goto exit_fail;
        }

        // open output wavefile
        err = wavefile_write_open( owf, out_wave_filename, WAVETYPE_MONO_8000HZ_PCM16 );
        if(err<0) {
            printf("error: could not create wavefile \"%s\"\n", out_wave_filename);
            goto exit_fail;
        }

        // main loop
        processed = 0;
        start_time();
        while(1) {

            // read encode data from file
            err = fread( data, 1, 1, df ); //bytes=1
            if(err!=1) {
                if(feof(df)) {
                    //end of file has been reached
                    break;
                }
                printf("error: fread(data) failed!\n");
                goto exit_fail;
            }

            /* Decode a buffer of IMA ADPCM data to linear PCM.
               Returns the number of samples returned. */
            err = ima_adpcm_decode( &imaadpcm, x, data, 1 );  // 1 byte = 2 samples
            
           /* wavefile_write_voice() returns:
            *  0 = ok
            *  1 = end of file
            * -1 = error
            */
            err = wavefile_write_voice ( owf, x, err ); //wrsamples=err
            if(err<0) {
                printf("error: could not write sample to output wave-file\n");
                break;
            }
            else if(err==1) {
                break;
            }

            processed += 2;
        }
        t_ms = stop_time();
        printf("%u samples has been processed in %llu ms\n", processed, t_ms);
        break;

    case ACTION_MSE:

        iwf = wavefile_create();
        if(!iwf) {
            printf("error: wavefile_create() failed for file1\n");
            goto exit_fail;
        }
        owf = wavefile_create();
        if(!owf) {
            printf("error: wavefile_create() failed for file2\n");
            goto exit_fail;
        }

        // open input wavefile 1, show file-info
        err = wavefile_read_open( iwf, inp_wave_filename );
        if(err<0) {
            printf("error: could not open wavefile \"%s\"\n", inp_wave_filename);
            goto exit_fail;
        }
        //print_waveinfo( iwf );

        // open input wavefile 2, show file-info
        err = wavefile_read_open( owf, out_wave_filename );
        if(err<0) {
            printf("error: could not open wavefile \"%s\"\n", out_wave_filename);
            goto exit_fail;
        }
        //print_waveinfo( owf );

        // main loop
        diffxmax  = 0;
        diffxnmax = 0.0;
        mse       = 0.0;
        processed = 0;
        while(1) {
            /* wavefile_read_voice() returns:
            *  0 = ok
            *  1 = end of file
            * -1 = error
            */
            err = wavefile_read_voice ( iwf, &x1, 1 );  //samples=1
            if(err<0) {
                printf("error: could not read sample from input file 1\n");
                break;
            }
            else if(err==1) {
                break; //eof
            }

            err = wavefile_read_voice ( owf, &x2, 1 );  //samples=1
            if(err<0) {
                printf("error: could not read sample from input file 2\n");
                break;
            }
            else if(err==1) {
                break; //eof
            }

            //calc diffx, diffxn, mse
            diffx = abs(x1 - x2);
            if(diffx > diffxmax)
                diffxmax = diffx;

            diffxn = diffx/32768.0;
            if(diffxn > diffxnmax)
                diffxnmax = diffxn;

            mse += (double)(diffxn * diffxn);

            processed ++;

            //limit number of samples to compare
            if(compare_samples>0 && processed>=compare_samples) {
                printf("compare samples=%d\n", compare_samples);
                break;
            }
        }
        mse = mse / (double)processed;

        printf("samples: %10u, maxerr: %6d, maxrelerr: %10.8f, relMSE: %10.8f for \"%s\" vs \"%s\"\n",
                processed, diffxmax, diffxnmax, mse, inp_wave_filename, out_wave_filename );
        break;

    case ACTION_CONVERT:

        iwf = wavefile_create();
        if(!iwf) {
            printf("error: wavefile_create() failed for file1\n");
            goto exit_fail;
        }
        owf = wavefile_create();
        if(!owf) {
            printf("error: wavefile_create() failed for file2\n");
            goto exit_fail;
        }

        // open input wavefile 1, show file-info
        err = wavefile_read_open( iwf, inp_wave_filename );
        if(err<0) {
            printf("error: could not open wavefile \"%s\" in read mode\n", inp_wave_filename);
            goto exit_fail;
        }
        print_waveinfo( iwf );

        // open input wavefile 2
        err = wavefile_write_open( owf, out_wave_filename, convertformat );
        if(err<0) {
            printf("error: could not open wavefile \"%s\" in write mode\n", out_wave_filename);
            goto exit_fail;
        }

        // main loop
        processed = 0;
        while(1) {
            /* wavefile_read_voice() returns:
            *  0 = ok
            *  1 = end of file
            * -1 = error
            */
            err = wavefile_read_voice ( iwf, &x1, 1 );  //samples=1
            if(err<0) {
                printf("error: could not read sample from input file\n");
                break;
            }
            else if(err==1) {
                break; //eof
            }

            err = wavefile_write_voice ( owf, &x1, 1 );  //samples=1
            if(err<0) {
                printf("error: could not write sample into output file\n");
                break;
            }
            else if(err==1) {
                break; //eof
            }

            processed ++;
        }
        printf("%10u samples converted\n", processed );
        break;

    case ACTION_SPEED_TEST:
    
        printf("Measure speed of G.711, G.726, DVI4, MMDQ encoders/decoders\n");

        //Fill voicebuf with random numbers
        for(i=0; i<VOICE_BUFF_SAMPLES; i++) {
            voicebuf[i] = (short)VOICE_BUFF_AMP*(float)rand()/RAND_MAX;
        }

        for(smooth=1; smooth<=SMOOTH_MAX; smooth++) {
            //=======================================
            printf("MMDQ-32-%d  encode (spf=14,bps=3,smooth=%d)  ", smooth, smooth);
            spf    = 14;
            bps    = 3;
            (void) mmdq_codec_init( &codec, 0, spf, bps, smooth, 0 ); //decoder_only=0
    
            i         = 0;
            voicebufi = 0;
            xi        = 0;
            start_time();
            while(i<SPEED_TEST_SAMPLES) {
                //get input sample
                x[xi++] = voicebuf[voicebufi++];
                if(voicebufi>=VOICE_BUFF_SAMPLES)
                    voicebufi = 0;
                if(xi >= spf) {
                    (void) mmdq_encode( &codec, x, spf, data, sizeof(data), &bytes );
                    xi = 0;
                    i += spf;
                }
            }
            t_ms = stop_time();
            printf("%u samples in %8llu ms\n", SPEED_TEST_SAMPLES, t_ms);
        }

        //=======================================
        printf("MMDQ-32    decode (spf=14,bps=3)           ");
        smooth   = 4;
        spf      = 14;
        bps      = 3;
        (void) mmdq_codec_init( &codec, 0, spf, bps, smooth, 0 ); //decoder_only=0
        bytes = mmdq_framebytes( &codec );
        
        i         = 0;
        voicebufi = 0;
        xi        = 0;
        start_time();
        while(i<SPEED_TEST_SAMPLES) {
            //get input bytes
            data[xi++] = (uint8_t)voicebuf[voicebufi++];
            if(voicebufi>=VOICE_BUFF_SAMPLES)
                voicebufi = 0;
            if(xi >= bytes) {
                (void) mmdq_decode( &codec, data, bytes, x, sizeof(x), &wrsamples );
                xi = 0;
                i += spf;
            }
        }
        t_ms = stop_time();
        printf("%u samples in %8llu ms\n", SPEED_TEST_SAMPLES, t_ms);

        for(smooth=1; smooth<=SMOOTH_MAX; smooth++) {
            //=======================================
            printf("MMDQ-40-%d  encode (spf=13,bps=4,smooth=%d)  ", smooth, smooth);
            spf    = 13;
            bps    = 4;
            (void) mmdq_codec_init( &codec, 0, spf, bps, smooth, 0 ); //decoder_only=0
    
            i         = 0;
            voicebufi = 0;
            xi        = 0;
            start_time();
            while(i<SPEED_TEST_SAMPLES) {
                //get input sample
                x[xi++] = voicebuf[voicebufi++];
                if(voicebufi>=VOICE_BUFF_SAMPLES)
                    voicebufi = 0;
                if(xi >= spf) {
                    (void) mmdq_encode( &codec, x, spf, data, sizeof(data), &bytes );
                    xi = 0;
                    i += spf;
                }
            }
            t_ms = stop_time();
            printf("%u samples in %8llu ms\n", SPEED_TEST_SAMPLES, t_ms);
        }

        //=======================================
        printf("MMDQ-40    decode (spf=13,bps=4)           ");
        smooth   = 4;
        spf      = 13;
        bps      = 4;
        (void) mmdq_codec_init( &codec, 0, spf, bps, smooth, 0 ); //decoder_only=0
        bytes = mmdq_framebytes( &codec );
        
        i         = 0;
        voicebufi = 0;
        xi        = 0;
        start_time();
        while(i<SPEED_TEST_SAMPLES) {
            //get input bytes
            data[xi++] = (uint8_t)voicebuf[voicebufi++];
            if(voicebufi>=VOICE_BUFF_SAMPLES)
                voicebufi = 0;
            if(xi >= bytes) {
                (void) mmdq_decode( &codec, data, bytes, x, sizeof(x), &wrsamples );
                xi = 0;
                i += spf;
            }
        }
        t_ms = stop_time();
        printf("%u samples in %8llu ms\n", SPEED_TEST_SAMPLES, t_ms);

        for(smooth=1; smooth<=SMOOTH_MAX; smooth++) {
            //=======================================
            printf("MMDQ-40x-%d encode (spf=7,bps=3,smooth=%d)   ", smooth, smooth);
            spf    = 7;
            bps    = 3;
            (void) mmdq_codec_init( &codec, 0, spf, bps, smooth, 0 ); //decoder_only=0
    
            i         = 0;
            voicebufi = 0;
            xi        = 0;
            start_time();
            while(i<SPEED_TEST_SAMPLES) {
                //get input sample
                x[xi++] = voicebuf[voicebufi++];
                if(voicebufi>=VOICE_BUFF_SAMPLES)
                    voicebufi = 0;
                if(xi >= spf) {
                    (void) mmdq_encode( &codec, x, spf, data, sizeof(data), &bytes );
                    xi = 0;
                    i += spf;
                }
            }
            t_ms = stop_time();
            printf("%u samples in %8llu ms\n", SPEED_TEST_SAMPLES, t_ms);
        }

        //=======================================
        printf("MMDQ-40x   decode (spf=7,bps=4)            ");
        smooth   = 4;
        spf      = 7;
        bps      = 3;
        (void) mmdq_codec_init( &codec, 0, spf, bps, smooth, 0 ); //decoder_only=0
        bytes = mmdq_framebytes( &codec );
        
        i         = 0;
        voicebufi = 0;
        xi        = 0;
        start_time();
        while(i<SPEED_TEST_SAMPLES) {
            //get input bytes
            data[xi++] = (uint8_t)voicebuf[voicebufi++];
            if(voicebufi>=VOICE_BUFF_SAMPLES)
                voicebufi = 0;
            if(xi >= bytes) {
                (void) mmdq_decode( &codec, data, bytes, x, sizeof(x), &wrsamples );
                xi = 0;
                i += spf;
            }
        }
        t_ms = stop_time();
        printf("%u samples in %8llu ms\n", SPEED_TEST_SAMPLES, t_ms);

        //=======================================
        printf("DVI4       encode                          ");
        spf = 160;
        ima_adpcm_init( &imaadpcm, IMA_ADPCM_DVI4, spf ); //chunksize=spf

        i         = 0;
        voicebufi = 0;
        xi        = 0;
        start_time();
        while(i<SPEED_TEST_SAMPLES) {
            //get input sample
            x[xi++] = voicebuf[voicebufi++];
            if(voicebufi>=VOICE_BUFF_SAMPLES)
                voicebufi = 0;
            if(xi >= spf) {
                bytes = ima_adpcm_encode( &imaadpcm, data, x, spf );
                (void) mmdq_encode( &codec, x, spf, data, sizeof(data), &bytes );
                xi = 0;
                i += spf;
            }
        }
        t_ms = stop_time();
        printf("%u samples in %8llu ms\n", SPEED_TEST_SAMPLES, t_ms);

        //=======================================
        printf("DVI4       decode                          ");
        spf = 160;  //160 samples = 80 bytes
        ima_adpcm_init( &imaadpcm, IMA_ADPCM_DVI4, spf ); //chunksize=spf
        i         = 0;
        voicebufi = 0;
        xi        = 0;
        start_time();
        while(i<SPEED_TEST_SAMPLES) {
            //get input bytes
            data[xi++] = (uint8_t)voicebuf[voicebufi++];
            if(voicebufi>=VOICE_BUFF_SAMPLES)
                voicebufi = 0;
            if(xi >= 80) {
                err = ima_adpcm_decode( &imaadpcm, x, data, 80 );  //160 samples = 80 bytes
                xi = 0;
                i += spf;
            }
        }
        t_ms = stop_time();
        printf("%u samples in %8llu ms\n", SPEED_TEST_SAMPLES, t_ms);

        //=======================================
        printf("G726-32    encode                          ");
        g726_init_state( &g726 );
        i         = 0;
        voicebufi = 0;
        xi        = 0;
        start_time();
        while(i<SPEED_TEST_SAMPLES) {
            //get input sample
            x[xi++] = voicebuf[voicebufi++];
            if(voicebufi>=VOICE_BUFF_SAMPLES)
                voicebufi = 0;
            if(xi >= 1) {
                data[0] = g726_32_encoder( x[0], &g726 );
                xi = 0;
                i += 1;
            }
        }
        t_ms = stop_time();
        printf("%u samples in %8llu ms\n", SPEED_TEST_SAMPLES, t_ms);

        //=======================================
        printf("G726-32    decode                          ");
        g726_init_state( &g726 );
        i         = 0;
        voicebufi = 0;
        xi        = 0;
        start_time();
        while(i<SPEED_TEST_SAMPLES) {
            //get input bytes
            data[xi++] = (uint8_t)voicebuf[voicebufi++];
            if(voicebufi>=VOICE_BUFF_SAMPLES)
                voicebufi = 0;
            if(xi >= 1) {
                x[0] = g726_32_decoder( data[0], &g726 );
                xi = 0;
                i += 1;
            }
        }
        t_ms = stop_time();
        printf("%u samples in %8llu ms\n", SPEED_TEST_SAMPLES, t_ms);

        //=======================================
        printf("G726-40    encode                          ");
        g726_init_state( &g726 );
        i         = 0;
        voicebufi = 0;
        xi        = 0;
        start_time();
        while(i<SPEED_TEST_SAMPLES) {
            //get input sample
            x[xi++] = voicebuf[voicebufi++];
            if(voicebufi>=VOICE_BUFF_SAMPLES)
                voicebufi = 0;
            if(xi >= 1) {
                data[0] = g726_40_encoder( x[0], &g726 );
                xi = 0;
                i += 1;
            }
        }
        t_ms = stop_time();
        printf("%u samples in %8llu ms\n", SPEED_TEST_SAMPLES, t_ms);

        //=======================================
        printf("G726-40    decode                          ");
        g726_init_state( &g726 );
        i         = 0;
        voicebufi = 0;
        xi        = 0;
        start_time();
        while(i<SPEED_TEST_SAMPLES) {
            //get input bytes
            data[xi++] = (uint8_t)voicebuf[voicebufi++];
            if(voicebufi>=VOICE_BUFF_SAMPLES)
                voicebufi = 0;
            if(xi >= 1) {
                x[0] = g726_40_decoder( data[0], &g726 );
                xi = 0;
                i += 1;
            }
        }
        t_ms = stop_time();
        printf("%u samples in %8llu ms\n", SPEED_TEST_SAMPLES, t_ms);

        //=======================================
        printf("G711-alaw  encode                          ");
        i         = 0;
        voicebufi = 0;
        xi        = 0;
        start_time();
        while(i<SPEED_TEST_SAMPLES) {
            //get input sample
            x[xi++] = voicebuf[voicebufi++];
            if(voicebufi>=VOICE_BUFF_SAMPLES)
                voicebufi = 0;
            if(xi >= 1) {
                data[0] = linear2alaw( x[0] );
                xi = 0;
                i += 1;
            }
        }
        t_ms = stop_time();
        printf("%u samples in %8llu ms\n", SPEED_TEST_SAMPLES, t_ms);

        //=======================================
        printf("G711-alaw  decode                          ");
        i         = 0;
        voicebufi = 0;
        xi        = 0;
        start_time();
        while(i<SPEED_TEST_SAMPLES) {
            //get input bytes
            data[xi++] = (uint8_t)voicebuf[voicebufi++];
            if(voicebufi>=VOICE_BUFF_SAMPLES)
                voicebufi = 0;
            if(xi >= 1) {
                x[0] = alaw2linear( data[0] );
                xi = 0;
                i += 1;
            }
        }
        t_ms = stop_time();
        printf("%u samples in %8llu ms\n", SPEED_TEST_SAMPLES, t_ms);

        //=======================================
        printf("G711-mulaw encode                          ");
        i         = 0;
        voicebufi = 0;
        xi        = 0;
        start_time();
        while(i<SPEED_TEST_SAMPLES) {
            //get input sample
            x[xi++] = voicebuf[voicebufi++];
            if(voicebufi>=VOICE_BUFF_SAMPLES)
                voicebufi = 0;
            if(xi >= 1) {
                data[0] = linear2mulaw( x[0] );
                xi = 0;
                i += 1;
            }
        }
        t_ms = stop_time();
        printf("%u samples in %8llu ms\n", SPEED_TEST_SAMPLES, t_ms);

        //=======================================
        printf("G711-mulaw decode                          ");
        i         = 0;
        voicebufi = 0;
        xi        = 0;
        start_time();
        while(i<SPEED_TEST_SAMPLES) {
            //get input bytes
            data[xi++] = (uint8_t)voicebuf[voicebufi++];
            if(voicebufi>=VOICE_BUFF_SAMPLES)
                voicebufi = 0;
            if(xi >= 1) {
                x[0] = mulaw2linear( data[0] );
                xi = 0;
                i += 1;
            }
        }
        t_ms = stop_time();
        printf("%u samples in %8llu ms\n", SPEED_TEST_SAMPLES, t_ms);
        printf("speed test finished!\n");
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
