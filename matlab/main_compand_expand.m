%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Show compand/expand plots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
clear all;
close all;

global COM_PWR;
global EXP_PWR;

%compand/expand functions powers
COM_PWR = [1.0  1.10  1.20  1.20];  % best for MMDQ-32
EXP_PWR = [1.0  1.10  1.20  1.20];

x=-1:0.05:1;

c1 = compand(x,1);
c2 = compand(x,2);
c3 = compand(x,3);
c4 = compand(x,4);

e1 = expand(x,1);
e2 = expand(x,2);
e3 = expand(x,3);
e4 = expand(x,4);

z1 = expand(compand(x,1),1);
z2 = expand(compand(x,2),2);
z3 = expand(compand(x,3),3);
z4 = expand(compand(x,4),4);

figure(1);
plot(x,c1,'k-', x,c2,'k-x', x,c3,'k.-', x,c4,'k-+');
title('compand(x)');
legend('ver1','ver2','ver3','ver4');
xlabel('x');
ylabel('y');
grid on;

figure(2);
plot(x,e1,'k-', x,e2,'k-x', x,e3,'k.-', x,e4,'k-+');
title('expand(x)');
legend('ver1','ver2','ver3','ver4');
xlabel('x');
ylabel('y');
grid on;

figure(3);
plot(x,z1,'k-', x,z2,'k-x', x,z3,'k.-', x,z4,'k-+');
title('expand(compand(x))');
legend('ver1','ver2','ver3','ver4');
xlabel('x');
ylabel('y');
grid on;

break

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Quantized versions for defined factor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

AMPDV = 2*32768;
BITS_PER_SAMPLE = 3;
FACTOR = 2^BITS_PER_SAMPLE;

%Fill compand table
x  = -AMPDV:1:AMPDV;
N = length(x);
y  = zeros(4,N);
for s=1:4
    for i=1:N
        dvoice = x(i);
        sss = compand( dvoice/AMPDV , s );
        ddd = FACTOR/2 * sss + FACTOR/2;
        ddd = fix(ddd);
        ddd = min(ddd,FACTOR-1);
        y(s,i) = fix( ddd );
    end
end

%Fill expand table
v = 0:FACTOR-1;
z = zeros(4,FACTOR);
for s=1:4
    for i=1:FACTOR
        dvoice = i-1;
        sss = expand( (dvoice+0.5)/FACTOR - 0.5 , s );
        z(s,i) = sss;
    end
end

%expand(compand(inp))
y2 = zeros(4,N);
for s=1:4
    for i=1:N
        inp = x(i);
        com = y(s,inp+AMPDV+1);
        exp = 2*AMPDV*z(s,com+1);
        y2(s,i) = exp;
    end
end

%Plot graphics
figure(4);
for s=1:4
    subplot(2,2,s);
    plot(x,y(s,:),'r.-');
    title(['compand ver.',num2str(s)]);
    xlabel('inp');
    ylabel('out');
    grid on;
end

figure(5);
for s=1:4
    subplot(2,2,s);
    plot(v,z(s,:),'r.-');
    title(['expand ver.',num2str(s)]);
    xlabel('inp');
    ylabel('out');
    grid on;
end

figure(6);
for s=1:4
    subplot(2,2,s);
    plot(x,y2(s,:),'r.-', x,x,'b');
    title(['expand(compand(inp)) ver.',num2str(s)]);
    xlabel('inp');
    ylabel('out');
    grid on;
end
