%Compand before diffx quantization
%GLOBALS: COM_PWR
%INPUTS:  x = [-1..+1]
%OUTPUTS: y = [-1..+1]
function y = compand( x , ver )

    global COM_PWR;
    %current best value:
    %COM_PWR = [1.0  1.10  1.20  1.20];

    switch ver
    case 1
        y = sign(x) .* abs(x) .^ (COM_PWR(1));
    case 2
        y = sign(x) .* abs(x) .^ (1/COM_PWR(2));
    case 3
        N = length(x);
        y = zeros(1,N);
        for i=1:N
            if x(i)>=0 && x(i)<=0.5
                y(i) =    0.5*(2*   x(i) )^(1/COM_PWR(3));
            elseif x(i)>0.5
                y(i) =  1-0.5*(2*(1-x(i)))^(1/COM_PWR(3));
            elseif x(i)>=-0.5
                y(i) =   -0.5*(2*( -x(i)))^(1/COM_PWR(3));
            else
                y(i) = -1+0.5*(2*(1+x(i)))^(1/COM_PWR(3));
            end
        end
    case 4
        y = sign(x) .* (1 - (1 - abs(x)) .^ (1/COM_PWR(4)));
    end

return
