%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test script to check and demonstrate work of                                 %
% Mycodec                                                                      %
%                                                                              %
% 2015, Sergei Mashkin                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
clear all;
close all;
disp('started...');

SAMPLES = 1:5*8000; % Number of samples to process (if 0 - process all available samples
%SAMPLES = 6000:6500;
%SAMPLES = 8144:8180; % Number of samples to process (if 0 - process all available samples
%SAMPLES=0;
SHOW_GRAPHICS = 1;

FS = 8000;  % Sample (discretization) frequency, Hz
TS = 1/FS;  % Sample (discretization) period, sec

INPUT_FILENAME  = './input.wav'; % Name of file for input (noised) signal
OUTPUT_FILENAME = './out.wav';   % Name of file for output (clean) signal

SPECTROGRAM_WIDTH = 16; % Parameters of spectrograms
SPECTROGRAM_OVR   = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load input (voice,noise) signals from wave-files, generate signal to process
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

USE_AUTOSCALE = 1; % 0 - disable autoscale of input signals, 1 - enable

%voice_filename = '../samples/cmu/sample1_8000.wav';         VOICE_AMP_DB = 0;
%voice_filename = '../samples/cmu/sample2_8000.wav';         VOICE_AMP_DB = 0;
voice_filename  = '../samples/cmu/sample3_8000.wav';         VOICE_AMP_DB = 0;  %female
%voice_filename = '../samples/cmu/sample4_8000.wav';         VOICE_AMP_DB = 0;
%voice_filename = '../samples/cmu/sample5_8000.wav';         VOICE_AMP_DB = -6;
%voice_filename = '../samples/cmu/sample6_8000.wav';         VOICE_AMP_DB = 0;
%voice_filename = '../samples/cmu/sample7_8000.wav';         VOICE_AMP_DB = 0;
%voice_filename  = '../samples/modems/v92-mohdenied.wav';     VOICE_AMP_DB = 0;
%voice_filename  = '../samples/modems/v90-rockwellconex.wav'; VOICE_AMP_DB = 0;
%voice_filename  = '../samples/modems/v34-33600bps.wav';      VOICE_AMP_DB = 0;
%voice_filename  = '../samples/modems/v32b-14400bps.wav';     VOICE_AMP_DB = 0;
%voice_filename  = '../samples/modems/v22b-2400bps.wav';      VOICE_AMP_DB = 0;
%voice_filename  = '../samples/modems/v21-300bps.wav';        VOICE_AMP_DB = 0;
%voice_filename  = '../samples/modems/v17-14400bpsfax.wav';   VOICE_AMP_DB = 0;
%voice_filename  = '../samples/modems/ttytdd.wav';            VOICE_AMP_DB = 0;


%noise_filename = '../samples/noise/noise_white.wav';        NOISE_AMP_DB = -12;
%noise_filename = '../samples/noise/noise_pink.wav';         NOISE_AMP_DB = -12;
%noise_filename = '../samples/noise/noise_brown.wav';        NOISE_AMP_DB = -12;
noise_filename = '../samples/noise/noise_badbearing.wav';   NOISE_AMP_DB = -99;
%noise_filename  = '../samples/noise/noise_diesel.wav';       NOISE_AMP_DB = -99;  %
%noise_filename = '../samples/noise/noise_lacetti.wav';      NOISE_AMP_DB = -12;
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
% now x_voice, x_noise have range [-1..+1]
x_voice = x_voice(:,1).';
x_voice = fix(x_voice * 32767);
N_voice = size(x_voice,2);

% Limit lenght of signal, if needed.
if size(SAMPLES,2) > 1
    x_voice = x_voice(SAMPLES);
    N_voice = size(x_voice,2);
end

x_noise = x_noise(:,1).';
x_noise = fix(x_noise * 32767);
N_noise = size(x_noise,2);

% Normalize power of signals, if needed
if USE_AUTOSCALE==1
    x_voice = fix( autoscale(x_voice, 32767) );
    x_noise = fix( autoscale(x_noise, 32767) );
end

% Add noise to voice
x = fix( mixer( x_voice, VOICE_AMP_DB, x_noise, NOISE_AMP_DB ) );
%x = [0 0 0 0  -1000 100 -3000 -3500   -1300 10000 11000 4000   0 0 0 0 ];
N = length(x);

% Convert sample numbers into time ticks (we will use this for plotting)
t = (1:N)/FS;

% Save input signal into input wavefile
wavwrite( (x/32768).',FS,bits_voice,INPUT_FILENAME);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%SAMPLES_PER_FRAME = 7; %40000 bit/s
%BITS_PER_SAMPLE   = 3;

SAMPLES_PER_FRAME = 8; %38000 bit/s
BITS_PER_SAMPLE   = 3;

%SAMPLES_PER_FRAME = 10; %35200 bit/s
%BITS_PER_SAMPLE   = 3;

%SAMPLES_PER_FRAME = 14; %32000 bit/s
%BITS_PER_SAMPLE   = 3;

%SAMPLES_PER_FRAME = 15; %24000 bit/s
%BITS_PER_SAMPLE   = 2;

%SAMPLES_PER_FRAME = 20; %22000 bit/s
%BITS_PER_SAMPLE   = 2;

FACTOR = 2^BITS_PER_SAMPLE;
COMPRESSION = (SAMPLES_PER_FRAME * 8) / (8 + 8 + 1 + (SAMPLES_PER_FRAME-1)*BITS_PER_SAMPLE);
BITRATE = 64000 / COMPRESSION;

fprintf(1,'test of mycodec started...\n');
fprintf(1,'samles per frame : %d\n', SAMPLES_PER_FRAME);
fprintf(1,'bits per sample  : %d\n', BITS_PER_SAMPLE);
fprintf(1,'factor           : %d\n', FACTOR);
fprintf(1,'compression      : %f\n', COMPRESSION);
fprintf(1,'bitrate, bit/s   : %i\n', BITRATE);

% Create decoder and encoder structures
%enc = encoder_init( SAMPLES_PER_FRAME, BITS_PER_SAMPLE );
enc = encoder2_init( SAMPLES_PER_FRAME, BITS_PER_SAMPLE );

%dec = decoder_init( SAMPLES_PER_FRAME, BITS_PER_SAMPLE );
dec = decoder2_init( SAMPLES_PER_FRAME, BITS_PER_SAMPLE );


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

%     if i>=round(8000*0.041)
%         fprintf(1,'@\n');
%     end

    vinp = fix( 512*x(i)/32768 );
    if vinp>512
        vinp = 512;
    elseif vinp<-512
        vinp = -512;
    end
    %vinp = fix( x(i) );
    frame_vinp( frame_pos ) = vinp;

    vout = frame_vout( frame_pos );
    y(i) = fix( 32768*vout/512 );
    %y(i) = fix( vout );

    frame_pos = frame_pos + 1;
    if frame_pos > SAMPLES_PER_FRAME
        frame_pos = 1;
        % Накопили фрейм, кодируем-декодируем
        %[frame_data,enc] = encoder(frame_vinp,enc,dec);
        [frame_data,enc] = encoder2(frame_vinp,enc,dec);

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

% uncomment this to disable smoothing on receiving
%         if frame_data(1) > frame_data(2)
%             tmp = frame_data(2);
%             frame_data(2) = frame_data(1);
%             frame_data(1) = tmp;
%         end
%         frame_data(3) = 0;

        %[frame_vout,dec] = decoder(frame_data,dec);
        [frame_vout,dec] = decoder2(frame_data,dec);
%         figure(1);
%         subplot(2,1,1);  plot(frame_vout);
%         subplot(2,1,2);  plot(ttt_vout);
    end

    ttt_vinp(i) = vinp;
    ttt_vout(i) = vout;

end

fprintf(1,'smooth_N:  0=%6d  1=%6d  2=%6d  3=%6d\n', smooth0_N, smooth1_N, smooth2_N, smooth3_N);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot graphics, make estimates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if SHOW_GRAPHICS==1

% Plot waveforms of signals
figure(1);
subplot(2,1,1);
    plot(t,x);
    title('original signal');  xlabel('t,sec');  ylabel('x');
    ylim([-32768, +32768]);
subplot(2,1,2);
    plot(t,y);
    title('encoded/decoded signal');  xlabel('t,sec');  ylabel('y');
    ylim([-32768, +32768]);

% Build and plot spectrogramms of signals
figure(2);
subplot(2,1,1);
    s_signal = spectrogram( x, SPECTROGRAM_WIDTH, FS, SPECTROGRAM_OVR);
    title('original signal');
subplot(2,1,2);
    s_clean = spectrogram( y, SPECTROGRAM_WIDTH, FS, SPECTROGRAM_OVR);
    title('encoded/decoded signal');

% Compare input/output waveforms [-127..127] scale
figure(3);
    ttt_vout_shifted = [ ttt_vout(SAMPLES_PER_FRAME+1:end) , zeros(1,SAMPLES_PER_FRAME) ]; %сдвигаем vout, чтобы компенсировать задержку энкодера
    plot( t, ttt_vinp,'r.-',  t, ttt_vout_shifted,'b.-' );  xlabel('t,sec');  ylabel('y');
    legend('vinp','vout(shifted)');

figure(4);
    plot( t, ttt_vinp - ttt_vout_shifted,'r.-' );  xlabel('t,sec');  ylabel('y');
    legend('error(vinp,vout(shifted))');

err = ttt_vinp - ttt_vout_shifted;
avg_err = mean( abs(err) );
fprintf(1,'avg error=%6d\n',avg_err);

% Compare input/output waveforms [-32767..32767] scale
figure(5);
    y_shifted = [ y(SAMPLES_PER_FRAME+1:end) , zeros(1,SAMPLES_PER_FRAME) ]; %сдвигаем vout, чтобы компенсировать задержку энкодера
    plot( t, x,'r.-',  t, y_shifted,'b.-' );  xlabel('t,sec');  ylabel('y');
    legend('x','y(shifted)');

figure(6);
    plot( t, x - y_shifted,'r.-' );  xlabel('t,sec');  ylabel('y');
    legend('error(x,y(shifted))');

end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save processed (clean) signal into output wavefile
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

wavwrite( (y/32768).', FS, bits_voice, OUTPUT_FILENAME);

fprintf(1,'test finished! %d samples processed!\n', N);
