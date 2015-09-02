%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mycodec decoder function initialization (table version)
% [dec] = decoder_init( FIXP )
% GLOBALS:
%   MAXX
%   FACTOR
%   SAMPLES_PER_FRAME
%   BITS_PER_SAMPLE
%   SMOOTH_N
%   SMOOTH_ERROR_VER
%   COM_PWR
%   EXP_PWR
% INPUTS:
%   FIXP  = constant of fixed-point arithmetics
% OUTPUTS:
%   dec   = decoder structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [dec] = decoder2_init()

    global FIXP;
    global MAXX;
    global FACTOR;
    global SAMPLES_PER_FRAME;
    global BITS_PER_SAMPLE;
    global SMOOTH_N;
    global SMOOTH_ERROR_VER;
    global COM_PWR;
    global EXP_PWR;

    % set settings of decoder

    % fill table for 1/voicediff_n, where voicediff_n=[0..2*MAXX]
    % values=[0..FIXP],  0<=>0.0  FIXP<=>1.0
    dec.divtable = zeros(1,2*MAXX+1);
    dec.divtable(1) = 0;
    for div=1:1:2*MAXX
        %this decrease error of integer division see decoder2():
        if div <= (2*MAXX)/256
            dec.divtable(div+1) = fix( FIXP/div ); %K=1
        else
            dec.divtable(div+1) = fix( FIXP/(div/256) ); %K=256
        end
    end

    % fill tables
    % inputs=[0..(FACTOR-1)]
    % returns=[-FIXP..+FIXP]
    dec.table = zeros(SMOOTH_N,FACTOR);
    for s=1:SMOOTH_N
        for dv=0:(FACTOR-1)
            sss = expand( 2*((dv+0.5)/FACTOR - 0.5) , s );
            dec.table(s,dv+1) = round(sss * FIXP);
        end
    end

return
