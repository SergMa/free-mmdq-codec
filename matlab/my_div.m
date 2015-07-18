% d = my_div( a, b )
% divide a by b, where a<=b, a=[-32768..+32768], b=[0..+32768]
% returns fract16 result: [-32768..+32767]
%                         0 for b=0
% 
% Multiplicative division algorithm based on Taylor-series expansion:
%
% A. Liddicoat and M.J. Flynn, High-Performance Floating-Point Divide,
% Euromicro Symposium on Digital System Design, Sep. 2001 

function d = my_div( a, b )

    X0 = round( 1000*(1/b) )/1000; %X0=1/b in fract16 format

    Y1 = 1 - b*X0;
    Y2 = Y1*Y1;
    Y3 = Y1*Y2;
    d = 1 + Y1 + Y2 + Y3;
    d = d*X0;
    d = d*a;

return