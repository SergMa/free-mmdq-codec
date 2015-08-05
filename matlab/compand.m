% code = compand( dx , smooth )
%
% Compands dx, outputs code
% GLOBAL:  FACTOR
%          SMOOTH_N
%          COMPAND_TABLE
% INPUTS:  dx = [-1..+1]
%          smooth = 1..SMOOTH_N
% OUTPUTS: code = [0..(FACTOR-1)]
function code = compand( dx , smooth )

    global FACTOR;
    global SMOOTH_N;
    global COMPAND_TABLE; %contains SMOOTH_N*(FACTOR-1) elements

    %FACTOR = 8;
    %SMOOTH_N = 4;

    %example (for FACTOR==8, SMOOTH_N==1):
    %COMPAND_TABLE=[  -0.8 -0.6 -0.4 0.0 +0.4 +0.6 +0.8   ]
    %codes:          0    1    2    3   4    5    6    7


    %limit input value into [-1..+1] range
    %dx = min(dx, 1);
    %dx = max(dx,-1);

    if smooth<1 || smooth>SMOOTH_N
        error('invalid smooth');
    end

    N = length(dx);
    code = zeros(1,N);

    for i=1:N
        if dx(i)<=COMPAND_TABLE(smooth,1)
            code(i) = 0;
        else
            for c=1:(FACTOR-1)
                if dx(i)>COMPAND_TABLE(smooth,c)
                    code(i) = c;
                end
            end
        end
    end

return
