%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MMDQ decoder function (table version)
% [data,dec] = decode(voice,dec)
% GLOBALS:
%   MAXX
%   FACTOR
%   SAMPLES_PER_FRAME
%   BITS_PER_SAMPLE
%   SMOOTH_N
%   SMOOTH_ERROR_VER
%   COM_PWR
%   EXP_PWR
% INPUTS:
%   data  = dim 1xM = data frame to decode
%   dec   = decoder structure
%   FIXP  = constant of fixed-point arithmetics
% OUTPUTS:
%   voice = dim 1xN = decoded voice samples
%   dec   = decoder structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [voice,dec] = decoder2( data, dec, FIXP )

    global FIXP;
    global MAXX;
    global FACTOR;
    global SAMPLES_PER_FRAME;
    global BITS_PER_SAMPLE;
    global SMOOTH_N;
    global SMOOTH_ERROR_VER;
    global COM_PWR;
    global EXP_PWR;

    N = SAMPLES_PER_FRAME;

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
    %mindv  = min(dvoice);
    %maxdv  = max(dvoice);
    %diffdv = maxdv - mindv;

    % Reconstrunct voice in relative coordinats
    voice = zeros(1,N);

    smooth_code = 2*smooth1 + smooth0 + 1;
    voice(1) = 0;
    for i=1:N-1
        %dvoice(i)  = [0..dec.factor-1]
        %dec.table0 = [-FIXP..+FIXP]
        voice(i+1) = voice(i) + dec.table( smooth_code, dvoice(i)+1 );
    end

    % Scale/shift absolute voice by minv,maxv reference points
    voicemax  = max(voice);
    voicemin  = min(voice);
    voicediff = voicemax - voicemin;

    h = fix( FIXP / SAMPLES_PER_FRAME );
    voicediff_n = fix( voicediff * h / FIXP );
    voicemax_n  = fix( voicemax  * h / FIXP );
    voicemin_n  = fix( voicemin  * h / FIXP );

    % voicemin_n  = [-maxx..+maxx]
    % voicemax_n  = [-maxx..+maxx]
    % voicediff_n = [0..2*maxx]

    div = dec.divtable( voicediff_n + 1 ); %div=[0..FIXP*FIXP]
    if voicediff_n <= (2*MAXX)/256
        K = 1;
    else
        K = 256;
    end

    %div = FIXP / voicediff_n;

    %fprintf(1,'voicediff_n=%12d, div=%12d\n', voicediff_n, div );

    for i=1:N
        voice_n = fix( voice(i) * h / FIXP );
        voice(i) = minv + fix( diffv * (voice_n - voicemin_n)*div/(FIXP*K) );
    end

    %for i=1:N
    %    voice(i) = diffv * ((voice(i) - voicemin)/voicediff) + minv;
    %end

return
