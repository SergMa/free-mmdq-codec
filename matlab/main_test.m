%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test script to check and demonstrate work of MMDQ-codec                      %
% main_test.m                                                                  %
%                                                                              %
% (c) Sergei Mashkin, 2015                                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
clear all;
close all;
disp('MMDQ-codec test started...');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

SAMPLES = 0;         % Numbers of samples to process (if 0 - process all available samples)
%SAMPLES = 1:10000;
%SAMPLES = 1400:2000;

FS = 8000;            % Sample (discretization) frequency, Hz
TS = 1/FS;            % Sample (discretization) period, sec
BITS = 16;            % Bits per sample in original input signal
AMP = 2^(BITS-1)-1;   % Maximum amplitude of original input signal (for BITS=16: AMP=32767)

USE_AUTOSCALE = 1;    % 0 - disable autoscale of input signals, 1 - enable

CODEC_VERSION = 2;    % 0-no encode/decode operations
                      % 1-matlab float point
                      % 2-c-adapted, code tables, div tables

SHOW_GRAPHICS = 1;    % 0 - disable plotting of graphics, 1 - enable it

SPECTROGRAM_WIDTH = 256; % Parameters of spectrograms
SPECTROGRAM_OVR   = 8;

INPUT_FILENAME    = './input.wav'; % Name of file for input signal
OUTPUT_FILENAME_0 = './out0.wav';  % Name of file for output signal for codec version 0
OUTPUT_FILENAME_1 = './out1.wav';  % Name of file for output signal for codec version 1
OUTPUT_FILENAME_2 = './out2.wav';  % Name of file for output signal for codec version 2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Codec settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%SAMPLES_PER_FRAME = 13; %40000 bit/s
%BITS_PER_SAMPLE   = 4;

SAMPLES_PER_FRAME = 6; %42666.(6) bit/s
BITS_PER_SAMPLE   = 3;

%SAMPLES_PER_FRAME = 7; %40000 bit/s
%BITS_PER_SAMPLE   = 3;

%SAMPLES_PER_FRAME = 8; %38000 bit/s
%BITS_PER_SAMPLE   = 3;

%SAMPLES_PER_FRAME = 10; %35200 bit/s
%BITS_PER_SAMPLE   = 3;

%SAMPLES_PER_FRAME = 14; %32000 bit/s
%BITS_PER_SAMPLE   = 3;

%SAMPLES_PER_FRAME = 15; %24000 bit/s
%BITS_PER_SAMPLE   = 2;

%SAMPLES_PER_FRAME = 20; %22000 bit/s
%BITS_PER_SAMPLE   = 2;

BITS_INPUT_SIGNAL = 16;
MAXX = (2^BITS_INPUT_SIGNAL)/2-1;
FACTOR = 2^BITS_PER_SAMPLE;

% encoded frame data format:
% 8 bits   = min/max value (we will store A-law or u-law code here)
% 8 bits   = max/min value (we will store A-law or u-law code here)
% 1 bit    = smooth1 bit
% S*B bits = S=(SAMPLES_PER_FRAME-1), B=BITS_PER_SAMPLE - differences codes

COMPRESSION = (SAMPLES_PER_FRAME * 8) / ( 8 + 8 + 1 + (SAMPLES_PER_FRAME-1)*BITS_PER_SAMPLE);
BITRATE = 64000 / COMPRESSION;

% Print codec settings
fprintf(1,'test of mycodec started...\n');
fprintf(1,'-----------------------\n');
fprintf(1,'codec version    : %d\n', CODEC_VERSION);
fprintf(1,'bits             : %d\n', BITS);
fprintf(1,'amp              : %d\n', AMP);
fprintf(1,'bits input signal: %d\n', BITS_INPUT_SIGNAL);
fprintf(1,'maxx             : %d\n', MAXX);
fprintf(1,'-----------------------\n');
fprintf(1,'samles per frame : %d\n', SAMPLES_PER_FRAME);
fprintf(1,'bits per sample  : %d\n', BITS_PER_SAMPLE);
fprintf(1,'factor           : %d\n', FACTOR);
fprintf(1,'compression      : %f\n', COMPRESSION);
fprintf(1,'bitrate, bit/s   : %i\n', BITRATE);
fprintf(1,'maxx             : %i\n', MAXX);
fprintf(1,'-----------------------\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load input (voice,noise) signals from wave-files, generate signal to process
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%voice_filename  = '../samples/cmu/sample1_8000.wav';         VOICE_AMP_DB = 0;
%voice_filename  = '../samples/cmu/sample2_8000.wav';         VOICE_AMP_DB = 0;
voice_filename   = '../samples/cmu/sample3_8000.wav';         VOICE_AMP_DB = 0;  %female
%voice_filename  = '../samples/cmu/sample4_8000.wav';         VOICE_AMP_DB = 0;
%voice_filename  = '../samples/cmu/sample5_8000.wav';         VOICE_AMP_DB = -6;
%voice_filename  = '../samples/cmu/sample6_8000.wav';         VOICE_AMP_DB = 0;
%voice_filename  = '../samples/cmu/sample7_8000.wav';         VOICE_AMP_DB = 0;
%voice_filename  = '../samples/modems/v92-mohdenied.wav';     VOICE_AMP_DB = 0;
%voice_filename  = '../samples/modems/v90-rockwellconex.wav'; VOICE_AMP_DB = 0;
%voice_filename  = '../samples/modems/v34-33600bps.wav';      VOICE_AMP_DB = 0;
%voice_filename  = '../samples/modems/v32b-14400bps.wav';     VOICE_AMP_DB = 0;
%voice_filename  = '../samples/modems/v22b-2400bps.wav';      VOICE_AMP_DB = 0;
%voice_filename  = '../samples/modems/v21-300bps.wav';        VOICE_AMP_DB = 0;
%voice_filename  = '../samples/modems/v17-14400bpsfax.wav';   VOICE_AMP_DB = 0;
%voice_filename  = '../samples/modems/ttytdd.wav';            VOICE_AMP_DB = 0;

%noise_filename  = '../samples/noise/noise_white.wav';        NOISE_AMP_DB = -12;
%noise_filename  = '../samples/noise/noise_pink.wav';         NOISE_AMP_DB = -12;
%noise_filename  = '../samples/noise/noise_brown.wav';        NOISE_AMP_DB = -12;
noise_filename   = '../samples/noise/noise_badbearing.wav';   NOISE_AMP_DB = -99;
%noise_filename  = '../samples/noise/noise_diesel.wav';       NOISE_AMP_DB = -99;  %
%noise_filename  = '../samples/noise/noise_lacetti.wav';      NOISE_AMP_DB = -12;
%noise_filename  = '../samples/noise/noise_lacetti2.wav';     NOISE_AMP_DB = -12;
%noise_filename  = '../samples/noise/noise_tractor.wav';      NOISE_AMP_DB = -12;
%noise_filename  = '../samples/noise/noise_yamzdiesel.wav';   NOISE_AMP_DB = -12;

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
x_voice = fix(x_voice * AMP);
N_voice = size(x_voice,2);

% Limit lenght of signal, if needed.
if size(SAMPLES,2) > 1
    x_voice = x_voice(SAMPLES);
    N_voice = size(x_voice,2);
end

x_noise = x_noise(:,1).';
x_noise = fix(x_noise * AMP);
N_noise = size(x_noise,2);

% Normalize power of signals, if needed
if USE_AUTOSCALE==1
    x_voice = fix( autoscale(x_voice, AMP) );
    x_noise = fix( autoscale(x_noise, AMP) );
end

% Add noise to voice
x = fix( mixer( x_voice, VOICE_AMP_DB, x_noise, NOISE_AMP_DB ) );
N = length(x);

% Convert sample numbers into time ticks (we will use this for plotting)
t = (1:N)/FS;

% Save input signal into input wavefile
wavwrite( (x/AMP).',FS,bits_voice,INPUT_FILENAME);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create decoder and encoder structures
switch CODEC_VERSION
case 0
    enc = [];
    dec = [];
case 1
    enc = encoder_init ( SAMPLES_PER_FRAME, BITS_PER_SAMPLE, MAXX );
    dec = decoder_init ( SAMPLES_PER_FRAME, BITS_PER_SAMPLE, MAXX );
case 2
    enc = encoder2_init( SAMPLES_PER_FRAME, BITS_PER_SAMPLE, MAXX );
    dec = decoder2_init( SAMPLES_PER_FRAME, BITS_PER_SAMPLE, MAXX );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main processing loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% now we have x,t

frame_pos = 1;
frame_vinp = zeros(1,SAMPLES_PER_FRAME);
frame_vout = zeros(1,SAMPLES_PER_FRAME);

ttt_vinp = zeros(1,N);
ttt_vout = zeros(1,N);
y = zeros(1,N); %output voice

smooth0_N = 0;
smooth1_N = 0;
smooth2_N = 0;
smooth3_N = 0;

for i=1:N

    % scale input, put input into frame-buffer
    vinp = fix( MAXX*x(i)/AMP );
    if vinp>MAXX
        vinp = MAXX;
    elseif vinp<-MAXX
        vinp = -MAXX;
    end
    frame_vinp( frame_pos ) = vinp;

    % get output from frame-buffer, scale it
    vout = frame_vout( frame_pos );
    y(i) = fix( AMP*vout/MAXX );

    % process samples
    frame_pos = frame_pos + 1;
    if frame_pos > SAMPLES_PER_FRAME
        frame_pos = 1;

        % voice frame is ready, encode it to data
        switch CODEC_VERSION
        case 0
            frame_data = [ 0, 0, 0, frame_vinp ];
        case 1
            [frame_data,enc] = encoder(frame_vinp,enc,dec);
        case 2
            [frame_data,enc] = encoder2(frame_vinp,enc,dec);
        end

        % count smooth-es
        if frame_data(1)<=frame_data(2)
            smooth0 = 0;
        else
            smooth0 = 1;
        end
        smooth1 = frame_data(3);

        if smooth0==0 && smooth1==0
            smooth0_N = smooth0_N + 1;
        elseif smooth0==1 && smooth1==0
            smooth1_N = smooth1_N + 1;
        elseif smooth0==0 && smooth1==1
            smooth2_N = smooth2_N + 1;
        else
            smooth3_N = smooth3_N + 1;
        end

        % decode data frame to voice
        switch CODEC_VERSION
        case 0
            frame_vout = frame_data(4:end);
        case 1
            [frame_vout,dec] = decoder(frame_data,dec);
        case 2
            [frame_vout,dec] = decoder2(frame_data,dec);
        end

    end

    ttt_vinp(i) = vinp;
    ttt_vout(i) = vout;

end

fprintf(1,'smooth_N:  0=%6d  1=%6d  2=%6d  3=%6d\n', smooth0_N, smooth1_N, smooth2_N, smooth3_N);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make error estimates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

SHIFT = SAMPLES_PER_FRAME;

%shift vout to compensate encoder delay
ttt_vout_shifted = [ ttt_vout(SHIFT+1:end) , zeros(1,SHIFT) ];
%shift y to compensate encoder delay
y_shifted = [ y(SHIFT+1:end) , zeros(1,SHIFT) ];

% Calculate and print errors values
err = ttt_vinp - ttt_vout_shifted;
err = err(1:end-SAMPLES_PER_FRAME*2);
avg_err = mean( abs(err) );
max_err = max( abs(err) );
std_err = std( abs(err) );
mse_err = mean((err/MAXX).^2);

fprintf(1,'\n');
fprintf(1,'vinp,vout errors:\n');
fprintf(1,'avg error=%6d\n',avg_err);
fprintf(1,'max error=%6d\n',max_err);
fprintf(1,'std error=%6d\n',std_err);
fprintf(1,'mse error=%12.6f\n',mse_err);

erry = x - y_shifted;
erry = erry(1:end-SAMPLES_PER_FRAME*2);
avg_erry = mean( abs(erry) );
max_erry = max( abs(erry) );
std_erry = std( abs(erry) );
mse_erry = mean((erry/AMP).^2);
fprintf(1,'\n');
fprintf(1,'x,y errors:\n');
fprintf(1,'avg error=%6d\n',avg_erry);
fprintf(1,'max error=%6d\n',max_erry);
fprintf(1,'std error=%6d\n',std_erry);
fprintf(1,'mse error=%12.6f\n',mse_erry);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot graphics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if SHOW_GRAPHICS==1

% Plot waveforms of signals
figure(1);
subplot(2,1,1);
    plot(t,x);
    title('original signal');  xlabel('t,sec');  ylabel('x');
    ylim([-AMP, +AMP]);
    grid on;
subplot(2,1,2);
    plot(t,y);
    title('encoded/decoded signal');  xlabel('t,sec');  ylabel('y');
    ylim([-AMP, +AMP]);
    grid on;

% Build and plot spectrogramms of signals
figure(2);
subplot(3,1,1);
    s_signal = spectrogram( x, SPECTROGRAM_WIDTH, FS, SPECTROGRAM_OVR);
    title('original signal spectrogramm');
subplot(3,1,2);
    s_clean = spectrogram( y, SPECTROGRAM_WIDTH, FS, SPECTROGRAM_OVR);
    title('encoded/decoded signal spectrogramm');
subplot(3,1,3);
    time = (0:N)/FS;
    freq = 0:FS/2/SPECTROGRAM_WIDTH:FS/2;
    imagesc(time,freq,abs(s_signal - s_clean) );
    axis xy;
    xlabel('time,sec');
    ylabel('freq,Hz');
    %colorbar;
    title('difference of spectrogramms');

% Compare input/output waveforms [-MAXX..MAXX] scale
figure(3);
    plot( t, ttt_vinp,'r.-',  t, ttt_vout_shifted,'b.-' );  xlabel('t,sec');  ylabel('y');
    ylim([-MAXX MAXX]);
    title('-MAXX..+MAXX quantizied signal');
    legend('vinp','vout(shifted)');

figure(4);
    plot( t, ttt_vinp - ttt_vout_shifted,'r.-' );  xlabel('t,sec');  ylabel('y');
    title('-MAXX..+MAXX quantizied signal error');
    legend('error(vinp,vout(shifted))');
    ylim([-MAXX MAXX]);

% Compare input/output waveforms [-AMP..AMP] scale
figure(5);
    plot( t, x,'r.-',  t, y_shifted,'b.-' );  xlabel('t,sec');  ylabel('y');
    title('-AMP..+AMP quantizied signal');
    legend('x','y(shifted)');
    ylim([-AMP AMP]);

figure(6);
    plot( t, x - y_shifted,'r.-' );  xlabel('t,sec');  ylabel('y');
    title('-AMP..+AMP quantizied signal error');
    legend('error(x,y(shifted))');
    ylim([-AMP AMP]);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save processed (clean) signal into output wavefile
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch CODEC_VERSION
case 0
    wavwrite( (y/AMP).', FS, bits_voice, OUTPUT_FILENAME_0 );
case 1
    wavwrite( (y/AMP).', FS, bits_voice, OUTPUT_FILENAME_1 );
case 2
    wavwrite( (y/AMP).', FS, bits_voice, OUTPUT_FILENAME_2 );
end

fprintf(1,'test finished! %d samples processed!\n', N);
