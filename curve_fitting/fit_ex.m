clear all; clc;
t = 0:0.01:10.0; t= t(:);
f1 = 0.4;

y = 10*cos(2*pi*f1*t) + 1.0*randn(length(t),1) + 2;

figure;
plot(t, y)
title('Original data');
improvePlot;

fit_output = sine_fit(t, y);