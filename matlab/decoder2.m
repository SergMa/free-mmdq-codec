%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mycodec decoder function (table version)
% [data,dec] = decode(voice,dec)
% INPUTS:
%   data  = dim 1xM = data frame to decode
%   dec   = decoder structure
% OUTPUTS:
%   voice = dim 1xN = decoded voice samples
%   dec   = decoder structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [voice,dec] = decoder(data,dec)

    N = dec.samples_per_frame;

    minv    = data(1);
    maxv    = data(2);
    smooth1 = data(3);
    if minv<=maxv
        smooth0 = 0;
    else
        smooth0 = 1;
        tmp  = minv;
        minv = maxv;
        maxv = tmp;
    end
    diffv = maxv - minv;

    % Analize dvoice-s
    dvoice = data(3+1:end);
    mindv  = min(dvoice);
    maxdv  = max(dvoice);
    diffdv = maxdv - mindv;

    % Get absolute voice
    voice = zeros(1,N);

    % TODO: correct formulaes to remove this check
    for i=1:N-1
        if dvoice(i) < 1
            fprintf(1,'ALARM ZERO! %d\n', dvoice(i));
            dvoice(i) = 1;
        end
        if dvoice(i) > dec.factor-1
            fprintf(1,'ALARM BIG! %d\n', dvoice(i));
            dvoice(i) = dec.factor-1;
        end
    end

    if 1
        if smooth0==0 && smooth1==0
            voice(1) = 0;
            for i=1:N-1
                %sss = 2*dvoice(i)/dec.factor - 1;
                %voice(i+1) = voice(i) + 1024 * sss/2;
                voice(i+1) = voice(i) + dec.table0( dvoice(i)+1 );
            end
        elseif smooth0==1 && smooth1==0
            %expand/compand smoothing
            voice(1) = 0;
            for i=1:N-1
                %sss = 2*dvoice(i)/dec.factor - 1;
                %voice(i+1) = voice(i) + 1024 * expand( sss/2 , 1 );
                voice(i+1) = voice(i) + dec.table1( dvoice(i)+1 );
            end
        elseif smooth0==0 && smooth1==1
            %expand/compand smoothing
            voice(1) = 0;
            for i=1:N-1
                %sss = 2*dvoice(i)/dec.factor - 1;
                %voice(i+1) = voice(i) + 1024 * expand( sss/2 , 2 );
                voice(i+1) = voice(i) + dec.table2( dvoice(i)+1 );
            end
        else
            %expand/compand smoothing
            voice(1) = 0;
            for i=1:N-1
                %sss = 2*dvoice(i)/dec.factor - 1;
                %voice(i+1) = voice(i) + 1024 * expand( sss/2 , 3 );
                voice(i+1) = voice(i) + dec.table3( dvoice(i)+1 );
            end
        end
    end

    % Scale/shift absolute voice by minv,maxv reference points
    voice = round(voice);

    voicemax = max(voice);
    voicemin = min(voice);
    voicediff = voicemax - voicemin;
    
    if voicediff == 0
        for i=1:N
            voice(i) = minv;
        end
    else
        div = dec.divtable( voicediff );
        for i=1:N
            div = dec.divtable( voicediff + 1 ); % (1/voicediff)*32768
            voice(i) = diffv*(voice(i)-voicemin)*div/32768 + minv;
        end

        %for i=1:N
        %    voice(i) = diffv * ((voice(i) - voicemin)/voicediff) + minv;
        %end
    end

return
