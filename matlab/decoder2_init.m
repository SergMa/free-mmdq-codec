%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mycodec decoder function initialization (table version)
% [dec] = decoder_init( samples_per_frame, bits_per_sample )
% INPUTS:
%   samples_per_frame = number of voice samples per frame
%   bits_per_sample   = number of bits per sample
%   maxx              = amplitude of signal: signal=[-maxx...+maxx]
%   FIXP  = constant of fixed-point arithmetics
% OUTPUTS:
%   dec   = decoder structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [dec] = decoder2_init( samples_per_frame, bits_per_sample, maxx, FIXP )

    % set settings of decoder
    dec.samples_per_frame = samples_per_frame;
    dec.bits_per_sample   = bits_per_sample;
    dec.factor            = 2^dec.bits_per_sample;
    dec.maxx              = maxx;

    % fill table for 1/voicediff_n, where voicediff_n=[0..2*maxx]
    % values=[0..FIXP],  0<=>0.0  FIXP<=>1.0
    dec.divtable = zeros(1,2*maxx+1);
    dec.divtable(1) = 0;
    for div=1:1:2*maxx
        %this decrease error of integer division see decoder2():
        if div <= (2*maxx)/256
            dec.divtable(div+1) = fix( FIXP/div ); %K=1
        else
            dec.divtable(div+1) = fix( FIXP/(div/256) ); %K=256
        end
    end

    % fill tables
    % inputs=[0..(dec.factor-1)]
    % returns=[-FIXP..+FIXP]
    dec.table0 = zeros(1,dec.factor);
    for dv=0:(dec.factor-1)
        sss = expand( (dv+0.5)/dec.factor - 0.5 , 0 );
        dec.table0(dv+1) = round(sss * FIXP);
    end

    dec.table1 = zeros(1,dec.factor);
    for dv=0:(dec.factor-1)
        sss = expand( (dv+0.5)/dec.factor - 0.5 , 1 );
        dec.table1(dv+1) = round(sss * FIXP);
    end

    dec.table2 = zeros(1,dec.factor);
    for dv=0:(dec.factor-1)
        sss = expand( (dv+0.5)/dec.factor - 0.5 , 2 );
        dec.table2(dv+1) = round(sss * FIXP);
    end

    dec.table3 = zeros(1,dec.factor);
    for dv=0:(dec.factor-1)
        sss = expand( (dv+0.5)/dec.factor - 0.5 , 3 );
        dec.table3(dv+1) = round(sss * FIXP);
    end

return
