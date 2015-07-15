%Compand before diffx quantization
%INPUTS:  x = [-1..+1]
%OUTPUTS: y = [-1..+1]
function y = compand( x , ver )

    switch ver
    case 0
        % VER0: linear table
        a = -1:0.001:1;
        table = a;

    case 1
        %% VER1: power 1.2 table
        %a = -1:0.001:1;
        %table = sign(a) .* abs(a) .^ (1/1.2);

        % VER1: power 1.5 table
        a = -1:0.001:1;
        table = sign(a) .* abs(a) .^ (1.5);

    case 2
        %% VER2: power 1.4 table
        %a = -1:0.001:1;
        %table = sign(a) .* abs(a) .^ (1/1.4);

        % VER2: power 0.65 table
        a = -1:0.001:1;
        table = sign(a) .* (1 - (1 - abs(a)) .^ (1/0.65));

    case 3
        %% VER2: power 1.8 table
        %a = -1:0.001:1;
        %table = sign(a) .* abs(a) .^ (1/1.8);

        % VER3: power 1.5 table
        a = -1:0.001:1;
        table = sign(a) .* (1 - (1 - abs(a)) .^ (1/1.5));
    end

    %convert x into [1,2,...,N] range
    N = length(table);
    p = round( (x+1.0)*(N-1)/2 + 1 );
    if p<1
        p = 1;
    elseif p>N
        p = N;
    end

    y = table(p);

return