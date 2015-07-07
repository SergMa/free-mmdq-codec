function [y,xdelay,ydelay] = hf100(x,xdelay,ydelay)
    %numerator
    b1 =  1.0000000;
    b2 = -1.0000000;
    %denominator
    a1 =  1.0000000;
    a2 = -0.9243905;
    %scale values
    k = 0.9621952;
    %process
    y = k * (b1*x + b2*xdelay - a2*ydelay);
    xdelay = x;
    ydelay = y;
return;
