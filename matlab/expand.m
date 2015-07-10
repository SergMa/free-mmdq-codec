%INPUTS:  x = [-1..+1]
%OUTPUTS: y = [-1..+1]
function y = expand( x , ver )

    switch ver
    case 1
        % VER1: power 1.3 table
        a = -1:0.01:1;
        table = sign(a) .* abs(a) .^ (1.2);

    case 2
        % VER2: power 1.5 table
        a = -1:0.01:1;
        table = sign(a) .* abs(a) .^ (1.4);

        %a = 0.01:0.01:1;
        %N=length(a);
        %table1 = zeros(1,N);
        %for i=1:N
        %    if a(i)<=0.1
        %        table1(i) = (0.3/0.1)*a(i);
        %    elseif a(i)<=0.9
        %        table1(i) = (0.4/0.8)*(a(i)-0.1) + 0.3;
        %    else
        %        table1(i) = (0.3/0.1)*(a(i)-0.9) + 0.7;
        %    end
        %end
        %table = [ -fliplr(table1) , 0 , table1 ];

        %a = 0.01:0.01:1;
        %N=length(a);
        %table1 = zeros(1,N);
        %for i=1:N
        %    if a(i)<=0.1
        %        table1(i) = (0.1/0.3)*a(i);
        %    else
        %        table1(i) = (0.9/0.7)*(a(i)-0.3) + 0.1;
        %    end
        %end
        %table = [ -fliplr(table1) , 0 , table1 ];

    case 3
        % VER3: power 0.7 table
        a = -1:0.01:1;
        table = sign(a) .* abs(a) .^ (1.8);

        %a = 0.01:0.01:1;
        %N=length(a);
        %table1 = zeros(1,N);
        %for i=1:N
        %    if a(i)<=0.3
        %        table1(i) = (0.1/0.3)*a(i);
        %    elseif a(i)<=0.7
        %        table1(i) = (0.8/0.4)*(a(i)-0.3) + 0.1;
        %    else
        %        table1(i) = (0.1/0.3)*(a(i)-0.7) + 0.9;
        %    end
        %end
        %table = [ -fliplr(table1) , 0 , table1 ];

    case 4
        % VER4: power 2 table
        a = -1:0.01:1;
        table = sign(a) .* abs(a) .^ (2);

    case 5
        % VER5: power 1.2 table
        a = -1:0.01:1;
        table = sign(a) .* abs(a) .^ (1.2);

    case 6
        % VER6: A-expand
        a = -1:0.01:1;
        table = a_expand(a);

    case 7
        % VER7
        % manually created conversion table (LINEAR-TO-LINEAR)
        %          0.05  0.10  0.15  0.20  0.25  0.30  0.35  0.40  0.45  0.50  0.55  0.60  0.65  0.70  0.75  0.80  0.85  0.90  0.95  1.00   % linear
        table1 = [ 0.05  0.10  0.15  0.20  0.25  0.30  0.35  0.40  0.45  0.50  0.55  0.60  0.65  0.70  0.75  0.80  0.85  0.90  0.95  1.00]; % output
        table = [ -fliplr(table1) , 0 , table1 ];
    end

    %convert x into [1,2,...,N] range
    N = length(table);
    p = round( (x+1.0)*(N-1)/2 + 1 );
    y = table(p);

return