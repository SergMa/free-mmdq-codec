%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mycodec encoder function
% [data] = encode(voice)
% GLOBALS:
%   MAXX
%   FACTOR
%   SAMPLES_PER_FRAME
%   BITS_PER_SAMPLE
%   SMOOTH_N
%   SMOOTH_ERROR_VER
% INPUTS:
%   voice = dim 1xN = voice samples to encode
% OUTPUTS:
%   data  = dim 1xM = encoded voice data frame
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data] = encoder(voice)

    global MAXX;
    global FACTOR;
    global SAMPLES_PER_FRAME;
    global BITS_PER_SAMPLE;
    global SMOOTH_N;
    global SMOOTH_ERROR_VER;

    N = SAMPLES_PER_FRAME;

    minv  = min(min(voice));
    maxv  = max(max(voice));
    diffv = maxv - minv;

    data = zeros(1,3+N-1);

    % If smooth0==0, minv first, maxv second,
    % if smooth0==1, maxv first, minv second
    data(1) = minv; %smooth0 = 0
    data(2) = maxv;
    data(3) = 0;    %smooth1 = 0

    % get differencies of voice samples
    dvoice = zeros(1,N-1);
    for i=1:N-1
        dvoice(i) = voice(i+1) - voice(i);
    end

    % get min, max dvoice
    mindv  = min(dvoice);
    maxdv  = max(dvoice);
    diffdv = maxdv - mindv;
    ampdv  = max( abs(mindv) , abs(maxdv) );

    % quantize dvoice
    if diffdv==0
        %voice is constant
        if maxdv==0
            for i=1:2:N-1
                data(3+i) = round( FACTOR/2 );
            end
            for i=2:2:N-1
                data(3+i) = round( FACTOR/2 ) - 1;
            end
        elseif maxdv>0
            for i=1:N-1
                data(3+i) = FACTOR - 1;
            end
        else
            for i=1:N-1
                data(3+i) = 0;
            end
        end
    else
        %really quantize dvoice
        edata  = zeros(SMOOTH_N,N-1);
        errors = zeros(1,SMOOTH_N);
        voice2 = zeros(1,N);

        %expand/compand smoothing (smooth0=1,smooth1=0)
        for s=1:SMOOTH_N
            %set minv/maxv, smooth bits
            switch s
            case 1
                edata(s,1) = minv;
                edata(s,2) = maxv;
                edata(s,3) = 0; %smooth1
            case 2
                edata(s,1) = maxv;
                edata(s,2) = minv;
                edata(s,3) = 0; %smooth1
            case 3
                edata(s,1) = minv;
                edata(s,2) = maxv;
                edata(s,3) = 1; %smooth1
            case 4
                edata(s,1) = maxv;
                edata(s,2) = minv;
                edata(s,3) = 1; %smooth1
            end

            %get codes for dvoice values
            n_voice = 0; %true normalized voice
            r_voice = 0; %companded/expanded normalized voice
            voice2(1) = r_voice;
            for i=1:N-1
                %true normalized dvoice
                n_dvoice = dvoice(i)/ampdv;

                %true restored normalized voice
                n_voice = n_voice + n_dvoice;

                %get diff between true and companded/expanded normalized voices
                r_dvoice = n_voice - r_voice;

                %compand/expand voice
                edata(s,3+i) = compand( r_dvoice , s );
                ce_dvoice = expand( edata(s,3+i) , s );

                %restore voice
                r_voice = r_voice + ce_dvoice;
                voice2(i+1) = r_voice;
            end

            %find reconstruction errors
            [voice2] = decoder(edata(s,:));

            switch SMOOTH_ERROR_VER
            case 0
                errors(s) = max( abs(voice2-voice) );
            case 1
                errors(s) = sum( abs(voice2-voice) );
            case 2
                errors(s) = mean((voice2-voice).^2);
            end

        end
        %get data for smooth with min error
        [errmin,smin] = min(errors);
        data = edata(smin,:);
    end

return
