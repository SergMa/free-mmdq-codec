%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mycodec decoder function
% [data,dec] = decode(voice,dec)
% INPUTS:
%   data  = dim 1xM = data frame to decode
%   dec   = decoder structure
% OUTPUTS:
%   voice = dim 1xN = decoded voice samples
%   dec   = decoder structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [voice,dec] = decoder(data,dec)

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

    N = dec.samples_per_frame;
    voice = zeros(1,N);

    % Get absolute voice
    mindv = min(dvoice);
    maxdv = max(dvoice);
    diffdv = maxdv - mindv;

    if 1
        if smooth0==0 && smooth1==0
            voice(1) = 0;
            for i=1:N-1
                sss = expand( ((dvoice(i)+0.5)/dec.factor - 0.5)*2 , 0 );
                voice(i+1) = voice(i) + sss;
                %fprintf(1,'voice(i=%3d)=%8.3f , sss=%8.3f, voice(i+1)=%8.3f\n', i, voice(i), sss, voice(i+1));
            end
        elseif smooth0==1 && smooth1==0
            %expand/compand smoothing
            voice(1) = 0;
            for i=1:N-1
                sss = expand( ((dvoice(i)+0.5)/dec.factor - 0.5)*2 , 1 );
                voice(i+1) = voice(i) + sss;
            end
        elseif smooth0==0 && smooth1==1
            %expand/compand smoothing
            voice(1) = 0;
            for i=1:N-1
                sss = expand( ((dvoice(i)+0.5)/dec.factor - 0.5)*2 , 2 );
                voice(i+1) = voice(i) + sss;
            end
        else
            %expand/compand smoothing
            voice(1) = 0;
            for i=1:N-1
                sss = expand( ((dvoice(i)+0.5)/dec.factor - 0.5)*2 , 3 );
                voice(i+1) = voice(i) + sss;
            end
        end
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
