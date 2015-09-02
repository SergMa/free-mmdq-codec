%Expand after diffx de-quantization
%GLOBALS: EXP_PWR
%INPUTS:  x = [-1..+1]
%OUTPUTS: y = [-1..+1]
function y = expand( x , ver )

    global EXP_PWR;
    %current best value:
    %EXP_PWR = [1.0  1.10  1.20  1.20];

    switch ver
    case 1
        y = sign(x) .* abs(x) .^ (1/EXP_PWR(1));
    case 2
        y = sign(x) .* abs(x) .^ (EXP_PWR(2));
    case 3
        N = length(x);
        y = zeros(1,N);
        for i=1:N
            if x(i)>=0 && x(i)<=0.5
                y(i) =    0.5*(2*    x(i))^(EXP_PWR(3));
            elseif x(i)>0.5
                y(i) =  1-0.5*(2*(1-x(i)))^(EXP_PWR(3));
            elseif x(i)>=-0.5
                y(i) =   -0.5*(2*( -x(i)))^(EXP_PWR(3));
            else
                y(i) = -1+0.5*(2*(1+x(i)))^(EXP_PWR(3));
            end
        end
    case 4
        y = sign(x) .* (1 - (1 - abs(x)) .^ (EXP_PWR(4)));
    end

return
