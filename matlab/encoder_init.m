%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mycodec encoder function initialization
% [enc] = encoder_init( samples_per_frame, bits_per_sample )
% INPUTS:
%   samples_per_frame = number of voice samples per frame
%   bits_per_sample   = number of bits per sample
% OUTPUTS:
%   enc   = encoder structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [enc] = encoder_init( samples_per_frame, bits_per_sample )

    % set settings of encoder
    enc.samples_per_frame = samples_per_frame;
    enc.bits_per_sample   = bits_per_sample;
    enc.factor            = 2^enc.bits_per_sample;

    enc.history = zeros(1,2);

return
