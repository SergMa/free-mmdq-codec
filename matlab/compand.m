%Compand before diffx quantization
%INPUTS:  x = [-1..+1]
%OUTPUTS: y = [-1..+1]
function y = compand( x , ver )

%     switch ver
%     case 0
%         y = sign(x) .* abs(x) .^ (1/1.28);
%     case 1
%         PWR = 1.182;
%         N = length(x);
%         y = zeros(1,N);
%         for i=1:N
%             if x(i)>=0 && x(i)<=0.5
%                 y(i) = 0.5*(2*x(i))^(1/PWR);
%             elseif x(i)>0.5
%                 y(i) = 1-0.5*(2*(1-x(i)))^(1/PWR);
%             elseif x(i)>=-0.5
%                 y(i) = -0.5*(2*(-x(i)))^(1/PWR);
%             else
%                 y(i) = -1+0.5*(2*(1+x(i)))^(1/PWR);
%             end
%         end
%     case 2
%         y = sign(x) .* (1 - (1 - abs(x)) .^ (1/1.215));
%     case 3
%         PWR = 1/1.26;
%         N = length(x);
%         y = zeros(1,N);
%         for i=1:N
%             if x(i)>=0 && x(i)<=0.5
%                 y(i) = 0.5*(2*x(i))^(1/PWR);
%             elseif x(i)>0.5
%                 y(i) = 1-0.5*(2*(1-x(i)))^(1/PWR);
%             elseif x(i)>=-0.5
%                 y(i) = -0.5*(2*(-x(i)))^(1/PWR);
%             else
%                 y(i) = -1+0.5*(2*(1+x(i)))^(1/PWR);
%             end
%         end
%     end

    PWR0 = 1.000;
    PWR1 = 1.250;
    PWR2 = 1.350;
    PWR3 = 1.200;

    switch ver
    case 0
        y = sign(x) .* abs(x) .^ (PWR0);
    case 1
        y = sign(x) .* abs(x) .^ (1/PWR1);
    case 2
        N = length(x);
        y = zeros(1,N);
        for i=1:N
            if x(i)>=0 && x(i)<=0.5
                y(i) = 0.5*(2*x(i))^(1/PWR2);
            elseif x(i)>0.5
                y(i) = 1-0.5*(2*(1-x(i)))^(1/PWR2);
            elseif x(i)>=-0.5
                y(i) = -0.5*(2*(-x(i)))^(1/PWR2);
            else
                y(i) = -1+0.5*(2*(1+x(i)))^(1/PWR2);
            end
        end
    case 3
        y = sign(x) .* (1 - (1 - abs(x)) .^ (1/PWR3));
    end

return