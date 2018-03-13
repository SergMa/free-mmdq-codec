%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test script to demodulate modems wave-files                                  %
% main_modem.m                                                                 %
%                                                                              %
% This code needs MATLAB Communication Toolbox                                 %
%                                                                              %
% (c) Sergei Mashkin, 2015                                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
clear all;
close all;

%copy these from <main_modem_generate.m>
TIMEONE = 10;  %single loop length, sec
TIMENUM = 60;  %number of loops
TIMELEN = TIMENUM * TIMEONE;


FILENAME_PREFIX = {
'mmdq-40-1_';
'mmdq-40-2_';
'mmdq-40-3_';
'mmdq-40-4_';
'mmdq-40x-1_';
'mmdq-40x-2_';
'mmdq-40x-3_';
'mmdq-40x-4_';
'mmdq-32-1_';
'mmdq-32-2_';
'mmdq-32-3_';
'mmdq-32-4_';
'dvi4_';
'g726-40_';
'g726-32_';
'g711-alaw_';
'g711-ulaw_' };

DIR = 'modem';
disp('started!');

LOGFILENAME = [DIR,filesep,'demodulation.log'];
fid = 1;
fid = fopen(LOGFILENAME,'w'); %uncomment this to use file instead of stdout
if fid==-1
    fid = 1;
    fprintf(fid,'Error: could not create results file: %s\n', LOGFILENAME);
end

fprintf(fid,'modems signals demodulation started!');

for f=1:length(FILENAME_PREFIX)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(fid,'-----------------------------------------\n');
fprintf(fid,'filename prefix: %s\n\n', FILENAME_PREFIX{f});

FS = 8000; %Sample rate, Hz

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ASK modem
FILENAME   = 'modem/ask2.wav';
FILENAME2  = [DIR,filesep,FILENAME_PREFIX{f},'ask2.wav'];
MODULATION = 'ask';
M  = 2;           %Use M-ary modulation
FC = 1600;        %Carrier frequency, Hz
FD = 1600;        %Data rate, bits per second
y  = wavread(FILENAME);
y2 = wavread(FILENAME2);

SCALE = 0.9;
y  = (1/SCALE)*y;
y2 = (1/SCALE)*y2;

N  = length(y);
N2 = length(y2);
if N2<N
    y2 = [y2 ; zeros(N-N2,1)];
elseif N2>N
    y2 = y2(1:N,1);
end

data  = [];
data2 = [];
for i=1:TIMENUM
    ib = 1 + (i-1)*TIMEONE*FD;
    ie = ib + TIMEONE*FD - 1;
    iy  = y (ib:ie);
    iy2 = y2(ib:ie);
    idata  = ddemod(iy, FC,FD,FS,MODULATION,M);
    idata2 = ddemod(iy2,FC,FD,FS,MODULATION,M);
    data  = [data  ; idata ];
    data2 = [data2 ; idata2];
end

DATABITS = length(data);

err_y = y2 - y;
max_y = max( abs(y) );
nerr_y = err_y / max_y;
nmse_y = mean( nerr_y .* nerr_y );
s = symerr(data,data2); % Check symbol error rate.

fprintf(fid,'file %s has been demodulated\n',FILENAME);
fprintf(fid,'file %s has been demodulated\n',FILENAME2);
fprintf(fid,'databits: %d, error rate: %d\n', DATABITS, s);
fprintf(fid,'normalized MSE: %8.6f\n\n', nmse_y );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%FSK modem (appr. V.23)
FILENAME   = 'modem/fsk2.wav';
FILENAME2  = [DIR,filesep,FILENAME_PREFIX{f},'fsk2.wav'];
MODULATION = 'fsk';
M  = 2;           %Use M-ary modulation
FC = 1600;        %Carrier frequency, Hz
FD = 1600;        %Data rate, bits per second
y  = wavread(FILENAME);
y2 = wavread(FILENAME2);

SCALE = 0.9;
y  = (1/SCALE)*y;
y2 = (1/SCALE)*y2;

N  = length(y);
N2 = length(y2);
if N2<N
    y2 = [y2 ; zeros(N-N2,1)];
elseif N2>N
    y2 = y2(1:N,1);
end

data  = [];
data2 = [];
for i=1:TIMENUM
    ib = 1 + (i-1)*TIMEONE*FD;
    ie = ib + TIMEONE*FD - 1;
    iy  = y (ib:ie);
    iy2 = y2(ib:ie);
    idata  = ddemod(iy, FC,FD,FS,MODULATION,M);
    idata2 = ddemod(iy2,FC,FD,FS,MODULATION,M);
    data  = [data  ; idata ];
    data2 = [data2 ; idata2];
end

DATABITS = length(data);

err_y = y2 - y;
max_y = max( abs(y) );
nerr_y = err_y / max_y;
nmse_y = mean( nerr_y .* nerr_y );
s = symerr(data,data2); % Check symbol error rate.

fprintf(fid,'file %s has been demodulated\n',FILENAME);
fprintf(fid,'file %s has been demodulated\n',FILENAME2);
fprintf(fid,'databits: %d, error rate: %d\n', DATABITS, s);
fprintf(fid,'normalized MSE: %8.6f\n\n', nmse_y );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%PSK-4 modem (appr. V.26)
FILENAME   = 'modem/psk4.wav';
FILENAME2  = [DIR,filesep,FILENAME_PREFIX{f},'psk4.wav'];
MODULATION = 'psk';
M  = 4;           %Use M-ary modulation
FC = 1600;        %Carrier frequency, Hz
FD = 1600;        %Data rate, bits per second
y  = wavread(FILENAME);
y2 = wavread(FILENAME2);

SCALE = 0.9;
y  = (1/SCALE)*y;
y2 = (1/SCALE)*y2;

N  = length(y);
N2 = length(y2);
if N2<N
    y2 = [y2 ; zeros(N-N2,1)];
elseif N2>N
    y2 = y2(1:N,1);
end

data  = [];
data2 = [];
for i=1:TIMENUM
    ib = 1 + (i-1)*TIMEONE*FD;
    ie = ib + TIMEONE*FD - 1;
    iy  = y (ib:ie);
    iy2 = y2(ib:ie);
    idata  = ddemod(iy, FC,FD,FS,MODULATION,M);
    idata2 = ddemod(iy2,FC,FD,FS,MODULATION,M);
    data  = [data  ; idata ];
    data2 = [data2 ; idata2];
end

DATABITS = length(data);

err_y = y2 - y;
max_y = max( abs(y) );
nerr_y = err_y / max_y;
nmse_y = mean( nerr_y .* nerr_y );
s = symerr(data,data2); % Check symbol error rate.

fprintf(fid,'file %s has been demodulated\n',FILENAME);
fprintf(fid,'file %s has been demodulated\n',FILENAME2);
fprintf(fid,'databits: %d, error rate: %d\n', DATABITS, s);
fprintf(fid,'normalized MSE: %8.6f\n\n', nmse_y );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%PSK-8 modem (appr. V.27ter)
FILENAME   = 'modem/psk8.wav';
FILENAME2  = [DIR,filesep,FILENAME_PREFIX{f},'psk8.wav'];
MODULATION = 'psk';
M  = 8;           %Use M-ary modulation
FC = 1600;        %Carrier frequency, Hz
FD = 1600;        %Data rate, bits per second
y  = wavread(FILENAME);
y2 = wavread(FILENAME2);

SCALE = 0.9;
y  = (1/SCALE)*y;
y2 = (1/SCALE)*y2;

N  = length(y);
N2 = length(y2);
if N2<N
    y2 = [y2 ; zeros(N-N2,1)];
elseif N2>N
    y2 = y2(1:N,1);
end

data  = [];
data2 = [];
for i=1:TIMENUM
    ib = 1 + (i-1)*TIMEONE*FD;
    ie = ib + TIMEONE*FD - 1;
    iy  = y (ib:ie);
    iy2 = y2(ib:ie);
    idata  = ddemod(iy, FC,FD,FS,MODULATION,M);
    idata2 = ddemod(iy2,FC,FD,FS,MODULATION,M);
    data  = [data  ; idata ];
    data2 = [data2 ; idata2];
end

DATABITS = length(data);

err_y = y2 - y;
max_y = max( abs(y) );
nerr_y = err_y / max_y;
nmse_y = mean( nerr_y .* nerr_y );
s = symerr(data,data2); % Check symbol error rate.

fprintf(fid,'file %s has been demodulated\n',FILENAME);
fprintf(fid,'file %s has been demodulated\n',FILENAME2);
fprintf(fid,'databits: %d, error rate: %d\n', DATABITS, s);
fprintf(fid,'normalized MSE: %8.6f\n\n', nmse_y );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%QASK-16 modem (appr. V.29 and V.32)
FILENAME   = 'modem/qask16.wav';
FILENAME2  = [DIR,filesep,FILENAME_PREFIX{f},'qask16.wav'];
MODULATION = 'qask';
M  = 16;          %Use M-ary modulation
FC = 1600;        %Carrier frequency, Hz
FD = 1600;        %Data rate, bits per second
y  = wavread(FILENAME);
y2 = wavread(FILENAME2);

SCALE = (1/sqrt(2))*(1/3);
y  = (1/SCALE)*y;
y2 = (1/SCALE)*y2;

N  = length(y);
N2 = length(y2);
if N2<N
    y2 = [y2 ; zeros(N-N2,1)];
elseif N2>N
    y2 = y2(1:N,1);
end

data  = [];
data2 = [];
for i=1:TIMENUM
    ib = 1 + (i-1)*TIMEONE*FD;
    ie = ib + TIMEONE*FD - 1;
    iy  = y (ib:ie);
    iy2 = y2(ib:ie);
    idata  = ddemod(iy, FC,FD,FS,MODULATION,M);
    idata2 = ddemod(iy2,FC,FD,FS,MODULATION,M);
    data  = [data  ; idata ];
    data2 = [data2 ; idata2];
end

DATABITS = length(data);

err_y = y2 - y;
max_y = max( abs(y) );
nerr_y = err_y / max_y;
nmse_y = mean( nerr_y .* nerr_y );
s = symerr(data,data2); % Check symbol error rate.

fprintf(fid,'file %s has been demodulated\n',FILENAME);
fprintf(fid,'file %s has been demodulated\n',FILENAME2);
fprintf(fid,'databits: %d, error rate: %d\n', DATABITS, s);
fprintf(fid,'normalized MSE: %8.6f\n\n', nmse_y );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%QASK-32 modem (appr. V.33)
FILENAME   = 'modem/qask32.wav';
FILENAME2  = [DIR,filesep,FILENAME_PREFIX{f},'qask32.wav'];
MODULATION = 'qask';
M  = 32;          %Use M-ary modulation
FC = 1600;        %Carrier frequency, Hz
FD = 1600;        %Data rate, bits per second
y  = wavread(FILENAME);
y2 = wavread(FILENAME2);

SCALE = (1/sqrt(2))*(1/5);
y  = (1/SCALE)*y;
y2 = (1/SCALE)*y2;

N  = length(y);
N2 = length(y2);
if N2<N
    y2 = [y2 ; zeros(N-N2,1)];
elseif N2>N
    y2 = y2(1:N,1);
end

data  = [];
data2 = [];
for i=1:TIMENUM
    ib = 1 + (i-1)*TIMEONE*FD;
    ie = ib + TIMEONE*FD - 1;
    iy  = y (ib:ie);
    iy2 = y2(ib:ie);
    idata  = ddemod(iy, FC,FD,FS,MODULATION,M);
    idata2 = ddemod(iy2,FC,FD,FS,MODULATION,M);
    data  = [data  ; idata ];
    data2 = [data2 ; idata2];
end

DATABITS = length(data);

err_y = y2 - y;
max_y = max( abs(y) );
nerr_y = err_y / max_y;
nmse_y = mean( nerr_y .* nerr_y );
s = symerr(data,data2); % Check symbol error rate.

fprintf(fid,'file %s has been demodulated\n',FILENAME);
fprintf(fid,'file %s has been demodulated\n',FILENAME2);
fprintf(fid,'databits: %d, error rate: %d\n', DATABITS, s);
fprintf(fid,'normalized MSE: %8.6f\n\n', nmse_y );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%QASK-64 modem (appr.V.34)
FILENAME   = 'modem/qask64.wav';
FILENAME2  = [DIR,filesep,FILENAME_PREFIX{f},'qask64.wav'];
MODULATION = 'qask';
M  = 64;          %Use M-ary modulation
FC = 1600;        %Carrier frequency, Hz
FD = 1600;        %Data rate, bits per second
y  = wavread(FILENAME);
y2 = wavread(FILENAME2);

SCALE = (1/sqrt(2))*(1/7);
y  = (1/SCALE)*y;
y2 = (1/SCALE)*y2;

N  = length(y);
N2 = length(y2);
if N2<N
    y2 = [y2 ; zeros(N-N2,1)];
elseif N2>N
    y2 = y2(1:N,1);
end

data  = [];
data2 = [];
for i=1:TIMENUM
    ib = 1 + (i-1)*TIMEONE*FD;
    ie = ib + TIMEONE*FD - 1;
    iy  = y (ib:ie);
    iy2 = y2(ib:ie);
    idata  = ddemod(iy, FC,FD,FS,MODULATION,M);
    idata2 = ddemod(iy2,FC,FD,FS,MODULATION,M);
    data  = [data  ; idata ];
    data2 = [data2 ; idata2];
end

DATABITS = length(data);

err_y = y2 - y;
max_y = max( abs(y) );
nerr_y = err_y / max_y;
nmse_y = mean( nerr_y .* nerr_y );
s = symerr(data,data2); % Check symbol error rate.

fprintf(fid,'file %s has been demodulated\n',FILENAME);
fprintf(fid,'file %s has been demodulated\n',FILENAME2);
fprintf(fid,'databits: %d, error rate: %d\n', DATABITS, s);
fprintf(fid,'normalized MSE: %8.6f\n\n', nmse_y );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

fprintf(fid,'finished!\n');

if fid~=1
    fclose(fid);
end

disp('finished!');

