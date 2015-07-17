%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Show compand/expand plots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
clear all;
close all;

x=-1:0.001:1;

c0 = compand(x,0);
c1 = compand(x,1);
c2 = compand(x,2);
c3 = compand(x,3);

e0 = expand(x,0);
e1 = expand(x,1);
e2 = expand(x,2);
e3 = expand(x,3);

z0 = expand(compand(x,0),0);
z1 = expand(compand(x,0),0);
z2 = expand(compand(x,0),0);
z3 = expand(compand(x,0),0);

figure(1);
plot(x,c0,'r.-', x,c1,'g.-', x,c2,'b.-', x,c3,'k.-');
title('compand(x)');
legend('ver0','ver1','ver2','ver3');
xlabel('x');
ylabel('y');
grid on;

figure(2);
plot(x,e0,'r.-', x,e1,'g.-', x,e2,'b.-', x,e3,'k.-');
title('expand(x)');
legend('ver0','ver1','ver2','ver3');
xlabel('x');
ylabel('y');
grid on;

figure(3);
plot(x,z0,'r.-', x,z1,'g.-', x,z2,'b.-', x,z3,'k.-');
title('expand(compand(x))');
legend('ver0','ver1','ver2','ver3');
xlabel('x');
ylabel('y');
grid on;
