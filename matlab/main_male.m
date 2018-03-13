%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test script to measure quality of male voice                                 %
% main_male.m                                                                  %
%                                                                              %
% (c) Sergei Mashkin, 2015                                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
clear all;
close all;

disp('started!');

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

FILES = length(FILENAME_PREFIX);

NAME = 'male.wav';
DIR  = 'male';

LOGFILENAME = [DIR,filesep,'male.log'];
fid=1;
fid = fopen(LOGFILENAME,'w'); %uncomment this to use file instead of stdout
if fid==-1
    fid = 1;
    fprintf(fid,'Error: could not create results file: %s\n', LOGFILENAME);
end

FILENAME = [DIR,filesep,NAME];
y = wavread(FILENAME);
N = length(y);

fprintf(fid,'-----------------\n', N);
fprintf(fid,'original file: %s\n', FILENAME);
fprintf(fid,'samples: %d\n', N);
fprintf(fid,'-----------------\n\n', N);

max_y = max( abs(y) );

for i=1:FILES
   
    FILENAME2  = [DIR,filesep,FILENAME_PREFIX{i},NAME];

    y2 = wavread(FILENAME2);
    
    N2 = length(y2);
    if N2<N
        y2 = [y2 ; zeros(N-N2,1)];
    elseif N2>N
        y2 = y2(1:N,1);
    end

    nerr = (y2 - y)/max_y;

    fprintf(fid,'file2: %s\n', FILENAME2);
    fprintf(fid,'normalized MSE: %10.8f\n\n', mean( nerr.*nerr ) );

end

if fid~=1
    fclose(fid);
end

disp('finished!');
