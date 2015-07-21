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

DIR = 'modem';
LOGFILENAME = [DIR,filesep,'generation.log'];

disp('started!');

fid = fopen(LOGFILENAME,'w');
fprintf(fid,'modems signals generation started!');

FS = 8000; %Sample rate, Hz

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ASK modem
FILENAME   = [DIR,filesep,'ask2.wav'];
MODULATION = 'ask';
M  = 2;           %Use M-ary modulation
FC = 1600;        %Carrier frequency, Hz
FD = 1600;        %Data rate, words per second (for M=2 equals to bits/sec)
DATABITS = 10*FD; %10 sec
data = randint(DATABITS,1,M); % Random digital message
y = dmod(data,FC,FD,FS,MODULATION,M); % Generate signal
y = 0.9*y;        %limit amplitude for no-clipping in wavwrite()
wavwrite(y,FS,FILENAME);

data2 = ddemod(y,FC,FD,FS,MODULATION,M);
s = symerr(data,data2); % Check symbol error rate.
fprintf(fid,'file %s has been generated\n',FILENAME);
fprintf(fid,'databits: %d, error rate: %d\n', DATABITS, s);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%FSK modem (appr. V.23)
FILENAME   = [DIR,filesep,'fsk2.wav'];
MODULATION = 'fsk';
M  = 2;           %Use M-ary modulation
FC = 1600;        %Carrier frequency, Hz
FD = 1600;        %Data rate, words per second (for M=2 equals to bits/sec)
DATABITS = 10*FD; %10 sec
data = randint(DATABITS,1,M); % Random digital message
y = dmod(data,FC,FD,FS,MODULATION,M); % Generate signal
y = 0.9*y;
wavwrite(y,FS,FILENAME);

data2 = ddemod(y,FC,FD,FS,MODULATION,M);
s = symerr(data,data2); % Check symbol error rate.
fprintf(fid,'file %s has been generated\n',FILENAME);
fprintf(fid,'databits: %d, error rate: %d\n', DATABITS, s);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%PSK-4 modem (appr. V.26)
FILENAME   = [DIR,filesep,'psk4.wav'];
MODULATION = 'psk';
M  = 4;           %Use M-ary modulation
FC = 1600;        %Carrier frequency, Hz
FD = 1600;        %Data rate, words per second (for M=4 equals to 2*bits/sec)
DATABITS = 10*FD; %10 sec
data = randint(DATABITS,1,M); % Random digital message
y = dmod(data,FC,FD,FS,MODULATION,M); % Generate signal
y = 0.9*y;
wavwrite(y,FS,FILENAME);

data2 = ddemod(y,FC,FD,FS,MODULATION,M);
s = symerr(data,data2); % Check symbol error rate.
fprintf(fid,'file %s has been generated\n',FILENAME);
fprintf(fid,'databits: %d, error rate: %d\n', DATABITS, s);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%PSK-8 modem (appr. V.27ter)
FILENAME   = [DIR,filesep,'psk8.wav'];
MODULATION = 'psk';
M  = 8;           %Use M-ary modulation
FC = 1600;        %Carrier frequency, Hz
FD = 1600;        %Data rate, words per second (for M=8 equals to 3*bits/sec)
DATABITS = 10*FD; %10 sec
data = randint(DATABITS,1,M); % Random digital message
y = dmod(data,FC,FD,FS,MODULATION,M); % Generate signal
y = 0.9*y;
wavwrite(y,FS,FILENAME);

data2 = ddemod(y,FC,FD,FS,MODULATION,M);
s = symerr(data,data2); % Check symbol error rate.
fprintf(fid,'file %s has been generated\n',FILENAME);
fprintf(fid,'databits: %d, error rate: %d\n', DATABITS, s);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%QASK-16 modem (appr. V.29 and V.32)
FILENAME   = [DIR,filesep,'qask16.wav'];
MODULATION = 'qask';
M  = 16;           %Use M-ary modulation
FC = 1600;        %Carrier frequency, Hz
FD = 1600;        %Data rate, words per second (for M=16 equals to 4*bits/sec)
DATABITS = 10*FD; %10 sec
data = randint(DATABITS,1,M); % Random digital message
y = dmod(data,FC,FD,FS,MODULATION,M); % Generate signal

SCALE = (1/sqrt(2))*(1/3);
y = SCALE*y;
wavwrite(y,FS,FILENAME);

data2 = ddemod(y*(1/SCALE),FC,FD,FS,MODULATION,M);
s = symerr(data,data2); % Check symbol error rate.
fprintf(fid,'file %s has been generated\n',FILENAME);
fprintf(fid,'databits: %d, error rate: %d\n', DATABITS, s);

%qaskenco(M);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%QASK-32 modem (appr. V.33)
FILENAME   = [DIR,filesep,'qask32.wav'];
MODULATION = 'qask';
M  = 32;          %Use M-ary modulation
FC = 1600;        %Carrier frequency, Hz
FD = 1600;        %Data rate, words per second (for M=32 equals to 5*bits/sec)
DATABITS = 10*FD; %10 sec
data = randint(DATABITS,1,M); % Random digital message
y = dmod(data,FC,FD,FS,MODULATION,M); % Generate signal

SCALE = (1/sqrt(2))*(1/5);
y = SCALE*y;
wavwrite(y,FS,FILENAME);

data2 = ddemod(y*(1/SCALE),FC,FD,FS,MODULATION,M);
s = symerr(data,data2); % Check symbol error rate.
fprintf(fid,'file %s has been generated\n',FILENAME);
fprintf(fid,'databits: %d, error rate: %d\n', DATABITS, s);

%qaskenco(M);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%QASK-64 modem (appr.V.34)
FILENAME   = [DIR,filesep,'qask64.wav'];
MODULATION = 'qask';
M  = 64;          %Use M-ary modulation
FC = 1600;        %Carrier frequency, Hz
FD = 1600;        %Data rate, words per second (for M=64 equals to 6*bits/sec)
DATABITS = 10*FD; %10 sec
data = randint(DATABITS,1,M); % Random digital message
y = dmod(data,FC,FD,FS,MODULATION,M); % Generate signal

SCALE = (1/sqrt(2))*(1/7);
y = SCALE*y;
wavwrite(y,FS,FILENAME);

data2 = ddemod(y*(1/SCALE),FC,FD,FS,MODULATION,M);
s = symerr(data,data2); % Check symbol error rate.
fprintf(fid,'file %s has been generated\n',FILENAME);
fprintf(fid,'databits: %d, error rate: %d\n', DATABITS, s);

%qaskenco(M);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf(fid,'finished!\n');
fclose(fid);

disp('finished!');
