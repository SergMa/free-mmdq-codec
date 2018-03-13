%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MMDQ encoder function (table version)
% [data,enc] = encode(voice,enc)
% GLOBALS:
%   FIXP
%   MAXX
%   FACTOR
%   SAMPLES_PER_FRAME
%   BITS_PER_SAMPLE
%   SMOOTH_N
%   SMOOTH_ERROR_VER
%   COM_PWR
%   EXP_PWR
% INPUTS:
%   voice = dim 1xN = voice samples to encode
%   enc   = encoder structure
%   dec   = decoder structure
% OUTPUTS:
%   data  = dim 1xM = encoded voice data frame
%   enc   = encoder structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data,enc] = encoder2( voice, enc, dec )

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

    % Calculate minv,maxv,diffv
    minv = voice(1);
    maxv = voice(1);
    for i=2:N
        if voice(i) < minv
            minv = voice(i);
        end
        if voice(i) > maxv
            maxv = voice(i);
        end
    end
    diffv = maxv - minv;

    data = zeros(1,3+N-1);

    % If smooth0==0, minv first, maxv second,
    % if smooth0==1, maxv first, minv second
    smooth0 = 0;
    smooth1 = 0;
    data(1) = minv;
    data(2) = maxv;
    data(3) = smooth1;
    
    % get differencies of voice samples, mindv,maxdv,diffdv
    dvoice = zeros(1,N-1);
    dvoice(1) = voice(2) - voice(1);
    mindv = dvoice(1);
    maxdv = dvoice(1);
    for i=2:N-1
        dvoice(i) = voice(i+1) - voice(i);
        if dvoice(i) < mindv
            mindv = dvoice(i);
        end
        if dvoice(i) > maxdv
            maxdv = dvoice(i);
        end
    end
    diffdv = maxdv - mindv;
    
    a = abs(mindv);
    b = abs(maxdv);
    if a>=b
        ampdv = a;
    else
        ampdv = b;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % quantize dvoice

    %ampdv=[0..2*MAXX]
    %div=[0..FIXP]
    div = enc.divtable( ampdv+1 );
    if ampdv <= (2*MAXX)/256
        K = 1;
    else
        K = 256;
    end

    %really quantize dvoice
    edata  = zeros(SMOOTH_N,N-1);
    errors = zeros(1,SMOOTH_N);

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
        n_voice = zeros(1,N); %true normalized voice
        r_voice = zeros(1,N); %companded/expanded normalized voice
        n_voice(1) = 0;
        r_voice(1) = 0;
        for i=1:N-1
            %true normalized dvoice
            % dvoice(i)=[-2*MAXX..+2*MAXX]
            % div=[0..FIXP]
            % n_dvoice=[-FIXP..+FIXP]
            n_dvoice = fix( dvoice(i)*div/K );

            %true restored normalized voice
            n_voice(i+1) = n_voice(i) + n_dvoice;

            %get diff between true and companded/expanded normalized voices
            % r_dvoice=[-FIXP..+FIXP]
            r_dvoice = n_voice(i+1) - r_voice(i);

            %compand/expand voice
            % dvoice(i)=[-2*MAXX..+2*MAXX]
            % div=[0..FIXP]
            sss = fix( r_dvoice );  % sss=[-FIXP..+FIXP]
            sss = min( sss, FIXP );
            sss = max( sss,-FIXP );
            edata(s,3+i) = enc.table( s, sss + FIXP + 1 );

            %dvoice(i)  = [0..FACTOR-1]
            %dec.table = [-FIXP..+FIXP]
            ce_dvoice = dec.table( s, edata(s,3+i)+1 );

            %restore voice
            r_voice(i+1) = r_voice(i) + ce_dvoice;
        end

        %find reconstruction errors by n_voice[], r_voice[]
        maxnv  = max(n_voice);
        minnv  = min(n_voice);
        maxrnv = max(r_voice);
        minrnv = min(r_voice);

        %K = (maxnv - minnv) / (maxrnv - minrnv);
        %Shift = minnv - K*minrnv;
        %srnv = K*r_voice + Shift;
        %multiply these by (maxrnv - minrnv)

        dn = maxnv - minnv;
        dr = maxrnv - minrnv;
        srnv = dn*(r_voice - minrnv) + dr*minnv;
        snv  = dr*n_voice;

         switch SMOOTH_ERROR_VER
         case 0
             errors(s) = max( abs(srnv - snv) );
         case 1
             errors(s) = sum( abs(srnv - snv) );
         case 2
             errors(s) = mean((abs(srnv - snv)).^2);
         end

    end
    %get data for smooth with min error
    [errmin,smin] = min(errors(1:SMOOTH_N));
    data = edata(smin,:);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

return
