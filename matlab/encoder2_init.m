%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mycodec encoder function initialization (table version)
% [enc] = encoder_init( samples_per_frame, bits_per_sample )
% INPUTS:
%   samples_per_frame = number of voice samples per frame
%   bits_per_sample   = number of bits per sample
% OUTPUTS:
%   enc   = encoder structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [enc] = encoder2_init( samples_per_frame, bits_per_sample )

    % set settings of encoder
    enc.samples_per_frame = samples_per_frame;
    enc.bits_per_sample   = bits_per_sample;
    enc.factor            = 2^enc.bits_per_sample;

    % fill table for 1/div, where div=[0...1024]
    enc.divtable = zeros(1,1+1024);
    for div=0:1:+1024
        if div>0
            enc.divtable(div+1) = 32768*1024/div;  % 0.0=0 , 1.0=32768
        else
            enc.divtable(div+1) = 0;
        end
    end

    % dvoice/ampdv = dvoice*(1/ampdv) = [-1024..+1024]*[0..+32768]/32768 = [-1024..+1024]
    enc.table0 = zeros(1,1024+1+1024);
    for a=-1024:1:1024
        sss = a / 1024;
        enc.table0( a+1024+1 ) = round( enc.factor/2 * sss + enc.factor/2 );
    end

    % encode tables
    enc.table1 = zeros(1,1024+1+1024);
    for a=-1024:1:1024
        sss = compand( a/1024 , 1 );
        enc.table1( a+1024+1 ) = round( enc.factor/2 * sss + enc.factor/2 );
    end

    enc.table2 = zeros(1,1024+1+1024);
    for a=-1024:1:1024
        sss = compand( a/1024 , 2 );
        enc.table2( a+1024+1 ) = round( enc.factor/2 * sss + enc.factor/2 );
    end

    enc.table3 = zeros(1,1024+1+1024);
    for a=-1024:1:1024
        sss = compand( a/1024 , 3 );
        enc.table3( a+1024+1 ) = round( enc.factor/2 * sss + enc.factor/2 );
    end

return
