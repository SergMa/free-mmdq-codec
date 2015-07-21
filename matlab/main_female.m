%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test script to measure quality of female voice                               %
% main_female.m                                                                %
%                                                                              %
% (c) Sergei Mashkin, 2015                                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
clear all;
close all;

disp('started!');

FILENAME_PREFIX = {'mmdq-40_'     ;
                   'mmdq-40nosm_' ;
                   'mmdq-40x_'    ;
                   'mmdq-40xnosm_';
                   'mmdq-32_'     ;
                   'mmdq-32nosm_' ;
                   'g726-40_'     ;
                   'g726-32_'     ;
                   'g711-alaw_'   ;
                   'g711-ulaw_'   };

FILES = size(FILENAME_PREFIX,1);

NAME = 'female.wav';
DIR  = 'female';

LOGFILENAME = [DIR,filesep,NAME,'_voice.log'];
fid = fopen(LOGFILENAME,'w');

FILENAME = [DIR,filesep,NAME];
y = wavread(FILENAME);
N = length(y);

fprintf(fid,'-----------------\n', N);
fprintf(fid,'original file: %s\n', FILENAME);
fprintf(fid,'samples: %d\n', N);
fprintf(fid,'-----------------\n\n', N);

for i=1:FILES
   
    FILENAME2  = [DIR,filesep,FILENAME_PREFIX{i},NAME];

    y2 = wavread(FILENAME2);
    
    N2 = length(y2);
    if N2<N
        y2 = [y2 ; zeros(N-N2,1)];
    elseif N2>N
        y2 = y2(1:N,1);
    end

    fprintf(fid,'file2: %s\n', FILENAME2);
    fprintf(fid,'MSE: %10.8f\n\n', mean( (y-y2).^2 ) );

end

fclose(fid);

disp('finished!');
