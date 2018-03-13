%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test script to generate modems wave-files and data-test                      %
% main_modem_generate.m                                                        %
%                                                                              %
% This code needs MATLAB Communication Toolbox                                 %
%                                                                              %
% (c) Sergei Mashkin, 2015                                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
clear all;
close all;

TIMEONE = 10;  %single loop length, sec
TIMENUM = 60;  %number of loops
TIMELEN = TIMENUM * TIMEONE;

DIR = 'modem';
LOGFILENAME = [DIR,filesep,'generation.log'];

disp('started!');

fid = 1;
fid = fopen(LOGFILENAME,'w'); %uncomment this to use file instead of stdout
if fid==-1
    fid = 1;
    fprintf(fid,'Error: could not create results file: %s\n', LOGFILENAME);
end

fprintf(fid,'modems signals generation started!');

FS = 8000; %Sample rate, Hz

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ASK modem
FILENAME   = [DIR,filesep,'ask2.wav'];
MODULATION = 'ask';
M  = 2;           %Use M-ary modulation
FC = 1600;        %Carrier frequency, Hz
FD = 1600;        %Data rate, words per second (for M=2 equals to bits/sec)
DATABITS = TIMELEN*FD;
SCALE = 0.9;
data = randint(DATABITS,1,M); % Random digital message

y = [];
data2 = [];
for i=1:TIMENUM
    ib = 1 + (i-1)*TIMEONE*FD;
    ie = ib + TIMEONE*FD - 1;
    idata = data(ib:ie);
    iy = dmod(idata,FC,FD,FS,MODULATION,M); % Generate signal
    iy = SCALE*iy;  %limit amplitude for no-clipping in wavwrite()
    y = [y;iy];
    idata2 = ddemod((1/SCALE)*iy,FC,FD,FS,MODULATION,M);
    data2 = [data2;idata2];
end

s = symerr(data,data2); % Check symbol error rate.
wavwrite(y,FS,FILENAME);
fprintf(fid,'file %s has been generated\n',FILENAME);
fprintf(fid,'databits: %d, error rate: %d\n', DATABITS, s);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%FSK modem (appr. V.23)
FILENAME   = [DIR,filesep,'fsk2.wav'];
MODULATION = 'fsk';
M  = 2;           %Use M-ary modulation
FC = 1600;        %Carrier frequency, Hz
FD = 1600;        %Data rate, words per second (for M=2 equals to bits/sec)
DATABITS = TIMELEN*FD;
SCALE = 0.9;
data = randint(DATABITS,1,M); % Random digital message

y = [];
data2 = [];
for i=1:TIMENUM
    ib = 1 + (i-1)*TIMEONE*FD;
    ie = ib + TIMEONE*FD - 1;
    idata = data(ib:ie);
    iy = dmod(idata,FC,FD,FS,MODULATION,M); % Generate signal
    iy = SCALE*iy;  %limit amplitude for no-clipping in wavwrite()
    y = [y;iy];
    idata2 = ddemod((1/SCALE)*iy,FC,FD,FS,MODULATION,M);
    data2 = [data2;idata2];
end

s = symerr(data,data2); % Check symbol error rate.
wavwrite(y,FS,FILENAME);
fprintf(fid,'file %s has been generated\n',FILENAME);
fprintf(fid,'databits: %d, error rate: %d\n', DATABITS, s);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%PSK-4 modem (appr. V.26)
FILENAME   = [DIR,filesep,'psk4.wav'];
MODULATION = 'psk';
M  = 4;           %Use M-ary modulation
FC = 1600;        %Carrier frequency, Hz
FD = 1600;        %Data rate, words per second (for M=4 equals to 2*bits/sec)
DATABITS = TIMELEN*FD;
SCALE = 0.9;
data = randint(DATABITS,1,M); % Random digital message

y = [];
data2 = [];
for i=1:TIMENUM
    ib = 1 + (i-1)*TIMEONE*FD;
    ie = ib + TIMEONE*FD - 1;
    idata = data(ib:ie);
    iy = dmod(idata,FC,FD,FS,MODULATION,M); % Generate signal
    iy = SCALE*iy;  %limit amplitude for no-clipping in wavwrite()
    y = [y;iy];
    idata2 = ddemod((1/SCALE)*iy,FC,FD,FS,MODULATION,M);
    data2 = [data2;idata2];
end

s = symerr(data,data2); % Check symbol error rate.
wavwrite(y,FS,FILENAME);
fprintf(fid,'file %s has been generated\n',FILENAME);
fprintf(fid,'databits: %d, error rate: %d\n', DATABITS, s);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%PSK-8 modem (appr. V.27ter)
FILENAME   = [DIR,filesep,'psk8.wav'];
MODULATION = 'psk';
M  = 8;           %Use M-ary modulation
FC = 1600;        %Carrier frequency, Hz
FD = 1600;        %Data rate, words per second (for M=8 equals to 3*bits/sec)
DATABITS = TIMELEN*FD;
SCALE = 0.9;
data = randint(DATABITS,1,M); % Random digital message

y = [];
data2 = [];
for i=1:TIMENUM
    ib = 1 + (i-1)*TIMEONE*FD;
    ie = ib + TIMEONE*FD - 1;
    idata = data(ib:ie);
    iy = dmod(idata,FC,FD,FS,MODULATION,M); % Generate signal
    iy = SCALE*iy;  %limit amplitude for no-clipping in wavwrite()
    y = [y;iy];
    idata2 = ddemod((1/SCALE)*iy,FC,FD,FS,MODULATION,M);
    data2 = [data2;idata2];
end

s = symerr(data,data2); % Check symbol error rate.
wavwrite(y,FS,FILENAME);
fprintf(fid,'file %s has been generated\n',FILENAME);
fprintf(fid,'databits: %d, error rate: %d\n', DATABITS, s);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%QASK-16 modem (appr. V.29 and V.32)
FILENAME   = [DIR,filesep,'qask16.wav'];
MODULATION = 'qask';
M  = 16;           %Use M-ary modulation
FC = 1600;        %Carrier frequency, Hz
FD = 1600;        %Data rate, words per second (for M=16 equals to 4*bits/sec)
DATABITS = TIMELEN*FD;
SCALE = (1/sqrt(2))*(1/3);
data = randint(DATABITS,1,M); % Random digital message

y = [];
data2 = [];
for i=1:TIMENUM
    ib = 1 + (i-1)*TIMEONE*FD;
    ie = ib + TIMEONE*FD - 1;
    idata = data(ib:ie);
    iy = dmod(idata,FC,FD,FS,MODULATION,M); % Generate signal
    iy = SCALE*iy;  %limit amplitude for no-clipping in wavwrite()
    y = [y;iy];
    idata2 = ddemod((1/SCALE)*iy,FC,FD,FS,MODULATION,M);
    data2 = [data2;idata2];
end

s = symerr(data,data2); % Check symbol error rate.
wavwrite(y,FS,FILENAME);
fprintf(fid,'file %s has been generated\n',FILENAME);
fprintf(fid,'databits: %d, error rate: %d\n', DATABITS, s);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%QASK-32 modem (appr. V.33)
FILENAME   = [DIR,filesep,'qask32.wav'];
MODULATION = 'qask';
M  = 32;          %Use M-ary modulation
FC = 1600;        %Carrier frequency, Hz
FD = 1600;        %Data rate, words per second (for M=32 equals to 5*bits/sec)
DATABITS = TIMELEN*FD;
SCALE = (1/sqrt(2))*(1/5);
data = randint(DATABITS,1,M); % Random digital message

y = [];
data2 = [];
for i=1:TIMENUM
    ib = 1 + (i-1)*TIMEONE*FD;
    ie = ib + TIMEONE*FD - 1;
    idata = data(ib:ie);
    iy = dmod(idata,FC,FD,FS,MODULATION,M); % Generate signal
    iy = SCALE*iy;  %limit amplitude for no-clipping in wavwrite()
    y = [y;iy];
    idata2 = ddemod((1/SCALE)*iy,FC,FD,FS,MODULATION,M);
    data2 = [data2;idata2];
end

s = symerr(data,data2); % Check symbol error rate.
wavwrite(y,FS,FILENAME);
fprintf(fid,'file %s has been generated\n',FILENAME);
fprintf(fid,'databits: %d, error rate: %d\n', DATABITS, s);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%QASK-64 modem (appr.V.34)
FILENAME   = [DIR,filesep,'qask64.wav'];
MODULATION = 'qask';
M  = 64;          %Use M-ary modulation
FC = 1600;        %Carrier frequency, Hz
FD = 1600;        %Data rate, words per second (for M=64 equals to 6*bits/sec)
DATABITS = TIMELEN*FD;
SCALE = (1/sqrt(2))*(1/7);
data = randint(DATABITS,1,M); % Random digital message

y = [];
data2 = [];
for i=1:TIMENUM
    ib = 1 + (i-1)*TIMEONE*FD;
    ie = ib + TIMEONE*FD - 1;
    idata = data(ib:ie);
    iy = dmod(idata,FC,FD,FS,MODULATION,M); % Generate signal
    iy = SCALE*iy;  %limit amplitude for no-clipping in wavwrite()
    y = [y;iy];
    idata2 = ddemod((1/SCALE)*iy,FC,FD,FS,MODULATION,M);
    data2 = [data2;idata2];
end

s = symerr(data,data2); % Check symbol error rate.
wavwrite(y,FS,FILENAME);
fprintf(fid,'file %s has been generated\n',FILENAME);
fprintf(fid,'databits: %d, error rate: %d\n', DATABITS, s);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf(fid,'finished!\n');

if fid~=1
    fclose(fid);
end

disp('finished!');

