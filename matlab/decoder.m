%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mycodec decoder function
% [data] = decode(voice)
% INPUTS:
%   data  = dim 1xM = data frame to decode
% OUTPUTS:
%   voice = dim 1xN = decoded voice samples
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [voice] = decoder(data)

    global MAXX;
    global FACTOR;
    global SAMPLES_PER_FRAME;
    global BITS_PER_SAMPLE;
    global SMOOTH_N;
    global SMOOTH_ERROR_VER;

    minv    = data(1);
    maxv    = data(2);
    smooth1 = data(3);
    if minv<=maxv
        smooth0 = 0;
    else
        smooth0 = 1;
        tmp  = minv; %swap minv,maxv
        minv = maxv;
        maxv = tmp;
    end
    diffv = maxv - minv;

    dvoice = data(3+1:end);

    N = SAMPLES_PER_FRAME;
    voice = zeros(1,N);

    % Get absolute voice
    mindv = min(dvoice);
    maxdv = max(dvoice);
    diffdv = maxdv - mindv;

    smooth = smooth1*2 + smooth0 + 1;

    voice(1) = 0;
    for i=1:N-1
        sss = expand( dvoice(i) , smooth );
        voice(i+1) = voice(i) + sss;
    end

    % Scale/shift absolute voice by minv,maxv reference points
    voicemax = max(voice);
    voicemin = min(voice);
    voicediff = voicemax - voicemin;

    if voicediff == 0
        for i=1:N
            voice(i) = minv;
        end
    else
        for i=1:N
            voice(i) = diffv * ((voice(i) - voicemin)/voicediff) + minv;
        end
    end

return
