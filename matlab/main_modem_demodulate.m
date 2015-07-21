%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test script to demodulate modems wave-files                                  %
% main_modem_demodulate.m                                                      %
%                                                                              %
% This code needs MATLAB Communication Toolbox                                 %
%                                                                              %
% (c) Sergei Mashkin, 2015                                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
clear all;
close all;

FILENAME_PREFIX = 'mmdq-40_';
FILENAME_PREFIX = 'mmdq-40nosm_';
FILENAME_PREFIX = 'mmdq-40x_';
FILENAME_PREFIX = 'mmdq-40xnosm_';
FILENAME_PREFIX = 'mmdq-32_';
FILENAME_PREFIX = 'mmdq-32nosm_';
FILENAME_PREFIX = 'g726-40_';
FILENAME_PREFIX = 'g726-32_';
FILENAME_PREFIX = 'g711-alaw_';
FILENAME_PREFIX = 'g711-ulaw_';

DIR = 'modem';
LOGFILENAME = [DIR,filesep,FILENAME_PREFIX,'demodulation.log'];

disp('started!');

fid = fopen(LOGFILENAME,'w');
fprintf(fid,'modems signals demodulation started!');
fprintf(fid,'filename prefix: %s\n\n', FILENAME_PREFIX);

FS = 8000; %Sample rate, Hz

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ASK modem
FILENAME   = 'modem/ask2.wav';
FILENAME2  = [DIR,filesep,FILENAME_PREFIX,'ask2.wav'];
MODULATION = 'ask';
M  = 2;           %Use M-ary modulation
FC = 1600;        %Carrier frequency, Hz
FD = 1600;        %Data rate, bits per second
y  = wavread(FILENAME);
y2 = wavread(FILENAME2);

N  = length(y);
N2 = length(y2);
if N2<N
    y2 = [y2 ; zeros(N-N2,1)];
elseif N2>N
    y2 = y2(1:N,1);
end

data  = ddemod(y, FC,FD,FS,MODULATION,M);
data2 = ddemod(y2,FC,FD,FS,MODULATION,M);
DATABITS = length(data);

s = symerr(data,data2); % Check symbol error rate.
fprintf(fid,'file %s has been demodulated\n',FILENAME);
fprintf(fid,'file %s has been demodulated\n',FILENAME2);
fprintf(fid,'databits: %d, error rate: %d\n', DATABITS, s);
fprintf(fid,'MSE: %8.6f\n\n', mean( (y-y2).^2 ) );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%FSK modem (appr. V.23)
FILENAME   = 'modem/fsk2.wav';
FILENAME2  = [DIR,filesep,FILENAME_PREFIX,'fsk2.wav'];
MODULATION = 'fsk';
M  = 2;           %Use M-ary modulation
FC = 1600;        %Carrier frequency, Hz
FD = 1600;        %Data rate, bits per second
y  = wavread(FILENAME);
y2 = wavread(FILENAME2);

N  = length(y);
N2 = length(y2);
if N2<N
    y2 = [y2 ; zeros(N-N2,1)];
elseif N2>N
    y2 = y2(1:N,1);
end

data  = ddemod(y, FC,FD,FS,MODULATION,M);
data2 = ddemod(y2,FC,FD,FS,MODULATION,M);
DATABITS = length(data);

s = symerr(data,data2); % Check symbol error rate.
fprintf(fid,'file %s has been demodulated\n',FILENAME);
fprintf(fid,'file %s has been demodulated\n',FILENAME2);
fprintf(fid,'databits: %d, error rate: %d\n', DATABITS, s);
fprintf(fid,'MSE: %8.6f\n\n', mean( (y-y2).^2 ) );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%PSK-4 modem (appr. V.26)
FILENAME   = 'modem/psk4.wav';
FILENAME2  = [DIR,filesep,FILENAME_PREFIX,'psk4.wav'];
MODULATION = 'psk';
M  = 4;           %Use M-ary modulation
FC = 1600;        %Carrier frequency, Hz
FD = 1600;        %Data rate, bits per second
y  = wavread(FILENAME);
y2 = wavread(FILENAME2);

N  = length(y);
N2 = length(y2);
if N2<N
    y2 = [y2 ; zeros(N-N2,1)];
elseif N2>N
    y2 = y2(1:N,1);
end

data  = ddemod(y, FC,FD,FS,MODULATION,M);
data2 = ddemod(y2,FC,FD,FS,MODULATION,M);
DATABITS = length(data);

s = symerr(data,data2); % Check symbol error rate.
fprintf(fid,'file %s has been demodulated\n',FILENAME);
fprintf(fid,'file %s has been demodulated\n',FILENAME2);
fprintf(fid,'databits: %d, error rate: %d\n', DATABITS, s);
fprintf(fid,'MSE: %8.6f\n\n', mean( (y-y2).^2 ) );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%PSK-8 modem (appr. V.27ter)
FILENAME   = 'modem/psk8.wav';
FILENAME2  = [DIR,filesep,FILENAME_PREFIX,'psk8.wav'];
MODULATION = 'psk';
M  = 8;           %Use M-ary modulation
FC = 1600;        %Carrier frequency, Hz
FD = 1600;        %Data rate, bits per second
y  = wavread(FILENAME);
y2 = wavread(FILENAME2);

N  = length(y);
N2 = length(y2);
if N2<N
    y2 = [y2 ; zeros(N-N2,1)];
elseif N2>N
    y2 = y2(1:N,1);
end

data  = ddemod(y, FC,FD,FS,MODULATION,M);
data2 = ddemod(y2,FC,FD,FS,MODULATION,M);
DATABITS = length(data);

s = symerr(data,data2); % Check symbol error rate.
fprintf(fid,'file %s has been demodulated\n',FILENAME);
fprintf(fid,'file %s has been demodulated\n',FILENAME2);
fprintf(fid,'databits: %d, error rate: %d\n', DATABITS, s);
fprintf(fid,'MSE: %8.6f\n\n', mean( (y-y2).^2 ) );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%QASK-16 modem (appr. V.29 and V.32)
FILENAME   = 'modem/qask16.wav';
FILENAME2  = [DIR,filesep,FILENAME_PREFIX,'qask16.wav'];
MODULATION = 'qask';
M  = 16;          %Use M-ary modulation
FC = 1600;        %Carrier frequency, Hz
FD = 1600;        %Data rate, bits per second
y  = wavread(FILENAME);
y2 = wavread(FILENAME2);

N  = length(y);
N2 = length(y2);
if N2<N
    y2 = [y2 ; zeros(N-N2,1)];
elseif N2>N
    y2 = y2(1:N,1);
end

SCALE = (1/sqrt(2))*(1/3);
y  = (1/SCALE)*y;
y2 = (1/SCALE)*y2;

data  = ddemod(y, FC,FD,FS,MODULATION,M);
data2 = ddemod(y2,FC,FD,FS,MODULATION,M);
DATABITS = length(data);

s = symerr(data,data2); % Check symbol error rate.
fprintf(fid,'file %s has been demodulated\n',FILENAME);
fprintf(fid,'file %s has been demodulated\n',FILENAME2);
fprintf(fid,'databits: %d, error rate: %d\n', DATABITS, s);
fprintf(fid,'MSE: %8.6f\n\n', mean( (y-y2).^2 ) );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%QASK-32 modem (appr. V.33)
FILENAME   = 'modem/qask32.wav';
FILENAME2  = [DIR,filesep,FILENAME_PREFIX,'qask32.wav'];
MODULATION = 'qask';
M  = 32;          %Use M-ary modulation
FC = 1600;        %Carrier frequency, Hz
FD = 1600;        %Data rate, bits per second
y  = wavread(FILENAME);
y2 = wavread(FILENAME2);

N  = length(y);
N2 = length(y2);
if N2<N
    y2 = [y2 ; zeros(N-N2,1)];
elseif N2>N
    y2 = y2(1:N,1);
end

SCALE = (1/sqrt(2))*(1/5);
y  = (1/SCALE)*y;
y2 = (1/SCALE)*y2;

data  = ddemod(y, FC,FD,FS,MODULATION,M);
data2 = ddemod(y2,FC,FD,FS,MODULATION,M);
DATABITS = length(data);

s = symerr(data,data2); % Check symbol error rate.
fprintf(fid,'file %s has been demodulated\n',FILENAME);
fprintf(fid,'file %s has been demodulated\n',FILENAME2);
fprintf(fid,'databits: %d, error rate: %d\n', DATABITS, s);
fprintf(fid,'MSE: %8.6f\n\n', mean( (y-y2).^2 ) );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%QASK-64 modem (appr.V.34)
FILENAME   = 'modem/qask64.wav';
FILENAME2  = [DIR,filesep,FILENAME_PREFIX,'qask64.wav'];
MODULATION = 'qask';
M  = 64;          %Use M-ary modulation
FC = 1600;        %Carrier frequency, Hz
FD = 1600;        %Data rate, bits per second
y  = wavread(FILENAME);
y2 = wavread(FILENAME2);

N  = length(y);
N2 = length(y2);
if N2<N
    y2 = [y2 ; zeros(N-N2,1)];
elseif N2>N
    y2 = y2(1:N,1);
end

SCALE = (1/sqrt(2))*(1/7);
y  = (1/SCALE)*y;
y2 = (1/SCALE)*y2;

data  = ddemod(y, FC,FD,FS,MODULATION,M);
data2 = ddemod(y2,FC,FD,FS,MODULATION,M);
DATABITS = length(data);

s = symerr(data,data2); % Check symbol error rate.
fprintf(fid,'file %s has been demodulated\n',FILENAME);
fprintf(fid,'file %s has been demodulated\n',FILENAME2);
fprintf(fid,'databits: %d, error rate: %d\n', DATABITS, s);
fprintf(fid,'MSE: %8.6f\n\n', mean( (y-y2).^2 ) );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf(fid,'finished!\n');
fclose(fid);

disp('finished!');
