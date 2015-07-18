%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test script to compare quality of codecs and estimate MSE                    %
% main_compare.m                                                               %
%                                                                              %
% (c) Sergei Mashkin, 2015                                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
clear all;
close all;
disp('MSE compare test started...');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FS = 8000;            % Sample (discretization) frequency, Hz
TS = 1/FS;            % Sample (discretization) period, sec

SPECTROGRAM_WIDTH = 256; % Parameters of spectrograms
SPECTROGRAM_OVR   = 8;

% Name of file for original signal
ORIGINAL_FILENAME = '../c/out/input.wav';  

% Name of file for signal which has been encoded/decoded by codec 1
CODEC1_FILENAME   = '../c/out/g726-32kbps.wav';   
%CODEC1_FILENAME   = '../c/out/g726-40kbps.wav';   

% Name of file for signal which has been encoded/decoded by codec 2
CODEC2_FILENAME   = '../c/out/mmdq-32kbps.wav';
%CODEC2_FILENAME   = '../c/out/mmdq-42kbps.wav';
%CODEC2_FILENAME   = 'out1.wav';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load input (voice,noise) signals from wave-files, generate signal to process
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[x0, ffs0, bits0] = wavread(ORIGINAL_FILENAME);
if ffs0~=FS
    error('invalid sample frequency of original signal wavefile');
end

[x1, ffs1, bits1] = wavread(CODEC1_FILENAME);
if ffs1~=FS
    error('invalid sample frequency of codec-1 signal wavefile');
end

if length(CODEC2_FILENAME)>0
[x2, ffs2, bits2] = wavread(CODEC2_FILENAME);
if ffs2~=FS
    error('invalid sample frequency of codec-2 signal wavefile');
end
end

% Make horizontal vectors. If wavefiles are stereo, use only the first channels
x0 = x0(:,1).';       % now x has range [-1..+1]
x0 = fix(x0 * 32768); % now x has range [-32768..+32768]
N0 = size(x0,2);

x1 = x1(:,1).';       % now x1 has range [-1..+1]
x1 = fix(x1 * 32768); % now x1 has range [-32768..+32768]
N1 = size(x1,2);

if length(CODEC2_FILENAME)>0
x2 = x2(:,1).';       % now x2 has range [-1..+1]
x2 = fix(x2 * 32768); % now x2 has range [-32768..+32768]
N2 = size(x2,2);
end

% Limit lenght of signal to minimal Ni
N = N0;
if N1<=N
    N = N1;
end
if length(CODEC2_FILENAME)>0
if N2<=N
    N = N2;
end
end

x0 = x0(1:N);
x1 = x1(1:N);
if length(CODEC2_FILENAME)>0
x2 = x2(1:N);
end

% Convert sample numbers into time ticks (we will use this for plotting)
t = (1:N)/FS;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compare signals
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

diff1 = x0-x1;
maxerr1 = max(diff1);
mse1 = mean(diff1.^2);
ndiff1 = diff1/32768;
nmaxerr1 = max(ndiff1);
nmse1 = mean(ndiff1.^2);

if length(CODEC2_FILENAME)>0
diff2 = x0-x2;
maxerr2 = max(diff2);
mse2 = mean(diff2.^2);
ndiff2 = diff2/32768;
nmaxerr2 = max(ndiff2);
nmse2 = mean(ndiff2.^2);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Show results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Compare test settings
fprintf(1,'compare test:\n');
fprintf(1,'-----------------------\n');
fprintf(1,'original file     : %s\n', ORIGINAL_FILENAME);
fprintf(1,'  sample freq, Hz : %8d\n', ffs0);
fprintf(1,'  bits            : %8d\n', bits0);
fprintf(1,'  length,samples  : %8d\n', N0);
fprintf(1,'  length,sec      : %8.3f\n', N0/ffs0);
fprintf(1,'-----------------------\n');
fprintf(1,'codec-1 file      : %s\n', CODEC1_FILENAME);
fprintf(1,'  sample freq, Hz : %8d\n', ffs1);
fprintf(1,'  bits            : %8d\n', bits1);
fprintf(1,'  length,samples  : %8d\n', N1);
fprintf(1,'  length,sec      : %8.3f\n', N1/ffs1);
fprintf(1,'  test samples    : %8d\n', N);
fprintf(1,'  max error       : %10d\n', maxerr1);
fprintf(1,'  mse             : %10d\n', mse1);
fprintf(1,'  max error (norm): %10.6f\n', nmaxerr1);
fprintf(1,'  mse       (norm): %10.6f\n', nmse1);
fprintf(1,'-----------------------\n');
if length(CODEC2_FILENAME)>0
fprintf(1,'codec-2 file      : %s\n', CODEC2_FILENAME);
fprintf(1,'  sample freq, Hz : %8d\n', ffs2);
fprintf(1,'  bits            : %8d\n', bits2);
fprintf(1,'  length,samples  : %8d\n', N2);
fprintf(1,'  length,sec      : %8.3f\n', N2/ffs2);
fprintf(1,'  test samples    : %8d\n', N);
fprintf(1,'  max error       : %10d\n', maxerr2);
fprintf(1,'  mse             : %10d\n', mse2);
fprintf(1,'  max error (norm): %10.6f\n', nmaxerr2);
fprintf(1,'  mse       (norm): %10.6f\n', nmse2);
fprintf(1,'-----------------------\n');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot graphics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Build and plot spectrogramms of signals
figure(1);
subplot(3,1,1);
    s0 = spectrogram( x0, SPECTROGRAM_WIDTH, FS, SPECTROGRAM_OVR);
    title('original signal spectrogramm');
subplot(3,1,2);
    s1 = spectrogram( x1, SPECTROGRAM_WIDTH, FS, SPECTROGRAM_OVR);
    title('codec-1 signal spectrogramm');
subplot(3,1,3);
    time = (0:N)/FS;
    freq = 0:FS/2/SPECTROGRAM_WIDTH:FS/2;
    imagesc(time,freq,abs(s1 - s0) );
    axis xy;
    xlabel('time,sec');
    ylabel('freq,Hz');
    %colorbar;
    title('difference of spectrogramms');

figure(2);
subplot(3,1,1);
    s0 = spectrogram( x0, SPECTROGRAM_WIDTH, FS, SPECTROGRAM_OVR);
    title('original signal spectrogramm');
subplot(3,1,2);
    s2 = spectrogram( x2, SPECTROGRAM_WIDTH, FS, SPECTROGRAM_OVR);
    title('codec-2 signal spectrogramm');
subplot(3,1,3);
    time = (0:N)/FS;
    freq = 0:FS/2/SPECTROGRAM_WIDTH:FS/2;
    imagesc(time,freq,abs(s2 - s0) );
    axis xy;
    xlabel('time,sec');
    ylabel('freq,Hz');
    %colorbar;
    title('difference of spectrogramms');

% Compare input/output waveforms
figure(3);
    subplot(2,1,1);
    plot( t, x0,'r.-',  t, x1,'b.-' );  xlabel('t,sec');  ylabel('y');
    ylim([-32768 32768]);
    legend('original x','codec-1 x');

    subplot(2,1,2);
    plot( t, x0,'r.-',  t, x2,'b.-' );  xlabel('t,sec');  ylabel('y');
    ylim([-32768 32768]);
    legend('original x','codec-2 x');

figure(4);
    subplot(2,1,1);
    plot( t, diff1,'r.-');  xlabel('t,sec');  ylabel('diff');
    ylim([-32768 32768]);
    legend('x1-x0');

    subplot(2,1,2);
    plot( t, diff2,'r.-');  xlabel('t,sec');  ylabel('diff');
    ylim([-32768 32768]);
    legend('x2-x0');

fprintf(1,'test finished!\n');