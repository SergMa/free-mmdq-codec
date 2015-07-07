% x = [-1 .. +1]
% y = [-1 .. +1]
function y = a_compand( x )

    N = length(x);
    A = 87.6; %A-law compand
    A1 = 1/A;
    LA1 = 1/(1+log(A));

    y = zeros(1,N);
    for i=1:length(x)
        xx = x(i);
        ax = abs(xx);
        sx = sign(xx);

        if ax == 0
            y(i) = 0;
        elseif ax < A1
            y(i) = sx * A*ax*LA1;
        elseif ax <= 1
            y(i) = sx * (1+log(A*ax))*LA1;
        else
            y(i) = 1; %error
        end
    end
return
