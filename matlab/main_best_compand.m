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
fid = 1; %uncomment this to use stdout instead of file
if fid==-1
    fid = 1;
    fprintf(fid,'Error: could not create results file: %s\n', RESULTS_FILENAME);
end

fprintf(fid,'MMDQ-codec test started...\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% List of global variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global FIXP;
global MAXX;
global FACTOR;
global SAMPLES_PER_FRAME;
global BITS_PER_SAMPLE;
global SMOOTH_N;
global SMOOTH_ERROR_VER;
global COM_PWR;
global EXP_PWR;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

SAMPLES = 0;          % Numbers of samples to process (if 0 - process all available samples)
%SAMPLES = 5000:7000;

FS = 8000;            % Sample (discretization) frequency, Hz
TS = 1/FS;            % Sample (discretization) period, sec
BITS = 16;            % Bits per sample in original input signal
MAXX = 2^(BITS-1);    % Maximum amplitude of original input signal (for BITS=16: AMP=32768)

USE_AUTOSCALE = 1;    % 0 - disable autoscale of input signals, 1 - enable

CODEC_VERSION = 1;    % 0-no encode/decode operations
                      % 1-matlab float point
                      % 2-c-adapted, code tables, div tables

SHOW_GRAPHICS = 0;    % 0 - disable plotting of graphics, 1 - enable it

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

%SAMPLES_PER_FRAME = 13; %40000 bit/s    (MMDQ-40)
%BITS_PER_SAMPLE   = 4;

%SAMPLES_PER_FRAME = 26; %36000 bit/s
%BITS_PER_SAMPLE   = 4;

%SAMPLES_PER_FRAME = 6; %42666 bit/s
%BITS_PER_SAMPLE   = 3;

%SAMPLES_PER_FRAME = 7; %40000 bit/s     (MMDQ-40x)
%BITS_PER_SAMPLE   = 3;

%SAMPLES_PER_FRAME = 8; %38000 bit/s
%BITS_PER_SAMPLE   = 3;

SAMPLES_PER_FRAME = 14; %32000 bit/s     (MMDQ-32)
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

SMOOTH_N = 4;
SMOOTH_ERROR_VER = 0;

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
%fflush(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load input (voice,noise) signals from wave-files, generate signal to process
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%voice_filename  = '../samples/cmu/sample1_8000.wav';         VOICE_AMP_DB = -3;
%voice_filename  = '../samples/cmu/sample2_8000.wav';         VOICE_AMP_DB = -3;
%voice_filename   = '../samples/cmu/sample3_8000.wav';         VOICE_AMP_DB = -3;  %female
%voice_filename  = '../samples/cmu/sample4_8000.wav';         VOICE_AMP_DB = -3;
%voice_filename  = '../samples/cmu/sample5_8000.wav';         VOICE_AMP_DB = -3;
%voice_filename  = '../samples/cmu/sample6_8000.wav';         VOICE_AMP_DB = -3;  %male
%voice_filename  = '../samples/cmu/sample7_8000.wav';         VOICE_AMP_DB = -3;
%voice_filename  = '../samples/modems_matlab/ask2.wav';       VOICE_AMP_DB = -3;
%voice_filename  = '../samples/modems_matlab/fsk2.wav';       VOICE_AMP_DB = -3;
%voice_filename  = '../samples/modems_matlab/psk4.wav';       VOICE_AMP_DB = -3;
%voice_filename  = '../samples/modems_matlab/psk8.wav';       VOICE_AMP_DB = -3;
%voice_filename  = '../samples/modems_matlab/qask16.wav';     VOICE_AMP_DB = -3;  %modem
%voice_filename  = '../samples/modems_matlab/qask32.wav';     VOICE_AMP_DB = -3;
%voice_filename  = '../samples/modems_matlab/qask64.wav';     VOICE_AMP_DB = -3;
voice_filename  = '../samples/various.wav';                  VOICE_AMP_DB = -3;  %male+female+modem

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


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % INTRO ITERATION LOOP INITIALIZATION
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    ITERATIONS_INIT = 1000;                    % 1st stage: monte-carlo method (0 - disable this stage)
    ITERATIONS_MAX  = ITERATIONS_INIT + 200;  % 2nd stage: gradient method

    MAX_PWR = 3;
    MIN_PWR = 0.3;

    STEPSIZE       = 0.005; %set initial (biggest) value of stepsize here
    STEPSIZE_DEC   = 0.7;   %stepsize decrement coefficient: 0..1
    STEP_CNTR_MAX  = 10;    %if no changes on STEP_CNTR_MAX - decrease STEPSIZE

    % Initial values

    COM_PWR = ones(1,SMOOTH_N);
    EXP_PWR = ones(1,SMOOTH_N);

    %COM_PWR = [1.0  1.10  1.20  1.20];
    %EXP_PWR = [1.0  1.10  1.20  1.20];

    BEST_COM_PWR = COM_PWR;
    BEST_EXP_PWR = EXP_PWR;

    best_max_nerry = 0;
    best_mse_nerry = 0;

    mse_nerry = 0;
    max_nerry = 0;

    step_cntr = 0;
    iter = 1;

    max_x = max( abs(x) );

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % SMALL ITERATION LOOP (BEGIN)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    while iter <= ITERATIONS_MAX

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Initialization

            % Create decoder and encoder structures
            switch CODEC_VERSION
            case 0
                enc = [];
                dec = [];
            case 1
                enc = []; 
                dec = []; 
            case 2
                enc = encoder2_init;
                dec = decoder2_init;
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
                    [enc_data,enc] = encoder2(enc_voice,enc,dec);
                end

                % decode data frame to voice
                switch CODEC_VERSION
                case 0
                    dec_voice = enc_data(4:end);
                case 1
                    [dec_voice,dec] = decoder(enc_data,dec);
                case 2
                    [dec_voice,dec] = decoder2(enc_data,dec);
                end

                %scale back, output voice
                y(i:i+SAMPLES_PER_FRAME-1) = fix( dec_voice );

                i = i + SAMPLES_PER_FRAME;
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Make error estimates

            % Calculate and print errors values
            nerry = (x - y)/max_x;
            max_nerry = max( abs(nerry) );
            mse_nerry = mean(nerry.*nerry);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        if (iter > 1) && (mse_nerry < best_mse_nerry) && isfinite(mse_nerry)
            %current step has better params
            best_mse_nerry = mse_nerry;
            best_max_nerry = max_nerry;

            BEST_COM_PWR = COM_PWR;
            BEST_EXP_PWR = EXP_PWR;

            step_cntr = 0;
        else
            if (iter==1)
                best_mse_nerry = mse_nerry;
                best_max_nerry = max_nerry;
            else
                if iter > ITERATIONS_INIT
                    %current step has worse params
                    step_cntr = step_cntr + 1;
                    if step_cntr > STEP_CNTR_MAX
                        step_cntr = 0;
                        STEPSIZE = STEPSIZE * STEPSIZE_DEC;
                        fprintf(fid,'decrement STEPSIZE to %12.8f\n',STEPSIZE);
                    end
                end
            end
        end

        %make little changes of params
        if iter <= ITERATIONS_INIT
            COM_PWR = MAX_PWR*rand(size(COM_PWR));
            %EXP_PWR = MAX_PWR*rand(size(EXP_PWR));
            EXP_PWR = COM_PWR;
        else
            COM_PWR = BEST_COM_PWR + STEPSIZE*randn(size(COM_PWR));
            %EXP_PWR = BEST_EXP_PWR + STEPSIZE*randn(size(EXP_PWR));
            EXP_PWR = COM_PWR;
        end

        %check validity of COM_PWR, EXP_PWR
        COM_PWR = min( COM_PWR, MAX_PWR );
        COM_PWR = max( COM_PWR, MIN_PWR );

        EXP_PWR = min( EXP_PWR, MAX_PWR );
        EXP_PWR = max( EXP_PWR, MIN_PWR );

        %print errors
        fprintf(fid,'\n');
        fprintf(fid,'iter=%d\n', iter);
       %fprintf(fid,'      max nerrory=%12.8f\n',max_nerry);
        fprintf(fid,'      mse nerrory=%12.8f\n',mse_nerry);
        fprintf(fid,'best  mse nerrory=%12.8f\n',best_mse_nerry);
        %fflush(fid);
        
        iter = iter + 1;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % SMALL ITERATION LOOP (END)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf(fid,'process finished!\n');

fprintf(fid,'iterations=%d\n', iter-1);
fprintf(fid,'x,y normalized errors:\n');
fprintf(fid,'  best mse nerrory=%12.8f\n',best_mse_nerry);
fprintf(fid,'       max nerrory=%12.8f\n',best_max_nerry);
fprintf(fid,'           COM_PWR=%6.4f\n',BEST_COM_PWR);
fprintf(fid,'           EXP_PWR=%6.4f\n',BEST_EXP_PWR);
%fflush(fid);

if fid~=1
    fclose(fid);
end

disp('finished!');
