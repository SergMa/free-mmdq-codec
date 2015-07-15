%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mycodec encoder function
% [data,enc] = encode(voice,enc)
% INPUTS:
%   voice = dim 1xN = voice samples to encode
%   enc   = encoder structure
% OUTPUTS:
%   data  = dim 1xM = encoded voice data frame
%   enc   = encoder structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data,enc] = encoder(voice,enc,dec)
    minv = min(min(voice));
    maxv = max(max(voice));
    diffv = maxv - minv;

    N = enc.samples_per_frame;

    for i=1:N
        %fprintf(1,'i=%6d, voice=%8.3f\n', i, voice(i) );
    end

    data = zeros(1,3+N-1);
    % If smooth0==0, minv first, maxv second,
    % if smooth0==1, maxv first, minv second
    smooth0 = 0;
    smooth1 = 0;
    data(1) = minv;
    data(2) = maxv;
    data(3) = smooth1;
    
    % get differencies of voice samples
    dvoice = zeros(1,N-1);
    for i=1:N-1
        dvoice(i) = voice(i+1) - voice(i);
    end

    % get min, max dvoice
    mindv = min(dvoice);
    maxdv = max(dvoice);
    diffdv = maxdv - mindv;
    ampdv = max( abs(mindv) , abs(maxdv) );

    %fprintf(1,'minv=%8.3f, maxv=%8.3f, diffv=%8.3f, mindv=%8.3f, maxdv=%8.3f, diffdv=%8.3f, ampdv=%8.3f\n', ...
    %        minv,maxv,diffdv,mindv,maxdv,diffdv,ampdv);

    % quantize dvoice
    data0 = zeros(1,N-1);
    data1 = zeros(1,N-1);
    data2 = zeros(1,N-1);
    data3 = zeros(1,N-1);
    err0 = 0;
    err1 = 0;
    err2 = 0;
    err3 = 0;
    if diffdv==0
        if maxdv==0
            for i=1:N-1
                data(3+i) = round( enc.factor/2 );
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

%         sss = maxdv/ampdv;
%         ddd = enc.factor/2 * sss + enc.factor/2;
%         if round(ddd)==enc.factor/2
%             %all differencies are too small and will be rounded to zeros
%             if 
%             for i=1:N-1
%                 dvoice(i) = 
%             end
%         end

        %no smoothing (smooth0=0,smooth1=0)
        data0(1) = minv;
        data0(2) = maxv;
        data0(3) = 0;
        for i=1:N-1
            sss = compand( dvoice(i)/ampdv , 0 );
            ddd = enc.factor/2 * sss + enc.factor/2;
            ddd = min(ddd,enc.factor-1);
            data0(3+i) = fix( ddd );
            %fprintf(1,'minv=%8d, maxv=%8d, dvoice(i=%d)=%8d, sss=%8.3f, ddd=%8.3f, data0(i)=%8d\n', minv, maxv, i, dvoice(i), sss, ddd, data0(3+i));
        end
        %expand/compand smoothing (smooth0=1,smooth1=0)
        data1(1) = maxv;
        data1(2) = minv;
        data1(3) = 0;
        for i=1:N-1
            sss   = compand( dvoice(i)/ampdv , 1 );
            ddd   = enc.factor/2 * sss + enc.factor/2;
            ddd = min(ddd,enc.factor-1);
            data1(3+i) = fix( ddd );
        end
        %expand/compand smoothing (smooth0=0,smooth1=1)
        data2(1) = minv;
        data2(2) = maxv;
        data2(3) = 1;
        for i=1:N-1
            sss   = compand( dvoice(i)/ampdv , 2 );
            ddd   = enc.factor/2 * sss + enc.factor/2;
            ddd = min(ddd,enc.factor-1);
            data2(3+i) = fix( ddd );
        end
        %expand/compand smoothing (smooth0=1,smooth1=1)
        data3(1) = maxv;
        data3(2) = minv;
        data3(3) = 1;
        for i=1:N-1
            sss   = compand( dvoice(i)/ampdv , 3 );
            ddd   = enc.factor/2 * sss + enc.factor/2;
            ddd = min(ddd,enc.factor-1);
            data3(3+i) = fix( ddd );
        end

        %find reconstruction errors
        [voice0,dec] = decoder(data0,dec);
        [voice1,dec] = decoder(data1,dec);
        [voice2,dec] = decoder(data2,dec);
        [voice3,dec] = decoder(data3,dec);

        err0 = max( abs(voice0-voice) ); 
        err1 = max( abs(voice1-voice) ); 
        err2 = max( abs(voice2-voice) ); 
        err3 = max( abs(voice3-voice) ); 

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

    %fprintf('err0=%8.3f, err1=%8.3f, err2=%8.3f, err3=%8.3f, smooth=%d,%d\n', err0, err1, err2, err3, smooth0, smooth1);

    %fprintf(1,'\nenc data: ');
    %for i=1:length(data)
    %    fprintf(' %6.3f', data(i));
    %end
    %fprintf(1,'\n\n');

return
