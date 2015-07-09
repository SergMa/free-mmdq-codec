%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mycodec encoder function initialization
% [enc] = encoder_init( samples_per_frame, bits_per_sample )
% INPUTS:
%   samples_per_frame = number of voice samples per frame
%   bits_per_sample   = number of bits per sample
%   maxx              = amplitude of signal: signal=[-maxx...+maxx]
% OUTPUTS:
%   enc   = encoder structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [enc] = encoder_init( samples_per_frame, bits_per_sample, maxx )

    % set settings of encoder
    enc.samples_per_frame = samples_per_frame;
    enc.bits_per_sample   = bits_per_sample;
    enc.factor            = 2^enc.bits_per_sample;
    enc.maxx              = maxx;

return
