%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test of my_div function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
clear all;
close all;

fprintf(1,'test of my_div() function\n');

A = 678;

x = 1:1:1000;
N = length(x);
y1 = zeros(1,N);
y2 = zeros(1,N);
for i=1:N
    y1(i) = A/x(i);
    y2(i) = my_div(A,x(i));
end

figure(1);
subplot(2,1,1);
plot(x,y1,'r.-',x,y2,'b.-');
xlabel('x');
ylabel('A/x, my-div(A,x)');

subplot(2,1,2);
plot( (y1-y2)./y1,'r.-');
xlabel('x');
ylabel('err, %');
