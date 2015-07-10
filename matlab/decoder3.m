%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mycodec decoder function (table version, integer division)
% [data,dec] = decode(voice,dec)
% INPUTS:
%   data  = dim 1xM = data frame to decode
%   dec   = decoder structure
% OUTPUTS:
%   voice = dim 1xN = decoded voice samples
%   dec   = decoder structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [voice,dec] = decoder3(data,dec)

    N = dec.samples_per_frame;

    minv    = data(1);
    maxv    = data(2);
    smooth1 = data(3);
    if minv<=maxv
        smooth0 = 0;
    else
        smooth0 = 1; %swap minv,maxv
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

    % Reconstrunct voice in relative coordinats
    voice = zeros(1,N);

    code = fix( 2*smooth1 + smooth0 );
    switch code
    case 0
        voice(1) = 0;
        for i=1:N-1
            %dvoice(i)  = [0..dec.factor-1]
            %dec.table0 = [-maxx..+maxx]
            voice(i+1) = voice(i) + dec.table0( dvoice(i)+1 );
            %fprintf(1,'voice(i=%d)=%6.3f , dec.table0( dvoice(i)=%6.3f )=%6.3f\n', i, voice(i), dvoice(i), dec.table0( dvoice(i)+1 ));
        end
    case 1
        %expand/compand smoothing
        voice(1) = 0;
        for i=1:N-1
            %dvoice(i)  = [0..dec.factor-1]
            %dec.table1 = [-maxx..+maxx]
            voice(i+1) = voice(i) + dec.table1( dvoice(i)+1 );
            %fprintf(1,'voice(i=%d)=%6.3f , dec.table1( dvoice(i)=%6.3f )=%6.3f\n', i, voice(i), dvoice(i), dec.table1( dvoice(i)+1 ));
        end
    case 2
        %expand/compand smoothing
        voice(1) = 0;
        for i=1:N-1
            %dvoice(i)  = [0..dec.factor-1]
            %dec.table2 = [-maxx..+maxx]
            voice(i+1) = voice(i) + dec.table2( dvoice(i)+1 );
            %fprintf(1,'voice(i=%d)=%6.3f , dec.table2( dvoice(i)=%6.3f )=%6.3f\n', i, voice(i), dvoice(i), dec.table2( dvoice(i)+1 ));
        end
    case 3
        %expand/compand smoothing
        voice(1) = 0;
        for i=1:N-1
            %dvoice(i)  = [0..dec.factor-1]
            %dec.table3 = [-maxx..+maxx]
            voice(i+1) = voice(i) + dec.table3( dvoice(i)+1 );
            %fprintf(1,'voice(i=%d)=%6.3f , dec.table3( dvoice(i)=%6.3f )=%6.3f\n', i, voice(i), dvoice(i), dec.table3( dvoice(i)+1 ));
        end
    end

    % Scale/shift absolute voice by minv,maxv reference points
    voicemax  = max(voice);
    voicemin  = min(voice);
    voicediff = voicemax - voicemin;
    if voicediff == 0
        for i=1:N
            voice(i) = minv;
        end
    else
        for i=1:N
            d = voice(i) - voicemin;
            voice(i) = fix(diffv * d / voicediff) + minv;
        end
    end

    %for i=1:N
    %    voice(i) = diffv * ((voice(i) - voicemin)/voicediff) + minv;
    %end

return
