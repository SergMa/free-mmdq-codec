%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mycodec encoder function (table version)
% [data,enc] = encode(voice,enc)
% INPUTS:
%   voice = dim 1xN = voice samples to encode
%   enc   = encoder structure
%   FIXP  = constant of fixed-point arithmetics
% OUTPUTS:
%   data  = dim 1xM = encoded voice data frame
%   enc   = encoder structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data,enc] = encoder2( voice, enc, dec, FIXP )

    N = enc.samples_per_frame;

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

    %fprintf(1,'diffdv=%d, maxdv=%d\n',diffdv,maxdv);

    % quantize dvoice
    data0 = zeros(1,3+N-1);
    data1 = zeros(1,3+N-1);
    data2 = zeros(1,3+N-1);
    data3 = zeros(1,3+N-1);
    err0 = 0;
    err1 = 0;
    err2 = 0;
    err3 = 0;
    if diffdv==0
        if maxdv==0
            for i=1:2:N-1
                data(3+i) = round( enc.factor/2 );
            end
            for i=2:2:N-1
                data(3+i) = round( enc.factor/2-1 );
            end
        elseif maxdv>0
            for i=1:N-1
                data(3+i) = enc.factor - 1;
            end
        else
            for i=1:N-1
                data(3+i) = 0;
            end
        end
    else
        %ampdv=[0..2*maxx]
        %div=[0..FIXP]
        div = enc.divtable( ampdv+1 );
        if ampdv <= (2*enc.maxx)/256
            K = 1;
        else
            K = 256;
        end

        %no smoothing (smooth0=0,smooth1=0)
        data0(1) = minv;
        data0(2) = maxv;
        data0(3) = 0;
        for i=1:N-1
            % dvoice(i)=[-2*maxx..+2*maxx]
            % div=[0..FIXP]
            sss = fix( dvoice(i)*div/K );  % sss=[-FIXP..+FIXP]
            data0(3+i) = enc.table0( sss + FIXP + 1 );
        end
        %expand/compand smoothing (smooth0=1,smooth1=0)
        data1(1) = maxv;
        data1(2) = minv;
        data1(3) = 0;
        for i=1:N-1
            % dvoice(i)=[-2*maxx..+2*maxx]
            % div=[0..FIXP]
            sss = fix( dvoice(i)*div/K );  % sss=[-FIXP..+FIXP]
            data1(3+i) = enc.table1( sss + FIXP + 1 );
        end
        %expand/compand smoothing (smooth0=0,smooth1=1)
        data2(1) = minv;
        data2(2) = maxv;
        data2(3) = 1;
        for i=1:N-1
            % dvoice(i)=[-2*maxx..+2*maxx]
            % div=[0..FIXP]
            sss = fix( dvoice(i)*div/K );  % sss=[-FIXP..+FIXP]
            data2(3+i) = enc.table2( sss + FIXP + 1 );
        end
        %expand/compand smoothing (smooth0=1,smooth1=1)
        data3(1) = maxv;
        data3(2) = minv;
        data3(3) = 1;
        for i=1:N-1
            % dvoice(i)=[-2*maxx..+2*maxx]
            % div=[0..FIXP]
            sss = fix( dvoice(i)*div/K );  % sss=[-FIXP..+FIXP]
            data3(3+i) = enc.table3( sss + FIXP + 1 );
        end

        %find reconstruction errors
        [voice0,dec] = decoder(data0,dec);
        [voice1,dec] = decoder(data1,dec);
        [voice2,dec] = decoder(data2,dec);
        [voice3,dec] = decoder(data3,dec);

        v = 0;
        switch v
        case 0
            err0 = max( abs(voice0-voice) ); 
            err1 = max( abs(voice1-voice) ); 
            err2 = max( abs(voice2-voice) ); 
            err3 = max( abs(voice3-voice) ); 
        case 1
            err0 = sum( abs(voice0-voice) ); 
            err1 = sum( abs(voice1-voice) ); 
            err2 = sum( abs(voice2-voice) ); 
            err3 = sum( abs(voice3-voice) ); 
        case 2
            err0 = mean((voice0-voice).^2); 
            err1 = mean((voice1-voice).^2); 
            err2 = mean((voice2-voice).^2); 
            err3 = mean((voice3-voice).^2); 
        end

        if err0<=err1 && err0<=err2 && err0<=err3
            data = data0;
        elseif err1<=err0 && err1<=err2 && err1<=err3
            data = data1;
        elseif err2<=err0 && err2<=err1 && err2<=err3
            data = data2;
        else
            data = data3;
        end
    end

    if data(1)<=data(2)
        smooth0 = 0;
    else
        smooth0 = 1;
    end
    smooth1 = data(3);

    %fprintf(1,'\nenc data: ');
    %for i=1:length(data)
    %    fprintf(' %6.3f', data(i));
    %end
    %fprintf(1,'\n\n');

return
