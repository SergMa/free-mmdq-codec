%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mycodec encoder function initialization (table version)
% [enc] = encoder_init( samples_per_frame, bits_per_sample )
% INPUTS:
%   samples_per_frame = number of voice samples per frame
%   bits_per_sample   = number of bits per sample
%   maxx              = amplitude of signal: signal=[-maxx...+maxx]
% OUTPUTS:
%   enc   = encoder structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [enc] = encoder2_init( samples_per_frame, bits_per_sample, maxx )

    % set settings of encoder
    enc.samples_per_frame = samples_per_frame;
    enc.bits_per_sample   = bits_per_sample;
    enc.factor            = 2^bits_per_sample;
    enc.maxx              = maxx;

    % fill table for 1/div, where div=[0...2*maxx*1024]
    % values=[0..2*maxx]
    enc.divtable = zeros(1,2*maxx+1);
    for div=0:1:2*maxx
        if div>0
            enc.divtable(div+1) = 2*maxx*1024/div;  % 0.0=0 , 1.0=2*maxx*1024
        else
            enc.divtable(div+1) = 0;
        end
    end

    % encode tables
    % dvoice/ampdv = dvoice*(1/ampdv) = [-maxx..+maxx]*[0..+32768]/32768 = [-maxx..+maxx]
    % values=[0..enc.factor]

    enc.table0 = zeros(1,4*maxx+1);
    for a=-2*maxx:1:2*maxx
        sss = a/(2*maxx);
        enc.table0( a+2*maxx+1 ) = fix( enc.factor/2 * sss + enc.factor/2 ); % TODO: correct formulae to better use of dynamic range from [-1..+1]
    end

    enc.table1 = zeros(1,4*maxx+1);
    for a=-2*maxx:1:2*maxx
        sss = compand( a/(2*maxx) , 1 );
        enc.table1( a+2*maxx+1 ) = fix( enc.factor/2 * sss + enc.factor/2 );
    end

    enc.table2 = zeros(1,4*maxx+1);
    for a=-2*maxx:1:2*maxx
        sss = compand( a/(2*maxx) , 2 );
        enc.table2( a+2*maxx+1 ) = fix( enc.factor/2 * sss + enc.factor/2 );
    end

    enc.table3 = zeros(1,4*maxx+1);
    for a=-2*maxx:1:2*maxx
        sss = compand( a/(2*maxx) , 3 );
        enc.table3( a+2*maxx+1 ) = fix( enc.factor/2 * sss + enc.factor/2 );
    end

return
