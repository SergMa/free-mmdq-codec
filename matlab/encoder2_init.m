%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MMDQ encoder function initialization (table version)
% [enc] = encoder_init( FIXP )
% GLOBALS:
%   FIXP
%   MAXX
%   FACTOR
%   SAMPLES_PER_FRAME
%   BITS_PER_SAMPLE
%   SMOOTH_N
%   SMOOTH_ERROR_VER
%   COM_PWR
%   EXP_PWR
% INPUTS:
%   ---
% OUTPUTS:
%   enc   = encoder structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [enc] = encoder2_init()

    global FIXP;
    global MAXX;
    global FACTOR;
    global SAMPLES_PER_FRAME;
    global BITS_PER_SAMPLE;
    global SMOOTH_N;
    global SMOOTH_ERROR_VER;
    global COM_PWR;
    global EXP_PWR;

    % fill table for 1/ampdv, where ampdv=[0..2*maxx]
    % values=[0..FIXP],  0<=>0.0  FIXP<=>1.0
    enc.divtable = zeros(1,2*MAXX+1);
    enc.divtable(1) = 0;
    for div=1:1:2*MAXX
        %this decrease error of integer division see encoder2():
        if div <= (2*MAXX)/256
            enc.divtable(div+1) = fix( FIXP/div );
        else
            enc.divtable(div+1) = fix( FIXP/(div/256) );
        end
    end

    % encode tables
    % inputs=dvoice/ampdv = [-FIXP..+FIXP]
    % values=[0..(FACTOR-1)]

    enc.table = zeros(SMOOTH_N,2*FIXP+1);
    for s=1:SMOOTH_N
        for a=-FIXP:1:FIXP
            sss = compand( a/FIXP, s ); %sss=[-FIXP..+FIXP]
            ddd = FACTOR/2 * sss + FACTOR/2;
            ddd = fix(ddd);
            ddd = min(ddd,FACTOR-1);
            enc.table( s, a+FIXP+1 ) = fix( ddd );
        end
    end

return
