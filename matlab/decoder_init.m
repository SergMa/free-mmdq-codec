%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mycodec decoder function initialization
% [dec] = decoder_init( samples_per_frame, bits_per_sample )
% INPUTS:
%   samples_per_frame = number of voice samples per frame
%   bits_per_sample   = number of bits per sample
% OUTPUTS:
%   dec   = decoder structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [dec] = decoder_init( samples_per_frame, bits_per_sample )

    % set settings of decoder
    dec.samples_per_frame = samples_per_frame;
    dec.bits_per_sample   = bits_per_sample;
    dec.factor            = 2^dec.bits_per_sample;

    dec.history = zeros(1,2);

return
