% s = sign(x)
% MATLAB sign() function emulation
% INPUTS: x = array
% RETURNS: 1 for x>0
%          0 for x==0
%         -1 for x<0
function s = sign(x)
    if isempty(x)
        s = [];
        return;
    end

    xs = size(x);
    s = zeros(xs);

    N = 1;
    for i=1:length(xs)
        N = N * xs(i);
    end

    for i = 1:N
        if x(i)<0
            s(i) = -1;
        elseif x(i)>0
            s(i) = 1;
        end
    end
return
