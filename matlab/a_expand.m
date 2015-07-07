% y = [-1 .. +1]
% x = [-1 .. +1]
function x = a_expand( y )

    N = length(y);
    A = 87.6; %A-law compand
    A1 = 1/A;
    LA = 1 + log(A);
    LA1 = 1/LA;

    x = zeros(1,N);
    for i=1:N
        yy = y(i);
        ay = abs(yy);
        sy = sign(yy);

        if ay == 0
            x(i) = 0;
        elseif ay < LA1
            x(i) = sy * ay * LA * A1;
        elseif ay <= 1
            x(i) = sy * exp(ay*LA-1) * A1;
        else
            x(i) = 1; %error
        end
    end
return
