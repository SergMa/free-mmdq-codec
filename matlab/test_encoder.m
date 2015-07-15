clc;
clear all;
close all;

factor = 8;
ver = 3;

dv = -2*32768:2*32768;
ampdv = 2*32768;

sss   = compand( dv/ampdv , ver );
ddd   = fix( factor/2 * sss + factor/2 );
ddd   = min(ddd,factor-1);
data0 = fix( ddd );

sss2 = 32768 * expand( (data0+0.5)/factor - 0.5 , ver );


figure(1);

subplot(1,2,1);
hist(data0,100);

subplot(1,2,2);
plot(dv,data0);
grid on;


figure(2);

subplot(1,2,1);
hist(sss2,100);

subplot(1,2,2);
plot(dv,sss2);
grid on;