% Create sample data
t = 0:0.2:50;
y = 3*sin(0.02*2*pi*t - 0.2);

%% Example 1: Limited x range for fill
% Plot sample data
figure;
plot(t, y);
xlabel('Time (s)');
ylabel('Amplitude (a.u.)');
improvePlot;

% Define the upper bound of the fill area
y_upper = y;

% Define the lower bound of the fill area as y = 0
y_lower = zeros(size(t));

% Set a fill range, here for 3 <= t < 11
fill_range = (t >= 3) & (t < 11);

x = t(fill_range);
x2 = [x, fliplr(x)];
inBetween = [y_upper(fill_range), fliplr(y_lower(fill_range))];
hold on;
hf = fill(x2, inBetween, 'g');
% Adjust some of the parameters of the fill
hf.FaceAlpha = 0.5; % Make shading semi-transparent
hf.FaceColor = 'red';
hf.EdgeColor = 'red';

%% Example 2: Limited fill up to peak of y
% Plot sample data
figure;
plot(t, y);
xlabel('Time (s)');
ylabel('Amplitude (a.u.)');
improvePlot;

% Define the upper bound of the fill area
y_upper = y;

% Define the lower bound of the fill area as y = 0
y_lower = zeros(size(t));

% Set a fill range, here for positive y until max value of y
fill_range = (y >= 0) & (t <= t(y == max(y)));

x = t(fill_range);
x2 = [x, fliplr(x)];
inBetween = [y_upper(fill_range), fliplr(y_lower(fill_range))];
hold on;
hf = fill(x2, inBetween, 'm');
% Adjust some of the parameters of the fill
hf.FaceAlpha = 0.2; % Make shading semi-transparent
hf.FaceColor = 'm';
hf.EdgeColor = 'm';