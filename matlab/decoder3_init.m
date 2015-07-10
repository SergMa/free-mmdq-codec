%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mycodec decoder function initialization (table version, integer division)
% [dec] = decoder_init( samples_per_frame, bits_per_sample )
% INPUTS:
%   samples_per_frame = number of voice samples per frame
%   bits_per_sample   = number of bits per sample
%   maxx              = amplitude of signal: signal=[-maxx...+maxx]
% OUTPUTS:
%   dec   = decoder structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [dec] = decoder3_init( samples_per_frame, bits_per_sample, maxx )

    % set settings of decoder
    dec.samples_per_frame = samples_per_frame;
    dec.bits_per_sample   = bits_per_sample;
    dec.factor            = 2^dec.bits_per_sample;
    dec.maxx              = maxx;

    % fill tables
    % inputs=[0..(dec.factor-1)]
    % returns=[-maxx..+maxx]
    dec.table0 = zeros(1,dec.factor);
    for dv=0:(dec.factor-1)
        sss = fix( 2*maxx*dv/dec.factor - maxx );
        dec.table0(dv+1) = fix( sss );
    end

    dec.table1 = zeros(1,dec.factor);
    for dv=0:(dec.factor-1)
        sss = fix( 2*maxx*dv/dec.factor - maxx );
        dec.table1(dv+1) = fix( maxx * expand( sss/maxx , 1 ) );
    end

    dec.table2 = zeros(1,dec.factor);
    for dv=0:(dec.factor-1)
        sss = fix( 2*maxx*dv/dec.factor - maxx );
        dec.table2(dv+1) = fix( maxx * expand( sss/maxx , 2 ) );
    end

    dec.table3 = zeros(1,dec.factor);
    for dv=0:(dec.factor-1)
        sss = fix( 2*maxx*dv/dec.factor - maxx );
        dec.table3(dv+1) = fix( maxx * expand( sss/maxx , 3 ) );
    end

return
