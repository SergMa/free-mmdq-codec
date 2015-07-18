%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mycodec encoder function initialization (table version)
% [enc] = encoder_init( samples_per_frame, bits_per_sample )
% INPUTS:
%   samples_per_frame = number of voice samples per frame
%   bits_per_sample   = number of bits per sample
%   maxx              = amplitude of signal: signal=[-maxx...+maxx]
%   FIXP  = constant of fixed-point arithmetics
% OUTPUTS:
%   enc   = encoder structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [enc] = encoder2_init( samples_per_frame, bits_per_sample, maxx, FIXP )

    % set settings of encoder
    enc.samples_per_frame = samples_per_frame;
    enc.bits_per_sample   = bits_per_sample;
    enc.factor            = 2^bits_per_sample;
    enc.maxx              = maxx;

    % fill table for 1/ampdv, where ampdv=[0..2*maxx]
    % values=[0..FIXP],  0<=>0.0  FIXP<=>1.0
    enc.divtable = zeros(1,2*maxx+1);
    enc.divtable(1) = 0;
    for div=1:1:2*maxx
        %this decrease error of integer division see encoder2():
        if div <= (2*maxx)/256
            enc.divtable(div+1) = fix( FIXP/div );
        else
            enc.divtable(div+1) = fix( FIXP/(div/256) );
        end
    end

    % encode tables
    % inputs=dvoice/ampdv = [-FIXP..+FIXP]
    % values=[0..(enc.factor-1)]

    enc.table0 = zeros(1,2*FIXP+1);
    for a=-FIXP:1:FIXP
        sss = compand( a/FIXP, 0 ); %sss=[-FIXP..+FIXP]
        ddd = enc.factor/2 * sss + enc.factor/2;
        ddd = fix(ddd);
        ddd = min(ddd,enc.factor-1);
        enc.table0( a+FIXP+1 ) = fix( ddd );
    end

    enc.table1 = zeros(1,2*FIXP+1);
    for a=-FIXP:1:FIXP
        sss = compand( a/FIXP, 1 ); %sss=[-FIXP..+FIXP]
        ddd = enc.factor/2 * sss + enc.factor/2;
        ddd = fix(ddd);
        ddd = min(ddd,enc.factor-1);
        enc.table1( a+FIXP+1 ) = fix( ddd );
    end

    enc.table2 = zeros(1,2*FIXP+1);
    for a=-FIXP:1:FIXP
        sss = compand( a/FIXP, 2 ); %sss=[-FIXP..+FIXP]
        ddd = enc.factor/2 * sss + enc.factor/2;
        ddd = fix(ddd);
        ddd = min(ddd,enc.factor-1);
        enc.table2( a+FIXP+1 ) = fix( ddd );
    end

    enc.table3 = zeros(1,2*FIXP+1);
    for a=-FIXP:1:FIXP
        sss = compand( a/FIXP, 3 ); %sss=[-FIXP..+FIXP]
        ddd = enc.factor/2 * sss + enc.factor/2;
        ddd = fix(ddd);
        ddd = min(ddd,enc.factor-1);
        enc.table3( a+FIXP+1 ) = fix( ddd );
    end

return
