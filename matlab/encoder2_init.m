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

    % fill table for 2*maxx*maxx/div, where div=[0...2*maxx]
    % values=[0..maxx]
    enc.divtable = zeros(1,2*maxx+1);
    enc.divtable(1) = 0;
    for div=1:1:2*maxx
        enc.divtable(div+1) = fix( 2*maxx*maxx/div );
    end

    % encode tables
    % inputs=dvoice/ampdv = [-maxx..+maxx]
    % values=[0..(enc.factor-1)]

    enc.table0 = zeros(1,2*maxx+1);
    for a=-maxx:1:maxx
        b = a + maxx; %b=[0..2*maxx]
        sss = round( enc.factor * b / (2*maxx) );
        if sss > (enc.factor-1)
            sss = enc.factor-1;
        end
        enc.table0( a+maxx+1 ) = sss;
    end

    enc.table1 = zeros(1,2*maxx+1);
    for a=-maxx:1:maxx
        b = fix( maxx*compand(a/maxx,1) ) + maxx; %b=[0..2*maxx]
        sss = round( enc.factor * b / (2*maxx) );
        if sss > (enc.factor-1)
            sss = enc.factor-1;
        end
        enc.table1( a+maxx+1 ) = sss;
    end

    enc.table2 = zeros(1,2*maxx+1);
    for a=-maxx:1:maxx
        b = fix( maxx*compand(a/maxx,1) ) + maxx; %b=[0..2*maxx]
        sss = round( enc.factor * b / (2*maxx) );
        if sss > (enc.factor-1)
            sss = enc.factor-1;
        end
        enc.table2( a+maxx+1 ) = sss;
    end

    enc.table3 = zeros(1,2*maxx+1);
    for a=-maxx:1:maxx
        b = fix( maxx*compand(a/maxx,1) ) + maxx; %b=[0..2*maxx]
        sss = round( enc.factor * b / (2*maxx) );
        if sss > (enc.factor-1)
            sss = enc.factor-1;
        end
        enc.table3( a+maxx+1 ) = sss;
    end

return
