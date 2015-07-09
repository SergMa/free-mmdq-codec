%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mycodec decoder function initialization (table version)
% [dec] = decoder_init( samples_per_frame, bits_per_sample )
% INPUTS:
%   samples_per_frame = number of voice samples per frame
%   bits_per_sample   = number of bits per sample
% OUTPUTS:
%   dec   = decoder structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [dec] = decoder2_init( samples_per_frame, bits_per_sample )

    % set settings of decoder
    dec.samples_per_frame = samples_per_frame;
    dec.bits_per_sample   = bits_per_sample;
    dec.factor            = 2^dec.bits_per_sample;

    % fill table for 1/div, where div=[0...32768]
    dec.divtable = zeros(1,1+32768);
    for div=0:1:+32768
        if div>0
            dec.divtable(div+1) = 32768*1/div;  % 0.0=0 , 1.0=32768
        else
            dec.divtable(div+1) = 0;
        end
    end

    % fill tables
    dec.table0 = zeros(1,dec.factor);
    for dv=1:dec.factor
        sss = 2*(dv-1)*dec.factor/dec.factor - dec.factor;
        dec.table0(dv) = sss;
    end

    dec.table1 = zeros(1,dec.factor);
    for dv=1:dec.factor
        sss = 2*(dv-1)*dec.factor/dec.factor - dec.factor;
        dec.table1(dv) = dec.factor * expand( sss/(2*dec.factor) , 1 );
    end

    dec.table2 = zeros(1,dec.factor);
    for dv=1:dec.factor
        sss = 2*(dv-1)*dec.factor/dec.factor - dec.factor;
        dec.table2(dv) = dec.factor * expand( sss/(2*dec.factor) , 1 );
    end

    dec.table3 = zeros(1,dec.factor);
    for dv=1:dec.factor
        sss = 2*(dv-1)*dec.factor/dec.factor - dec.factor;
        dec.table3(dv) = dec.factor * expand( sss/(2*dec.factor) , 1 );
    end

return
