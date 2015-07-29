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
z1 = expand(compand(x,1),1);
z2 = expand(compand(x,2),2);
z3 = expand(compand(x,3),3);

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
        sss = compand( dvoice/AMPDV , s-1 );
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
        sss = expand( (dvoice+0.5)/FACTOR - 0.5 , s-1 );
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
