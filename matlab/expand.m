%Expand after diffx de-quantization
%INPUTS:  x = [-1..+1]
%OUTPUTS: y = [-1..+1]
function y = expand( x , ver )

%     switch ver
%     case 0
%         y = sign(x) .* abs(x) .^ (1.28);
%     case 1
%         PWR = 1.182;
%         N = length(x);
%         y = zeros(1,N);
%         for i=1:N
%             if x(i)>=0 && x(i)<=0.5
%                 y(i) = 0.5*(2*x(i))^(PWR);
%             elseif x(i)>0.5
%                 y(i) = 1-0.5*(2*(1-x(i)))^(PWR);
%             elseif x(i)>=-0.5
%                 y(i) = -0.5*(2*(-x(i)))^(PWR);
%             else
%                 y(i) = -1+0.5*(2*(1+x(i)))^(PWR);
%             end
%         end
%     case 2
%         y = sign(x) .* (1 - (1 - abs(x)) .^ (1.215));
%     case 3
%         PWR = 1/1.26;
%         N = length(x);
%         y = zeros(1,N);
%         for i=1:N
%             if x(i)>=0 && x(i)<=0.5
%                 y(i) = 0.5*(2*x(i))^(PWR);
%             elseif x(i)>0.5
%                 y(i) = 1-0.5*(2*(1-x(i)))^(PWR);
%             elseif x(i)>=-0.5
%                 y(i) = -0.5*(2*(-x(i)))^(PWR);
%             else
%                 y(i) = -1+0.5*(2*(1+x(i)))^(PWR);
%             end
%         end
%     end

if 0
    global EXP_PWR0 EXP_PWR1 EXP_PWR2 EXP_PWR3;
    PWR0 = EXP_PWR0;
    PWR1 = EXP_PWR1;
    PWR2 = EXP_PWR2;
    PWR3 = EXP_PWR3;
else
    PWR0 = 1.0;
    PWR1 = 1.5;
    PWR2 = 0.65;
    PWR3 = 1.5;
end

if 1
    switch ver
    case 0
        y = sign(x) .* abs(x) .^ (PWR0);
    case 1
        y = sign(x) .* abs(x) .^ (PWR1);
    case 2
%         N = length(x);
%         y = zeros(1,N);
%         for i=1:N
%             if x(i)>=0 && x(i)<=0.5
%                 y(i) = 0.5*(2*x(i))^(1/PWR2);
%             elseif x(i)>0.5
%                 y(i) = 1-0.5*(2*(1-x(i)))^(1/PWR2);
%             elseif x(i)>=-0.5
%                 y(i) = -0.5*(2*(-x(i)))^(1/PWR2);
%             else
%                 y(i) = -1+0.5*(2*(1+x(i)))^(1/PWR2);
%             end
%         end
        y = sign(x) .* (1 - (1 - abs(x)) .^ (PWR2));
    case 3
        y = sign(x) .* (1 - (1 - abs(x)) .^ (PWR3));
    end
end

if 0
    switch ver
    case 0
        y = sign(x) .* abs(x) .^ (1/PWR0);
    case 1
        y = sign(x) .* abs(x) .^ (1/PWR1);
    case 2
        y = sign(x) .* (1 - (1 - abs(x)) .^ (1/PWR2));
    case 3
        y = sign(x) .* (1 - (1 - abs(x)) .^ (1/PWR3));
    end
end

return