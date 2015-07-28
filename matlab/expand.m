%Expand after diffx de-quantization
%INPUTS:  x = [-1..+1]
%OUTPUTS: y = [-1..+1]
function y = expand( x , ver )

    switch ver
    case 0
        y = sign(x) .* abs(x) .^ (1.28);

    case 1
        PWR = 1.182;
        N = length(x);
        y = zeros(1,N);
        for i=1:N
            if x(i)>=0 && x(i)<=0.5
                y(i) = 0.5*(2*x(i))^(PWR);
            elseif x(i)>0.5
                y(i) = 1-0.5*(2*(1-x(i)))^(PWR);
            elseif x(i)>=-0.5
                y(i) = -0.5*(2*(-x(i)))^(PWR);
            else
                y(i) = -1+0.5*(2*(1+x(i)))^(PWR);
            end
        end

    case 2
        y = sign(x) .* (1 - (1 - abs(x)) .^ (1.215));

    case 3
        PWR = 1/1.26;
        N = length(x);
        y = zeros(1,N);
        for i=1:N
            if x(i)>=0 && x(i)<=0.5
                y(i) = 0.5*(2*x(i))^(PWR);
            elseif x(i)>0.5
                y(i) = 1-0.5*(2*(1-x(i)))^(PWR);
            elseif x(i)>=-0.5
                y(i) = -0.5*(2*(-x(i)))^(PWR);
            else
                y(i) = -1+0.5*(2*(1+x(i)))^(PWR);
            end
        end

    end
return