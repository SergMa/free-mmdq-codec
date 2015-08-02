%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test script to find best compand/expand functions for MMDQ-codec             %
% main_best_compand.m                                                          %
%                                                                              %
% (c) Sergei Mashkin, 2015                                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
clear all;
close all;

disp('finding best compand/expand started!');

RESULTS_FILENAME = 'out/results.txt';
%fid = fopen(RESULTS_FILENAME,'w');
fid = 1;
if fid==-1
    fid = 1;
    fprintf(fid,'Error: could not create results file: %s\n', RESULTS_FILENAME);
end

fprintf(fid,'MMDQ-codec test started...\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

SAMPLES = 0;         % Numbers of samples to process (if 0 - process all available samples)
SAMPLES = 1:5000;

FS = 8000;            % Sample (discretization) frequency, Hz
TS = 1/FS;            % Sample (discretization) period, sec
BITS = 16;            % Bits per sample in original input signal
MAXX = 2^(BITS-1);    % Maximum amplitude of original input signal (for BITS=16: AMP=32768)

USE_AUTOSCALE = 1;    % 0 - disable autoscale of input signals, 1 - enable

CODEC_VERSION = 1;    % 0-no encode/decode operations
                      % 1-matlab float point
                      % 2-c-adapted, code tables, div tables

SHOW_GRAPHICS = 1;    % 0 - disable plotting of graphics, 1 - enable it

SPECTROGRAM_WIDTH = 256; % Parameters of spectrograms
SPECTROGRAM_OVR   = 8;

INPUT_FILENAME    = 'out/input.wav'; % Name of file for input signal
OUTPUT_FILENAME_0 = 'out/out0.wav';  % Name of file for output signal for codec version 0
OUTPUT_FILENAME_1 = 'out/out1.wav';  % Name of file for output signal for codec version 1
OUTPUT_FILENAME_2 = 'out/out2.wav';  % Name of file for output signal for codec version 2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Codec settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%SAMPLES_PER_FRAME = 10; %42400 bit/s
%BITS_PER_SAMPLE   = 4;

%SAMPLES_PER_FRAME = 13; %40000 bit/s
%BITS_PER_SAMPLE   = 4;

%SAMPLES_PER_FRAME = 26; %36000 bit/s
%BITS_PER_SAMPLE   = 4;

%SAMPLES_PER_FRAME = 6; %42666 bit/s
%BITS_PER_SAMPLE   = 3;

%SAMPLES_PER_FRAME = 7; %40000 bit/s      (*)
%BITS_PER_SAMPLE   = 3;

%SAMPLES_PER_FRAME = 8; %38000 bit/s
%BITS_PER_SAMPLE   = 3;

SAMPLES_PER_FRAME = 14; %32000 bit/s     (*)
BITS_PER_SAMPLE   = 3;

%SAMPLES_PER_FRAME = 32; %27500 bit/s
%BITS_PER_SAMPLE   = 3;

%SAMPLES_PER_FRAME = 5; %40000 bit/s
%BITS_PER_SAMPLE   = 2;

%SAMPLES_PER_FRAME = 6; %36000 bit/s
%BITS_PER_SAMPLE   = 2;

%SAMPLES_PER_FRAME = 7; %33142 bit/s
%BITS_PER_SAMPLE   = 2;

%SAMPLES_PER_FRAME = 8; %31000 bit/s
%BITS_PER_SAMPLE   = 2;

%SAMPLES_PER_FRAME = 10; %28000 bit/s
%BITS_PER_SAMPLE   = 2;

%SAMPLES_PER_FRAME = 12; %26000 bit/s
%BITS_PER_SAMPLE   = 2;

%SAMPLES_PER_FRAME = 15; %24000 bit/s
%BITS_PER_SAMPLE   = 2;

%SAMPLES_PER_FRAME = 20; %22000 bit/s
%BITS_PER_SAMPLE   = 2;

%SAMPLES_PER_FRAME = 30; %20000 bit/s
%BITS_PER_SAMPLE   = 2;


FACTOR = 2^BITS_PER_SAMPLE;
FIXP = 32768*2;

% encoded frame data format:
% 8 bits   = min/max value (we will store A-law code here)
% 8 bits   = max/min value (we will store A-law code here)
% 1 bit    = smooth1 bit
% S*B bits = S=(SAMPLES_PER_FRAME-1), B=BITS_PER_SAMPLE - differences codes

COMPRESSION = (SAMPLES_PER_FRAME * 8) / ( 8 + 8 + 1 + (SAMPLES_PER_FRAME-1)*BITS_PER_SAMPLE);
BITRATE = 64000 / COMPRESSION;

% Print codec settings
fprintf(fid,'test of mycodec started...\n');
fprintf(fid,'-----------------------\n');
fprintf(fid,'bits             : %d\n', BITS);
fprintf(fid,'maxx             : %d\n', MAXX);
fprintf(fid,'-----------------------\n');
fprintf(fid,'codec version    : %d\n', CODEC_VERSION);
fprintf(fid,'samles per frame : %d\n', SAMPLES_PER_FRAME);
fprintf(fid,'bits per sample  : %d\n', BITS_PER_SAMPLE);
fprintf(fid,'factor           : %d\n', FACTOR);
fprintf(fid,'compression      : %f\n', COMPRESSION);
fprintf(fid,'bitrate, bit/s   : %d\n', BITRATE);
fprintf(fid,'-----------------------\n');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load input (voice,noise) signals from wave-files, generate signal to process
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%voice_filename  = '../samples/cmu/sample1_8000.wav';         VOICE_AMP_DB = -3;
%voice_filename  = '../samples/cmu/sample2_8000.wav';         VOICE_AMP_DB = -3;
%voice_filename  = '../samples/cmu/sample3_8000.wav';         VOICE_AMP_DB = -3;  %female
%voice_filename  = '../samples/cmu/sample4_8000.wav';         VOICE_AMP_DB = -3;
%voice_filename  = '../samples/cmu/sample5_8000.wav';         VOICE_AMP_DB = -3;
%voice_filename  = '../samples/cmu/sample6_8000.wav';          VOICE_AMP_DB = -3;  %male
%voice_filename  = '../samples/cmu/sample7_8000.wav';         VOICE_AMP_DB = -3;
%voice_filename  = '../samples/modems_matlab/ask2.wav';       VOICE_AMP_DB = -3;
%voice_filename  = '../samples/modems_matlab/fsk2.wav';       VOICE_AMP_DB = -3;
%voice_filename  = '../samples/modems_matlab/psk4.wav';       VOICE_AMP_DB = -3;
%voice_filename  = '../samples/modems_matlab/psk8.wav';       VOICE_AMP_DB = -3;
%voice_filename   = '../samples/modems_matlab/qask16.wav';     VOICE_AMP_DB = -3;  %modem
%voice_filename  = '../samples/modems_matlab/qask32.wav';     VOICE_AMP_DB = -3;
%voice_filename  = '../samples/modems_matlab/qask64.wav';     VOICE_AMP_DB = -3;
voice_filename  = '../samples/various.wav';                   VOICE_AMP_DB = -3;  %male+female+modem

%noise_filename  = '../samples/noise/noise_white.wav';        NOISE_AMP_DB = -99;
%noise_filename  = '../samples/noise/noise_pink.wav';         NOISE_AMP_DB = -99;
%noise_filename  = '../samples/noise/noise_brown.wav';        NOISE_AMP_DB = -99;
noise_filename   = '../samples/noise/noise_badbearing.wav';   NOISE_AMP_DB = -99;
%noise_filename  = '../samples/noise/noise_diesel.wav';       NOISE_AMP_DB = -99;  %
%noise_filename  = '../samples/noise/noise_lacetti.wav';      NOISE_AMP_DB = -99;
%noise_filename  = '../samples/noise/noise_lacetti2.wav';     NOISE_AMP_DB = -99;
%noise_filename  = '../samples/noise/noise_tractor.wav';      NOISE_AMP_DB = -99;
%noise_filename  = '../samples/noise/noise_yamzdiesel.wav';   NOISE_AMP_DB = -99;

[x_voice,ffs_voice,bits_voice] = wavread(voice_filename);
if ffs_voice~=FS
    error('invalid sample frequency of input voice wavefile');
end

[x_noise,ffs_noise,bits_noise] = wavread(noise_filename);
if ffs_noise~=FS
    error('invalid sample frequency of input noise wavefile');
end

% Make horizontal vectors. If wavefiles are stereo, use only the first channels
% now x_voice, x_noise have range [-1..+1]
x_voice = x_voice(:,1).';
x_voice = fix(x_voice * MAXX);
N_voice = size(x_voice,2);

% Limit lenght of signal, if needed.
if size(SAMPLES,2) > 1
    x_voice = x_voice(SAMPLES);
    N_voice = size(x_voice,2);
end

x_noise = x_noise(:,1).';
x_noise = fix(x_noise * MAXX);
N_noise = size(x_noise,2);

% Normalize power of signals, if needed
if USE_AUTOSCALE==1
    x_voice = fix( autoscale(x_voice, MAXX) );
    x_noise = fix( autoscale(x_noise, MAXX) );
end

% Add noise to voice
x = fix( mixer( x_voice, VOICE_AMP_DB, x_noise, NOISE_AMP_DB ) );
N = length(x);

% Convert sample numbers into time ticks (we will use this for plotting)
t = (1:N)/FS;

% Save input signal into input wavefile
wavwrite( (x/MAXX).', FS, bits_voice, INPUT_FILENAME );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BIG ITERATION LOOP INITIALIZATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ITERATIONS = 100;

MIN_COM_PWR0 = 0.1;
MIN_COM_PWR1 = 0.1;
MIN_COM_PWR2 = 0.1;
MIN_COM_PWR3 = 0.1;

MAX_COM_PWR0 = 10;
MAX_COM_PWR1 = 10;
MAX_COM_PWR2 = 10;
MAX_COM_PWR3 = 10;

MIN_EXP_PWR0 = 0.1;
MIN_EXP_PWR1 = 0.1;
MIN_EXP_PWR2 = 0.1;
MIN_EXP_PWR3 = 0.1;

MAX_EXP_PWR0 = 10;
MAX_EXP_PWR1 = 10;
MAX_EXP_PWR2 = 10;
MAX_EXP_PWR3 = 10;

global COM_PWR0 COM_PWR1 COM_PWR2 COM_PWR3;
global EXP_PWR0 EXP_PWR1 EXP_PWR2 EXP_PWR3;

super_best_max_nerry = 0;
super_best_mse_nerry = 0;

SUPER_BEST_COM_PWR0 = 0;
SUPER_BEST_COM_PWR1 = 0;
SUPER_BEST_COM_PWR2 = 0;
SUPER_BEST_COM_PWR3 = 0;

SUPER_BEST_COM_PWR0 = 0;
SUPER_BEST_COM_PWR1 = 0;
SUPER_BEST_COM_PWR2 = 0;
SUPER_BEST_COM_PWR3 = 0;


bigiter = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BIG ITERATION LOOP (BEGIN)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
while bigiter <= BIG_ITERATIONS

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % INTRO ITERATION LOOP INITIALIZATION
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Initial values
    COM_PWR0 = my_rand( MIN_COM_PWR0, MAX_COM_PWR0 );
    COM_PWR1 = my_rand( MIN_COM_PWR1, MAX_COM_PWR1 );
    COM_PWR2 = my_rand( MIN_COM_PWR2, MAX_COM_PWR2 );
    COM_PWR3 = my_rand( MIN_COM_PWR3, MAX_COM_PWR3 );

    EXP_PWR0 = my_rand( MIN_EXP_PWR0, MAX_EXP_PWR0 );
    EXP_PWR1 = my_rand( MIN_EXP_PWR1, MAX_EXP_PWR1 );
    EXP_PWR2 = my_rand( MIN_EXP_PWR2, MAX_EXP_PWR2 );
    EXP_PWR3 = my_rand( MIN_EXP_PWR3, MAX_EXP_PWR3 );

    mse_nerry = 0;

    BEST_COM_PWR0 = COM_PWR0;
    BEST_COM_PWR1 = COM_PWR1;
    BEST_COM_PWR2 = COM_PWR2;
    BEST_COM_PWR3 = COM_PWR3;

    BEST_EXP_PWR0 = EXP_PWR0;
    BEST_EXP_PWR1 = EXP_PWR1;
    BEST_EXP_PWR2 = EXP_PWR2;
    BEST_EXP_PWR3 = EXP_PWR3;

    best_max_nerry = 0;
    best_mse_nerry = 0;

    ITERATIONS = 300;

    step_cntr     = 0;
    STEP_CNTR_MAX = 10;   %if no changes on STEP_CNTR_MAX - decrease STEPSIZE
    STEPSIZE      = 3;    %set initial (biggest) value of stepsize here
    STEPSIZE_DEC  = 0.5;  %stepsize decrement coefficient: 0..1

    iter = 1;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % SMALL ITERATION LOOP (BEGIN)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    while iter <= ITERATIONS

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Initialization

            % Create decoder and encoder structures
            switch CODEC_VERSION
            case 0
                enc = [];
                dec = [];
            case 1
                enc = encoder_init ( SAMPLES_PER_FRAME, BITS_PER_SAMPLE, MAXX );
                dec = decoder_init ( SAMPLES_PER_FRAME, BITS_PER_SAMPLE, MAXX );
            case 2
                enc = encoder2_init( SAMPLES_PER_FRAME, BITS_PER_SAMPLE, MAXX, FIXP );
                dec = decoder2_init( SAMPLES_PER_FRAME, BITS_PER_SAMPLE, MAXX, FIXP );
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Main processing loop

            % now we have x,t

            frame_pos = 1;
            frame_vinp = zeros(1,SAMPLES_PER_FRAME);
            frame_vout = zeros(1,SAMPLES_PER_FRAME);

            y = zeros(1,N); %output voice

            i = 1;
            while i<=N-SAMPLES_PER_FRAME+1

                % scale input, get enc_voice[] buffer
                enc_voice = x(i:i+SAMPLES_PER_FRAME-1);
                enc_voice = my_clip( enc_voice, MAXX );

                % encode frame
                switch CODEC_VERSION
                case 0
                    enc_data = [ 0, 0, 0, enc_voice ];
                case 1
                    [enc_data,enc] = encoder(enc_voice,enc,dec);
                case 2
                    [enc_data,enc] = encoder2(enc_voice,enc,dec,FIXP);
                end

                % decode data frame to voice
                switch CODEC_VERSION
                case 0
                    dec_voice = enc_data(4:end);
                case 1
                    [dec_voice,dec] = decoder(enc_data,dec);
                case 2
                    [dec_voice,dec] = decoder2(enc_data,dec,FIXP);
                end

                %scale back, output voice
                y(i:i+SAMPLES_PER_FRAME-1) = fix( dec_voice );

                i = i + SAMPLES_PER_FRAME;
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Make error estimates

            % Calculate and print errors values
            nerry = (x - y)/MAXX;
            max_nerry = max( abs(nerry) );
            mse_nerry = mean(nerry.^2);

            fprintf(fid,'\n');
            fprintf(fid,'iter=%d\n', iter);
            fprintf(fid,'x,y normalized errors:\n');
            fprintf(fid,'  max nerrory=%12.8f\n',max_nerry);
            fprintf(fid,'  mse nerrory=%12.8f\n',mse_nerry);


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        if (iter > 1) && (mse_nerry < best_mse_nerry) && isfinite(mse_nerry)
            %previous step had better params
            best_mse_nerry = mse_nerry;
            best_max_nerry = max_nerry;

            BEST_COM_PWR0 = COM_PWR0;
            BEST_COM_PWR1 = COM_PWR1;
            BEST_COM_PWR2 = COM_PWR2;
            BEST_COM_PWR3 = COM_PWR3;

            BEST_EXP_PWR0 = EXP_PWR0;
            BEST_EXP_PWR1 = EXP_PWR1;
            BEST_EXP_PWR2 = EXP_PWR2;
            BEST_EXP_PWR3 = EXP_PWR3;

            step_cntr = 0;
            fprintf(fid,'refresh best_mse_nerry=%12.8f\n',best_mse_nerry);
        else
            if (iter==1)
                best_mse_nerry = mse_nerry;
                best_max_nerry = max_nerry;
            else
                %previous step had worse params
                step_cntr = step_cntr + 1;
                if step_cntr > STEP_CNTR_MAX
                    step_cntr = 0;
                    STEPSIZE = STEPSIZE * STEPSIZE_DEC;
                    fprintf(fid,'decrement STEPSIZE to %12.8f\n',STEPSIZE);
                end
            end
        end

        %make little changes of params
        COM_PWR0 = abs( BEST_COM_PWR0 + STEPSIZE*randn(1) );
        COM_PWR1 = abs( BEST_COM_PWR1 + STEPSIZE*randn(1) );
        COM_PWR2 = abs( BEST_COM_PWR2 + STEPSIZE*randn(1) );
        COM_PWR3 = abs( BEST_COM_PWR3 + STEPSIZE*randn(1) );

        EXP_PWR0 = COM_PWR0; %abs( BEST_EXP_PWR0 + STEPSIZE*randn(1) );
        EXP_PWR1 = COM_PWR1; %abs( BEST_EXP_PWR1 + STEPSIZE*randn(1) );
        EXP_PWR2 = COM_PWR2; %abs( BEST_EXP_PWR2 + STEPSIZE*randn(1) );
        EXP_PWR3 = COM_PWR3; %abs( BEST_EXP_PWR3 + STEPSIZE*randn(1) );

        iter = iter + 1;

    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % SMALL ITERATION LOOP (END)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if()

    bigiter = bigiter + 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BIG ITERATION LOOP (END)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


fprintf(fid,'process finished!\n');

fprintf(fid,'iterations=%d\n', iter-1);
fprintf(fid,'x,y normalized errors:\n');
fprintf(fid,'  best mse nerrory=%12.8f\n',best_mse_nerry);
fprintf(fid,'       max nerrory=%12.8f\n',best_max_nerry);
fprintf(fid,'          COM_PWR0=%12.8f\n',BEST_COM_PWR0);
fprintf(fid,'          COM_PWR1=%12.8f\n',BEST_COM_PWR1);
fprintf(fid,'          COM_PWR2=%12.8f\n',BEST_COM_PWR2);
fprintf(fid,'          COM_PWR3=%12.8f\n',BEST_COM_PWR3);
fprintf(fid,'          EXP_PWR0=%12.8f\n',BEST_EXP_PWR0);
fprintf(fid,'          EXP_PWR1=%12.8f\n',BEST_EXP_PWR1);
fprintf(fid,'          EXP_PWR2=%12.8f\n',BEST_EXP_PWR2);
fprintf(fid,'          EXP_PWR3=%12.8f\n',BEST_EXP_PWR3);

if fid~=1
    fclose(fid);
end

disp('finished!');
