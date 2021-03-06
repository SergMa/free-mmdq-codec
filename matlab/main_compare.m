%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test script to compare quality of codecs and estimate MSE                    %
% main_compare.m                                                               %
%                                                                              %
% (c) Sergei Mashkin, 2015                                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
clear all;
close all;

disp('started!');

LOGFILENAME = 'out/results.txt';
fid = 1;
fid = fopen(LOGFILENAME,'w'); %uncomment this to use file instead of stdout
if fid==-1
    fid = 1;
    fprintf(fid,'Error: could not create results file: %s\n', LOGFILENAME);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FS = 8000;            % Sample (discretization) frequency, Hz
TS = 1/FS;            % Sample (discretization) period, sec

SPECTROGRAM_WIDTH = 256; % Parameters of spectrograms
SPECTROGRAM_OVR   = 8;



% Name of file for original signal
ORIGINAL_FILENAME  = 'female/female.wav';

% Name of file for signal which has been encoded/decoded by codec 1
CODEC1_FILENAME    = 'female/g726-32_female.wav';
%CODEC1_FILENAME    = 'female/g726-40_female.wav';
%CODEC1_FILENAME    = 'female/dvi4_female.wav';

% Name of file for signal which has been encoded/decoded by codec 2
CODEC2_FILENAME    = 'female/mmdq-32-1_female.wav';
%CODEC2_FILENAME    = 'female/mmdq-32-2_female.wav';
%CODEC2_FILENAME    = 'female/mmdq-32-3_female.wav';
%CODEC2_FILENAME    = 'female/mmdq-32-4_female.wav';

%CODEC2_FILENAME    = 'female/mmdq-40-1_female.wav';
%CODEC2_FILENAME    = 'female/mmdq-40-2_female.wav';
%CODEC2_FILENAME    = 'female/mmdq-40-3_female.wav';
%CODEC2_FILENAME    = 'female/mmdq-40-4_female.wav';

%CODEC2_FILENAME    = 'female/mmdq-40x-1_female.wav';
%CODEC2_FILENAME    = 'female/mmdq-40x-2_female.wav';
%CODEC2_FILENAME    = 'female/mmdq-40x-3_female.wav';
%CODEC2_FILENAME    = 'female/mmdq-40x-4_female.wav';



% Name of file for original signal
%ORIGINAL_FILENAME  = 'male/male.wav';

% Name of file for signal which has been encoded/decoded by codec 1
%CODEC1_FILENAME    = 'male/g726-32_male.wav';
%CODEC1_FILENAME    = 'male/g726-40_male.wav';
%CODEC1_FILENAME    = 'male/dvi4_male.wav';

% Name of file for signal which has been encoded/decoded by codec 2
%CODEC2_FILENAME    = 'male/mmdq-32-1_male.wav';
%CODEC2_FILENAME    = 'male/mmdq-32-2_male.wav';
%CODEC2_FILENAME    = 'male/mmdq-32-3_male.wav';
%CODEC2_FILENAME    = 'male/mmdq-32-4_male.wav';

%CODEC2_FILENAME    = 'male/mmdq-40-1_male.wav';
%CODEC2_FILENAME    = 'male/mmdq-40-2_male.wav';
%CODEC2_FILENAME    = 'male/mmdq-40-3_male.wav';
%CODEC2_FILENAME    = 'male/mmdq-40-4_male.wav';

%CODEC2_FILENAME    = 'male/mmdq-40x-1_male.wav';
%CODEC2_FILENAME    = 'male/mmdq-40x-2_male.wav';
%CODEC2_FILENAME    = 'male/mmdq-40x-3_male.wav';
%CODEC2_FILENAME    = 'male/mmdq-40x-4_male.wav';



% Name of file for original signal
%ORIGINAL_FILENAME  = 'modem/ask2.wav';

% Name of file for signal which has been encoded/decoded by codec 1
%CODEC1_FILENAME    = 'modem/g726-32_ask2.wav';
%CODEC1_FILENAME    = 'modem/g726-40_ask2.wav';
%CODEC1_FILENAME    = 'modem/dvi4_ask2.wav';

% Name of file for signal which has been encoded/decoded by codec 2
%CODEC2_FILENAME    = 'modem/mmdq-32-1_ask2.wav';
%CODEC2_FILENAME    = 'modem/mmdq-32-2_ask2.wav';
%CODEC2_FILENAME    = 'modem/mmdq-32-3_ask2.wav';
%CODEC2_FILENAME    = 'modem/mmdq-32-4_ask2.wav';

%CODEC2_FILENAME    = 'modem/mmdq-40-1_ask2.wav';
%CODEC2_FILENAME    = 'modem/mmdq-40-2_ask2.wav';
%CODEC2_FILENAME    = 'modem/mmdq-40-3_ask2.wav';
%CODEC2_FILENAME    = 'modem/mmdq-40-4_ask2.wav';

%CODEC2_FILENAME    = 'modem/mmdq-40x-1_ask2.wav';
%CODEC2_FILENAME    = 'modem/mmdq-40x-2_ask2.wav';
%CODEC2_FILENAME    = 'modem/mmdq-40x-3_ask2.wav';
%CODEC2_FILENAME    = 'modem/mmdq-40x-4_ask2.wav';



% Name of file for original signal
%ORIGINAL_FILENAME  = 'modem/fsk2.wav';

% Name of file for signal which has been encoded/decoded by codec 1
%CODEC1_FILENAME    = 'modem/g726-32_fsk2.wav';
%CODEC1_FILENAME    = 'modem/g726-40_fsk2.wav';
%CODEC1_FILENAME    = 'modem/dvi4_fsk2.wav';

% Name of file for signal which has been encoded/decoded by codec 2
%CODEC2_FILENAME    = 'modem/mmdq-32-1_fsk2.wav';
%CODEC2_FILENAME    = 'modem/mmdq-32-2_fsk2.wav';
%CODEC2_FILENAME    = 'modem/mmdq-32-3_fsk2.wav';
%CODEC2_FILENAME    = 'modem/mmdq-32-4_fsk2.wav';

%CODEC2_FILENAME    = 'modem/mmdq-40-1_fsk2.wav';
%CODEC2_FILENAME    = 'modem/mmdq-40-2_fsk2.wav';
%CODEC2_FILENAME    = 'modem/mmdq-40-3_fsk2.wav';
%CODEC2_FILENAME    = 'modem/mmdq-40-4_fsk2.wav';

%CODEC2_FILENAME    = 'modem/mmdq-40x-1_fsk2.wav';
%CODEC2_FILENAME    = 'modem/mmdq-40x-2_fsk2.wav';
%CODEC2_FILENAME    = 'modem/mmdq-40x-3_fsk2.wav';
%CODEC2_FILENAME    = 'modem/mmdq-40x-4_fsk2.wav';



% Name of file for original signal
%ORIGINAL_FILENAME  = 'modem/psk4.wav';

% Name of file for signal which has been encoded/decoded by codec 1
%CODEC1_FILENAME    = 'modem/g726-32_psk4.wav';
%CODEC1_FILENAME    = 'modem/g726-40_psk4.wav';
%CODEC1_FILENAME    = 'modem/dvi4_psk4.wav';

% Name of file for signal which has been encoded/decoded by codec 2
%CODEC2_FILENAME    = 'modem/mmdq-32-1_psk4.wav';
%CODEC2_FILENAME    = 'modem/mmdq-32-2_psk4.wav';
%CODEC2_FILENAME    = 'modem/mmdq-32-3_psk4.wav';
%CODEC2_FILENAME    = 'modem/mmdq-32-4_psk4.wav';

%CODEC2_FILENAME    = 'modem/mmdq-40-1_psk4.wav';
%CODEC2_FILENAME    = 'modem/mmdq-40-2_psk4.wav';
%CODEC2_FILENAME    = 'modem/mmdq-40-3_psk4.wav';
%CODEC2_FILENAME    = 'modem/mmdq-40-4_psk4.wav';

%CODEC2_FILENAME    = 'modem/mmdq-40x-1_psk4.wav';
%CODEC2_FILENAME    = 'modem/mmdq-40x-2_psk4.wav';
%CODEC2_FILENAME    = 'modem/mmdq-40x-3_psk4.wav';
%CODEC2_FILENAME    = 'modem/mmdq-40x-4_psk4.wav';



% Name of file for original signal
%ORIGINAL_FILENAME  = 'modem/psk8.wav';

% Name of file for signal which has been encoded/decoded by codec 1
%CODEC1_FILENAME    = 'modem/g726-32_psk8.wav';
%CODEC1_FILENAME    = 'modem/g726-40_psk8.wav';
%CODEC1_FILENAME    = 'modem/dvi4_psk8.wav';

% Name of file for signal which has been encoded/decoded by codec 2
%CODEC2_FILENAME    = 'modem/mmdq-32-1_psk8.wav';
%CODEC2_FILENAME    = 'modem/mmdq-32-2_psk8.wav';
%CODEC2_FILENAME    = 'modem/mmdq-32-3_psk8.wav';
%CODEC2_FILENAME    = 'modem/mmdq-32-4_psk8.wav';

%CODEC2_FILENAME    = 'modem/mmdq-40-1_psk8.wav';
%CODEC2_FILENAME    = 'modem/mmdq-40-2_psk8.wav';
%CODEC2_FILENAME    = 'modem/mmdq-40-3_psk8.wav';
%CODEC2_FILENAME    = 'modem/mmdq-40-4_psk8.wav';

%CODEC2_FILENAME    = 'modem/mmdq-40x-1_psk8.wav';
%CODEC2_FILENAME    = 'modem/mmdq-40x-2_psk8.wav';
%CODEC2_FILENAME    = 'modem/mmdq-40x-3_psk8.wav';
%CODEC2_FILENAME    = 'modem/mmdq-40x-4_psk8.wav';



% Name of file for original signal
%ORIGINAL_FILENAME  = 'modem/qask64.wav';

% Name of file for signal which has been encoded/decoded by codec 1
%CODEC1_FILENAME    = 'modem/g726-32_qask64.wav';
%CODEC1_FILENAME    = 'modem/g726-40_qask64.wav';
%CODEC1_FILENAME    = 'modem/dvi4_qask64.wav';

% Name of file for signal which has been encoded/decoded by codec 2
%CODEC2_FILENAME    = 'modem/mmdq-32-1_qask64.wav';
%CODEC2_FILENAME    = 'modem/mmdq-32-2_qask64.wav';
%CODEC2_FILENAME    = 'modem/mmdq-32-3_qask64.wav';
%CODEC2_FILENAME    = 'modem/mmdq-32-4_qask64.wav';

%CODEC2_FILENAME    = 'modem/mmdq-40-1_qask64.wav';
%CODEC2_FILENAME    = 'modem/mmdq-40-2_qask64.wav';
%CODEC2_FILENAME    = 'modem/mmdq-40-3_qask64.wav';
%CODEC2_FILENAME    = 'modem/mmdq-40-4_qask64.wav';

%CODEC2_FILENAME    = 'modem/mmdq-40x-1_qask64.wav';
%CODEC2_FILENAME    = 'modem/mmdq-40x-2_qask64.wav';
%CODEC2_FILENAME    = 'modem/mmdq-40x-3_qask64.wav';
%CODEC2_FILENAME    = 'modem/mmdq-40x-4_qask64.wav';


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

if exist('CODEC2_FILENAME')
    [x2, ffs2, bits2] = wavread(CODEC2_FILENAME);
    if ffs2~=FS
        error('invalid sample frequency of codec-2 signal wavefile');
    end
else
    CODEC2_FILENAME = 'no file';
    x2 = zeros(size(x1));
    ffs2 = ffs1;
    bits2 = bits1;
end

% Make horizontal vectors. If wavefiles are stereo, use only the first channels
x0 = x0(:,1).';       % now x has range [-1..+1]
x0 = fix(x0 * 32768); % now x has range [-32768..+32768]
N0 = size(x0,2);

x1 = x1(:,1).';       % now x1 has range [-1..+1]
x1 = fix(x1 * 32768); % now x1 has range [-32768..+32768]
N1 = size(x1,2);

x2 = x2(:,1).';       % now x2 has range [-1..+1]
x2 = fix(x2 * 32768); % now x2 has range [-32768..+32768]
N2 = size(x2,2);

% Limit lenght of signal to minimal Ni
N = N0;
if N1<=N
    N = N1;
end
if N2<=N
    N = N2;
end

x0 = x0(1:N);
x1 = x1(1:N);
x2 = x2(1:N);

% Convert sample numbers into time ticks (we will use this for plotting)
t = (1:N)/FS;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compare signals
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

max_x0 = max( abs(x0) );

err1     = x1-x0;
maxerr1  = max(err1);
mse1     = mean(err1.*err1);
nerr1    = err1/max_x0;
nmaxerr1 = max(nerr1);
nmse1    = mean(nerr1.*nerr1);

err2     = x2-x0;
maxerr2  = max(err2);
mse2     = mean(err2.*err2);
nerr2    = err2/max_x0;
nmaxerr2 = max(nerr2);
nmse2    = mean(nerr2.*nerr2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Show results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Compare test settings
fprintf(fid,'compare test:\n');
fprintf(fid,'-----------------------\n');
fprintf(fid,'original file     : %s\n', ORIGINAL_FILENAME);
fprintf(fid,'  sample freq, Hz : %8d\n', ffs0);
fprintf(fid,'  bits            : %8d\n', bits0);
fprintf(fid,'  length,samples  : %8d\n', N0);
fprintf(fid,'  length,sec      : %8.3f\n', N0/ffs0);
fprintf(fid,'-----------------------\n');
fprintf(fid,'codec-1 file      : %s\n', CODEC1_FILENAME);
fprintf(fid,'  sample freq, Hz : %8d\n', ffs1);
fprintf(fid,'  bits            : %8d\n', bits1);
fprintf(fid,'  length,samples  : %8d\n', N1);
fprintf(fid,'  length,sec      : %8.3f\n', N1/ffs1);
fprintf(fid,'  test samples    : %8d\n', N);
fprintf(fid,'  max error       : %10d\n', maxerr1);
fprintf(fid,'  mse             : %10d\n', mse1);
fprintf(fid,'  max error (norm): %10.8f\n', nmaxerr1);
fprintf(fid,'  mse       (norm): %10.8f\n', nmse1);
fprintf(fid,'-----------------------\n');
if length(CODEC2_FILENAME)>0
fprintf(fid,'codec-2 file      : %s\n', CODEC2_FILENAME);
fprintf(fid,'  sample freq, Hz : %8d\n', ffs2);
fprintf(fid,'  bits            : %8d\n', bits2);
fprintf(fid,'  length,samples  : %8d\n', N2);
fprintf(fid,'  length,sec      : %8.3f\n', N2/ffs2);
fprintf(fid,'  test samples    : %8d\n', N);
fprintf(fid,'  max error       : %10d\n', maxerr2);
fprintf(fid,'  mse             : %10d\n', mse2);
fprintf(fid,'  max error (norm): %10.8f\n', nmaxerr2);
fprintf(fid,'  mse       (norm): %10.8f\n', nmse2);
fprintf(fid,'-----------------------\n');
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
print('-dpng','out/compare_codec1_spectrogramm.png');

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
    %ylabel('freq,Hz');
    %colorbar;
    title('difference of spectrogramms');
print('-dpng','out/compare_codec2_spectrogramm.png');

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

    print('-dpng','out/compare_waveforms.png');

figure(4);
    subplot(2,1,1);
    plot( t, err1,'r.-');  xlabel('t,sec');  ylabel('err1');
    ylim([-32768 32768]);
    legend('x1-x0');

    subplot(2,1,2);
    plot( t, err2,'r.-');  xlabel('t,sec');  ylabel('err2');
    ylim([-32768 32768]);
    legend('x2-x0');

    print('-dpng','out/compare_errors.png');

fprintf(fid,'test finished!\n');

if fid~=1
    fclose(fid);
end

disp('finished!');
