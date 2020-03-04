close all;
rng default; % For consistency

% % Linear data
% x = 0.25:0.01:0.75;
% y = 3.2*x + 2.2 + 0.25*randn(size(x));
% linear_fit(x, y, 1);

% % Sinusoidal data
% x = 0:0.01:0.75;
% y = 3.2*sin(2*pi*x) + 5.0 + 0.2*randn(size(x));
% linear_fit(x, y, 1);
% 
% % Sinusoidal data on domain s.t. range is reasonably linear
x = 0.25:0.01:0.75;
y = 3.2*sin(2*pi*x) + 5.0 + 0.2*randn(size(x));
linear_fit(x, y, 1);
% 

% Strongly quadratic data
% x = -10:10;
% y = 2.0*(x - 2.0).^2 + 3.0*x + 3.0 + 5.0*randn(size(x));
% linear_fit(x, y, 1);

% Weakly quadratic data
% x = -10:10;
% y = 0.12*x.^2 + 3.0*x + 3.0 + 0.5*randn(size(x));
% linear_fit(x, y, 1);

% Exponential data
% x = -3:0.1:6;
% y = 0.5*exp(0.3*x)+3+0.2*randn(size(x));
% linear_fit(x, y, 1);