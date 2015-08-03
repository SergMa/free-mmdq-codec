%get code, expand it into dvoice value
%INPUTS:  code = [0..(FACTOR-1)]
%         smooth = 1..SMOOTH_N
%OUTPUTS: dx = [-1..+1]
function dx = expand( code , smooth )

    global FACTOR;
    global SMOOTH_N;
    global EXPAND_TABLE; %contains SMOOTH_N*FACTOR elements

    %example (for FACTOR==8, SMOOTH_N==1):
    %EXPAND_TABLE=[ -1.0 -0.6 -0.4 0.0 +0.4 +0.6 +0.8 +1.0 ]
    %codes:           0    1    2   3    4    5    6    7


    %limit input value into [0..FACTOR-1] range
    %code = min(code, FACTOR-1);
    %code = max(code, 0       );

    if smooth<1 || smooth>SMOOTH_N
        error('invalid smooth');
    end

    N = length(code);
    dx = zeros(1,N);

    for i=1:N
        dx(i) = EXPAND_TABLE( smooth, code(i)+1 );
    end

return
