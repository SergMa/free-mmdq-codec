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
        y = sign(x) .* abs(x) .^ (1/1.5);

    case 2
        %% VER2: power 1.4 table
        %y = sign(x) .* abs(x) .^ (1/1.4);

        % VER2: power 0.65 table
        y = sign(x) .* (1 - (1 - abs(x)) .^ (1/0.65));

    case 3
        %% VER2: power 1.8 table
        %y = sign(x) .* abs(x) .^ (1/1.8);

        % VER3: power 1.5 table
        y = sign(x) .* (1 - (1 - abs(x)) .^ (1/1.5));
    end
return