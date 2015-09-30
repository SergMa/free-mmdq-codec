%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test script to check and demonstrate work of MMDQ-codec                      %
% main_test.m                                                                  %
%                                                                              %
% (c) Sergei Mashkin, 2015                                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
clear all;
close all;

disp('started!');

LOGFILENAME = 'out/results.txt';
fid = 1; 
%fid = fopen(LOGFILENAME,'w'); %uncomment this to use file instead of stdout
if fid==-1
    fid = 1;
    fprintf(fid,'Error: could not create results file: %s\n', LOGFILENAME);
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
%SAMPLES = 1000:5000; % set desired samples range here

USE_AUTOSCALE = 1;    % 0 - disable autoscale of input signals, 1 - enable

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

%SAMPLES_PER_FRAME = 13; %40000 bit/s     (MMDQ-40)
%BITS_PER_SAMPLE   = 4;

%SAMPLES_PER_FRAME = 26; %36000 bit/s
%BITS_PER_SAMPLE   = 4;

%SAMPLES_PER_FRAME = 6; %42666 bit/s
%BITS_PER_SAMPLE   = 3;

%SAMPLES_PER_FRAME = 7; %40000 bit/s      (MMDQ-40x)
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

%compand/expand functions powers
COM_PWR = [1.0  1.10  1.20  1.20];  % best for MMDQ-32
EXP_PWR = [1.0  1.10  1.20  1.20];

%COM_PWR = [ 1.00459654758119  1.09093693508955   1.17309811506971   1.183272628612 ];  % best for MMDQ-40
%EXP_PWR = [ 1.00459654758119  1.09093693508955   1.17309811506971   1.183272628612 ];

CODEC_VERSION = 1;    % 0-no encode/decode operations
                      % 1-matlab float point
                      % 2-c-adapted, code tables, div tables

SMOOTH_N = 4;         % number of smoothes functions: 1..4

SMOOTH_ERROR_VER = 0; % version of function to select best smooth function
                      % 0:   max( abs(srnv - snv) )
                      % 1:   sum( abs(srnv - snv) )
                      % 2:   mean((abs(srnv - snv)).^2);

FS = 8000;            % Sample (discretization) frequency, Hz
TS = 1/FS;            % Sample (discretization) period, sec
BITS = 16;            % Bits per sample in original input signal
MAXX = 2^(BITS-1);    % Maximum amplitude of original input signal (for BITS=16: AMP=32768)

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
fprintf(fid,'smooth_n         : %d\n', SMOOTH_N);
fprintf(fid,'smooth_error_ver : %d\n', SMOOTH_ERROR_VER);
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
voice_filename   = '../samples/cmu/sample3_8000.wav';         VOICE_AMP_DB = -3;  %female
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
% Initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

    % count smooth-es
    if enc_data(1)<=enc_data(2)
        smooth0 = 0;
    else
        smooth0 = 1;
    end
    smooth1 = enc_data(3);

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
        dec_voice = enc_data(4:end);
    case 1
        [dec_voice,dec] = decoder(enc_data,dec);
    case 2
        [dec_voice,dec] = decoder2(enc_data,dec);
    end

    %scale back, output voice
    y(i:i+SAMPLES_PER_FRAME-1) = fix( dec_voice );

    ttt_vinp(i:i+SAMPLES_PER_FRAME-1) = enc_voice;
    ttt_vout(i:i+SAMPLES_PER_FRAME-1) = dec_voice;

    i = i + SAMPLES_PER_FRAME;
end

fprintf(fid,'smooth_N:  0=%6d  1=%6d  2=%6d  3=%6d\n', smooth0_N, smooth1_N, smooth2_N, smooth3_N);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make error estimates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Calculate and print errors values
erry = y - x;
avg_erry = mean( abs(erry) );
max_erry = max( abs(erry) );
std_erry = std( abs(erry) );
mse_erry = mean( erry.*erry );

max_x = max( abs(x) );
nerry = (y - x)/max_x;
avg_nerry = mean( abs(nerry) );
max_nerry = max( abs(nerry) );
std_nerry = std( abs(nerry) );
mse_nerry = mean( nerry.*nerry );

fprintf(fid,'\n');
fprintf(fid,'x,y errors:\n');
fprintf(fid,'  avg errory=%12.8f\n',avg_erry);
fprintf(fid,'  max errory=%12.8f\n',max_erry);
fprintf(fid,'  std errory=%12.8f\n',std_erry);
fprintf(fid,'  mse errory=%12.8f\n',mse_erry);

fprintf(fid,'x,y normalized errors:\n');
fprintf(fid,'  avg nerrory=%12.8f\n',avg_nerry);
fprintf(fid,'  max nerrory=%12.8f\n',max_nerry);
fprintf(fid,'  std nerrory=%12.8f\n',std_nerry);
fprintf(fid,'  mse nerrory=%12.8f\n',mse_nerry);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot graphics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if SHOW_GRAPHICS==1

% Plot waveforms of signals
figure(1);
subplot(2,1,1);
    plot(t,x);
    title('original signal');
    xlabel('t,sec');
    ylabel('x');
    ylim([-MAXX, +MAXX]);
    grid on;
subplot(2,1,2);
    plot(t,y);
    title('encoded/decoded signal');
    xlabel('t,sec');
    ylabel('y');
    ylim([-MAXX, +MAXX]);
    grid on;
print('-dpng','out/test_waveforms.png');

% Build and plot spectrogramms of signals
figure(2);
subplot(3,1,1);
    sx = spectrogram( x, SPECTROGRAM_WIDTH, FS, SPECTROGRAM_OVR);
    title('original signal spectrogramm');
subplot(3,1,2);
    sy = spectrogram( y, SPECTROGRAM_WIDTH, FS, SPECTROGRAM_OVR);
    title('encoded/decoded signal spectrogramm');
subplot(3,1,3);
    time = (0:N)/FS;
    freq = 0:FS/2/SPECTROGRAM_WIDTH:FS/2;
    imagesc(time,freq,abs(sx - sy) );
    axis xy;
    xlabel('time,sec');
    %colorbar;
    title('difference of spectrogramms');
print('-dpng','out/test_spectrogramms.png');

% Show compand/expand functions tables
if CODEC_VERSION==2
    figure(3);
    for s=1:SMOOTH_N
        subplot(4,2,2*s-1);
        hist(enc.table(s,:),100);
        title('compand');
        subplot(4,2,2*s);
        hist(dec.table(s,:),100);
        title('expand');
    end
    print('-dpng','out/test_expandcompand.png');
end

% Compare input/output waveforms [-MAXX..MAXX] scale
figure(4);
    subplot(2,1,1);
    plot( t, x,'r.-',  t, y,'b.-' );  xlabel('t,sec');  ylabel('y');
    title('quantizied signal');
    legend('x','y');
    ylim([-MAXX MAXX]);

    subplot(2,1,2);
    plot( t, x - y,'r.-' );  xlabel('t,sec');  ylabel('y');
    title('quantizied signal error');
    legend('error(x,y)');
    ylim([-MAXX MAXX]);
    print('-dpng','out/test_restored_signal.png');

figure(5);

    %plot graphics near the first max(error)/2
    if length(t) <= 600
        tz = t;
        xz = x;
        yz = y;
    else
        iz = 0;
        errz = abs(x-y);
        maxerrz = max(errz);
        Nz = length(t);
        for i=200:Nz-200
            if errz(i) >= maxerrz/2
                iz = i;
            end
        end
        if iz>0
            iz = iz-100 : iz+100;
        else
            iz = 1:200;
        end
        tz = t(iz);
        xz = x(iz);
        yz = y(iz);
    end

    subplot(2,1,1);
    plot( tz, xz,'r.-',  tz, yz,'b.-' );  xlabel('t,sec');  ylabel('y');
    title('quantizied signal (zoom)');
    legend('x','y');
    ylim([-MAXX MAXX]);

    subplot(2,1,2);
    plot( tz, xz - yz,'r.-' );  xlabel('t,sec');  ylabel('y');
    title('quantizied signal error (zoom)');
    legend('error(x,y)');
    ylim([-MAXX MAXX]);
    print('-dpng','out/test_restored_signal_zoom.png');

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save processed (clean) signal into output wavefile
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch CODEC_VERSION
case 0
    wavwrite( (y/MAXX).', FS, bits_voice, OUTPUT_FILENAME_0 );
case 1
    wavwrite( (y/MAXX).', FS, bits_voice, OUTPUT_FILENAME_1 );
case 2
    wavwrite( (y/MAXX).', FS, bits_voice, OUTPUT_FILENAME_2 );
end

fprintf(fid,'test finished! %d samples processed!\n', N);

if fid~=1
    fclose(fid);
end

disp('finished!');
