%INPUTS:  x = [-1..+1]
%OUTPUTS: y = [-1..+1]
function y = compand( x , ver )

    switch ver
    case 1
        % VER1: power 1.3 table
        a = -1:0.01:1;
        table = sign(a) .* abs(a) .^ (1/1.3);

    case 2
        % VER2: power 1.5 table
        a = -1:0.01:1;
        table = sign(a) .* abs(a) .^ (1/1.5);

    case 3
        % VER3: power 1.8 table
        a = -1:0.01:1;
        table = sign(a) .* abs(a) .^ (1/1.8);

    case 4
        % VER2: power 2 table
        a = -1:0.01:1;
        table = sign(a) .* abs(a) .^ (1/2);

    case 5
        % VER3: power 1.2 table
        a = -1:0.01:1;
        table = sign(a) .* abs(a) .^ (1/1.2);

    case 6
        % VER4: A-compand
        a = -1:0.01:1;
        table = a_compand(a);

    case 7
        % VER6
        % manually created conversion table
        %          0.05  0.10  0.15  0.20  0.25  0.30  0.35  0.40  0.45  0.50  0.55  0.60  0.65  0.70  0.75  0.80  0.85  0.90  0.95  1.00   % linear
        table1 = [ 0.01  0.02  0.03  0.05  0.10  0.15  0.20  0.25  0.30  0.35  0.40  0.45  0.50  0.55  0.60  0.65  0.70  0.80  0.90  1.00]; % output
        table = [ -fliplr(table1) , 0 , table1 ];
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