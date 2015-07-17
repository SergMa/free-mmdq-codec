%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate best integer constant for dec.table(i)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
clear all;
close all;

FACTOR = 2^3;
MINK = 1;
MAXK = 32768;

bestK = MINK;
errK = -1;

for K=MINK:1:MAXK

    err = 0;
    for s=0:3
    for dv=0:(FACTOR-1)
        sss = expand( (dv+0.5)/FACTOR - 0.5 , s );
        sssf = sss*K;
        sssi = round(sss*K);
        err = err + abs(sssf-sssi)/K;
    end
    end

    %fprintf(1,'K=%8d, errK=%10.6f\n', K, errK);

    if errK<0 || err<errK
        errK = err;
        bestK = K;
    end

end

fprintf(1,'FACTOR=%d, bestK=%d,  errK=%10.6f\n', FACTOR, bestK, errK);
