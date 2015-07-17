%Compand before diffx quantization
%INPUTS:  x = [-1..+1]
%OUTPUTS: y = [-1..+1]
function y = compand( x , ver )

    switch ver
    case 0
        % VER0: linear table
        y = x;

    case 1
        %% VER1: power 1.2 table
        %y = sign(x) .* abs(x) .^ (1/1.2);

        % VER1: power 1.5 table
        y = sign(x) .* abs(x) .^ (1/1.25);

    case 2
        % VER2: power 0.65 table
        %y = sign(x) .* (1 - (1 - abs(x)) .^ (1/0.85));

        % VER2: power 1.4 table
        %y = sign(x) .* abs(x) .^ (1/1.2);

        PWR = 1.35;
        N = length(x);
        y = zeros(1,N);
        for i=1:N
            if x(i)>=0 && x(i)<=0.5
                y(i) = 0.5*(2*x(i))^(1/PWR);
            elseif x(i)>0.5
                y(i) = 1-0.5*(2*(1-x(i)))^(1/PWR);
            elseif x(i)>=-0.5
                y(i) = -0.5*(2*(-x(i)))^(1/PWR);
            else
                y(i) = -1+0.5*(2*(1+x(i)))^(1/PWR);
            end
        end

    case 3
        %% VER2: power 1.8 table
        %y = sign(x) .* abs(x) .^ (1/1.8);

        % VER3: power 1.5 table
        y = sign(x) .* (1 - (1 - abs(x)) .^ (1/1.2));
    end
return