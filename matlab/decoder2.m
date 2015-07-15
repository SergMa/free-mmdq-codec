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

function [voice,dec] = decoder2(data,dec)

    FIXP = 32768*2;

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
            %dec.table0 = [-FIXP..+FIXP]
            voice(i+1) = voice(i) + dec.table0( dvoice(i)+1 );
            fprintf(1,'voice(i=%3d)=%8d , dec.table0( dvoice(i)=%8d )=%8d, voice(i+1)=%8d\n', i, voice(i), dvoice(i), dec.table0( dvoice(i)+1 ), voice(i+1));
        end
    case 1
        %expand/compand smoothing
        voice(1) = 0;
        for i=1:N-1
            %dvoice(i)  = [0..dec.factor-1]
            %dec.table1 = [-FIXP..+FIXP]
            voice(i+1) = voice(i) + dec.table1( dvoice(i)+1 );
            %fprintf(1,'voice(i=%d)=%6.3f , dec.table1( dvoice(i)=%6.3f )=%6.3f\n', i, voice(i), dvoice(i), dec.table1( dvoice(i)+1 ));
        end
    case 2
        %expand/compand smoothing
        voice(1) = 0;
        for i=1:N-1
            %dvoice(i)  = [0..dec.factor-1]
            %dec.table2 = [-FIXP..+FIXP]
            voice(i+1) = voice(i) + dec.table2( dvoice(i)+1 );
            %fprintf(1,'voice(i=%d)=%6.3f , dec.table2( dvoice(i)=%6.3f )=%6.3f\n', i, voice(i), dvoice(i), dec.table2( dvoice(i)+1 ));
        end
    case 3
        %expand/compand smoothing
        voice(1) = 0;
        for i=1:N-1
            %dvoice(i)  = [0..dec.factor-1]
            %dec.table3 = [-FIXP..+FIXP]
            voice(i+1) = voice(i) + dec.table3( dvoice(i)+1 );
            %fprintf(1,'voice(i=%d)=%6.3f , dec.table3( dvoice(i)=%6.3f )=%6.3f\n', i, voice(i), dvoice(i), dec.table3( dvoice(i)+1 ));
        end
    end

    % Scale/shift absolute voice by minv,maxv reference points
    voicemax  = max(voice);
    voicemin  = min(voice);
    voicediff = voicemax - voicemin;

    h = fix( FIXP / dec.samples_per_frame );
    voicediff_n = fix( voicediff * h / FIXP );
    voicemax_n  = fix( voicemax  * h / FIXP );
    voicemin_n  = fix( voicemin  * h / FIXP );

    % voicemin_n  = [-maxx..+maxx]
    % voicemax_n  = [-maxx..+maxx]
    % voicediff_n = [0..2*maxx]

    div = dec.divtable( voicediff_n + 1 ); %div=[0..2*FIXP]

    %fprintf(1,'h=%8.3f, voicediff_n=%8.3f, div=%8.3f\n', h, voicediff_n, div);
    for i=1:N
        tmp = voice(i);
        voice_n = fix( voice(i) * h / FIXP );
        voice(i) = minv + fix( diffv * (voice_n - voicemin_n)*div/(FIXP) );
        %fprintf(1,'i=%3d, minv=%8.3f, maxv=%8.3f, diffv=%8.3f, voice(i)=%8.3f --> voice(i)=%8.3f, voicemin=%8.3f\n', i, minv, maxv, diffv, tmp, voice(i), voicemin);
    end

    %for i=1:N
    %    voice(i) = diffv * ((voice(i) - voicemin)/voicediff) + minv;
    %end

return
