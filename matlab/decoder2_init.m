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

    % fill table for 1/div, where div=[0...1000000]
    dec.divtable = zeros(1,1+1000000);
    for div=0:1:+1000000
        if div>0
            dec.divtable(div+1) = 1000000*1/div;  % 0.0=0 , 1.0=1000000
        else
            dec.divtable(div+1) = 0;
        end
    end

return
