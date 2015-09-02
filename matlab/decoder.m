%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mycodec decoder function
% [data,dec] = decode(voice,dec)
% GLOBALS:
%   MAXX
%   FACTOR
%   SAMPLES_PER_FRAME
%   BITS_PER_SAMPLE
%   SMOOTH_N
%   SMOOTH_ERROR_VER
% INPUTS:
%   data  = dim 1xM = data frame to decode
%   dec   = decoder structure
% OUTPUTS:
%   voice = dim 1xN = decoded voice samples
%   dec   = decoder structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [voice,dec] = decoder(data,dec)

    global MAXX;
    global FACTOR;
    global SAMPLES_PER_FRAME;
    global BITS_PER_SAMPLE;
    global SMOOTH_N;
    global SMOOTH_ERROR_VER;

    N = SAMPLES_PER_FRAME;

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

    voice = zeros(1,N);

    % Get absolute voice
    mindv = min(dvoice);
    maxdv = max(dvoice);
    diffdv = maxdv - mindv;

    smooth_code = smooth1*2 + smooth0 + 1;

    voice(1) = 0;
    for i=1:N-1
        sss = expand( ((dvoice(i)+0.5)/FACTOR - 0.5)*1 , smooth_code );
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
