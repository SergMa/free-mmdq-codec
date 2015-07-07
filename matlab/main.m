%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test script to check and demonstrate work of          %
% my codec                                              %
%                                                       %
% 2015, Sergei Mashkin                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
clear all;
close all;
disp('started...');

FS = 8000;  % Sample (discretization) frequency, Hz
TS = 1/FS;  % Sample (discretization) period, sec

INPUT_FILENAME  = './input.wav'; % Name of file for input (noised) signal
OUTPUT_FILENAME = './out.wav';   % Name of file for output (clean) signal

SPECTROGRAM_WIDTH = 512; % Parameters of spectrograms
SPECTROGRAM_OVR   = 16;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load input (voice,noise) signals from wave-files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

USE_AUTOSCALE = 1; % 0 - disable autoscale of input signals, 1 - enable

%voice_filename = '../samples/cmu/sample1_8000.wav';         VOICE_AMP_DB = 0;
%voice_filename = '../samples/cmu/sample2_8000.wav';         VOICE_AMP_DB = 0;
voice_filename = '../samples/cmu/sample3_8000.wav';         VOICE_AMP_DB = 0;  %female
%voice_filename = '../samples/cmu/sample4_8000.wav';         VOICE_AMP_DB = 0;
%voice_filename  = '../samples/cmu/sample5_8000.wav';         VOICE_AMP_DB = 0;
%voice_filename = '../samples/cmu/sample6_8000.wav';         VOICE_AMP_DB = 0;
%voice_filename = '../samples/cmu/sample7_8000.wav';         VOICE_AMP_DB = 0;

%noise_filename = '../samples/noise/noise_white.wav';        NOISE_AMP_DB = -12;
%noise_filename = '../samples/noise/noise_pink.wav';         NOISE_AMP_DB = -12;
%noise_filename = '../samples/noise/noise_brown.wav';        NOISE_AMP_DB = -12;
%noise_filename = '../samples/noise/noise_badbearing.wav';   NOISE_AMP_DB = -12;
noise_filename  = '../samples/noise/noise_diesel.wav';       NOISE_AMP_DB = -20;
%noise_filename  = '../samples/noise/noise_lacetti.wav';     NOISE_AMP_DB = -12;
%noise_filename = '../samples/noise/noise_lacetti2.wav';     NOISE_AMP_DB = -12;
%noise_filename = '../samples/noise/noise_tractor.wav';      NOISE_AMP_DB = -12;
%noise_filename = '../samples/noise/noise_yamzdiesel.wav';   NOISE_AMP_DB = -12;

[x_voice,ffs_voice,bits_voice] = wavread(voice_filename);
if ffs_voice~=FS
    error('invalid sample frequency of input voice wavefile');
end

[x_noise,ffs_noise,bits_noise] = wavread(noise_filename);
if ffs_noise~=FS
    error('invalid sample frequency of input noise wavefile');
end

% Make horizontal vectors. If wavefiles are stereo, use only the first channels
% now x has range [-1..+1]
x_voice = x_voice(:,1).';
N_voice = size(x_voice,2);

x_noise = x_noise(:,1).';
N_noise = size(x_noise,2);

% Normalize power of signals, if needed
if USE_AUTOSCALE==1
    x_voice = autoscale(x_voice, 1.0);
    x_noise = autoscale(x_noise, 1.0);
end

% Limit lenght of signal, if needed.
TC = 5; %sec  Set TC=0 to make no limit.
if TC > 0
    N = min(N_voice, TC*FS );
    x_voice = x_voice(1:N);
end

% Add noise to voice
x = mixer( x_voice, VOICE_AMP_DB, x_noise, NOISE_AMP_DB );
N = length(x);

% Convert sample numbers into time ticks (we will use this for plotting)
t = (1:N)/FS;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Prepare signal to process
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Save input signal into input wavefile
wavwrite( x.',FS,bits_voice,INPUT_FILENAME);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize my codec
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main processing code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

SAMPLES_PER_FRAME = 8;
BITS_PER_SAMPLE = 2;
FACTOR = 2^BITS_PER_SAMPLE - 1;

COMPRESSION = (SAMPLES_PER_FRAME * 8) / (8 + 8 + SAMPLES_PER_FRAME*BITS_PER_SAMPLE);
COMPRESSION

BITRATE = 64000 / COMPRESSION;
BITRATE

enc_cntr = 1;
enc_xbuf = zeros(1,SAMPLES_PER_FRAME);
enc_dbuf = zeros(1,SAMPLES_PER_FRAME);
enc_dbuf0 = zeros(1,SAMPLES_PER_FRAME);
enc_dbuf1 = zeros(1,SAMPLES_PER_FRAME);

dec_cntr = 1;
dec_xbuf = zeros(1,SAMPLES_PER_FRAME);
dec_dbuf = zeros(1,SAMPLES_PER_FRAME);

data_ready = 0;

y = zeros(1,N);


%fill enc_table
enc_table = zeros(255,255);
for d1 = 0:255
for d2 = 0:255
    if d2==0
        enc_table( d1+1, d2+127+1 ) = 0;
    else
        if d1 > d2
            enc_table( d1+1, d2+127+1 ) = 0;
        else
            enc_table( d1+1, d2+127+1 ) = round( FACTOR * d1 / d2 );
        end
    end
end
end

%fill dec_table
dec_table = zeros(255,255);
for d1 = 0:FACTOR
for d2 = 0:255
    if d2==0
        dec_table( d1+1, d2+127+1 ) = 0;
    else
        if d1 > d2
            dec_table( d1+1, d2+127+1 ) = 0;
        else
            dec_table( d1+1, d2+127+1 ) = round( FACTOR * d1 / d2 );
        end
    end
end
end

for i=1:N
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Check, is there voice activity in signal.
    % If not, refresh noise parameters,
    % if yes, leave noise parameters unchanged

    % input

    %convert x into [-128...+127]  simple model of G.711 codec
    enc_x = round(127 * x(i));

    % encode signal
    if (enc_cntr<=SAMPLES_PER_FRAME)
        % fill buffer to encode
        enc_xbuf(enc_cntr) = enc_x;
        enc_cntr = enc_cntr + 1;

        if (enc_cntr==SAMPLES_PER_FRAME+1)
            % encode buffer (enc_xbuf -> enc_ybuf)
            %enc_dbuf = enc_xbuf;

            minx = min(min(enc_xbuf));
            maxx = max(max(enc_xbuf));
            diff = maxx - minx;
            enc_dbuf(1) = minx;
            enc_dbuf(2) = maxx;
            enc_dbuf(3) = 0; %smooth

            for s=1:SAMPLES_PER_FRAME
                %enc_dbuf(3+s) = round( FACTOR*(enc_xbuf(s) - minx) / diff );
                enc_dbuf(3+s) = enc_table( (enc_xbuf(s) - minx)+1, diff+127+1 );
            end

            enc_cntr = 1;
            data_ready = 1;
        end
    end

    % put data from encoder to decoder
    if (data_ready==1)
        dec_dbuf = enc_dbuf;

        % decode signal
        %decode buffer (dec_dbuf -> dec_xbuf)
        %dec_xbuf = dec_dbuf;

        minx   = dec_dbuf(1);
        maxx   = dec_dbuf(2);
        smooth = dec_dbuf(3);
        diff = maxx - minx;

        ds = dec_dbuf(3+1:end);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


        for s=1:SAMPLES_PER_FRAME
            dec_xbuf(s) = (ds(s) * diff / FACTOR) + minx;
        end

        data_ready = 0;
        dec_cntr = 1;
    end

    if (dec_cntr<=SAMPLES_PER_FRAME)
        % output decoded frame
        dec_x = dec_xbuf(dec_cntr);
        dec_cntr = dec_cntr + 1;

        if (dec_cntr==SAMPLES_PER_FRAME+1)
            dec_cntr = 1;
        end
    end

    % convert y from [-128...+127] into [-1..+1]
    y(i) = dec_x / 127;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot graphics, make estimates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fig = 1;

% Plot waveforms of signals
figure(fig);
fig = fig + 1;
subplot(2,1,1);
    plot(t,x);
    title('original signal');  xlabel('t,sec');  ylabel('x');
    ylim([-1, +1]);
subplot(2,1,2);
    plot(t,y);
    title('encoded/decoded signal');  xlabel('t,sec');  ylabel('y');
    ylim([-1, +1]);

% Build and plot spectrogramms of signals
figure(fig);
fig = fig + 1;
subplot(2,1,1);
    s_signal = spectrogram( x, SPECTROGRAM_WIDTH, FS, SPECTROGRAM_OVR);
    title('input (voice+noise) signal');
subplot(2,1,2);
    s_clean = spectrogram( y, SPECTROGRAM_WIDTH, FS, SPECTROGRAM_OVR);
    title('processed (voice+noise) signal');

figure(10);
plot( t(1:end-SAMPLES_PER_FRAME), x(1:end-SAMPLES_PER_FRAME),'r.-', ...
      t(1:end-SAMPLES_PER_FRAME), y(SAMPLES_PER_FRAME+1-1:end-1),'b.-' );
%      t(1:end-SAMPLES_PER_FRAME), abs( x(1:end-SAMPLES_PER_FRAME) - y(SAMPLES_PER_FRAME+1-1:end-1) ), 'b' ); ylim([-1 1]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save processed (clean) signal into output wavefile
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

wavwrite(y',FS,bits_voice,OUTPUT_FILENAME);

disp('finished!');
