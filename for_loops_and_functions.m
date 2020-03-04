%% Repetitive plotting with manual legend entry
clear all;
t = 0:0.1:50;
f = 0.01;
amp = 1.0;
y = amp*sin(2*pi*f*t);

figure;
plot(t, y, 'LineWidth', 2);
hold on;

f = 0.05;
amp = 2.0;
y = amp*sin(2*pi*f*t);
plot(t, y, 'LineWidth', 3);

t = 0:0.1:50;
f = 0.1;
amp = 3.0;
y = amp*sin(2*pi*f*t);
plot(t, y, 'LineWidth', 4);

xlabel('Time (s)');
ylabel('Amplitude');
legend('amp=1.0, f=0.01', 'amp=2.0, f=0.05', 'amp=3.0, f=0.1'); 
% The manual legend construction used above is common, but if you were to
% change the value of amp, or f for any of the 3 lines, or you changed the 
% order of the lines you would need to remember to change the legend too. 
improvePlot;

%% Using a for-loop and automatic legend entry
clear all;
t = 0:0.1:50;
fs = [0.01, 0.05, 0.1];           % Put the frequencies in order in an array
amps = [1.0, 2.0, 3.0];         % Put the amplitudes in order in an array
figure; hold on;

for i=1:length(fs)
    f = fs(i);                  % Take the i'th frequency
    amp = amps(i);              % Take the i'th amplitude
    y = amp*sin(2*pi*f*t);
    legend_entry = sprintf('amp=%.1f, f=%.1f', amp, f);
    % The sprintf function substitutes the variables you give it into a 
    % string according to the format you specify. Here, amp and f are 
    % substituted, in that order. Both variables are formated as floating 
    % point (decimal numbers) with 1 decimal place. The sprintf help entry 
    % has a comprehensive explanation of string formatting options in the
    % formatSpec section.
    plot(t, y, 'DisplayName', legend_entry, 'LineWidth', 1.5*i);
    % The line width changes automatically for each iteration of the loop
end

xlabel('Time (s)');
ylabel('Amplitude');
legend('show'); 
% The extra complication of sprintf makes the legend dynamic. If you add or
% change the value or order of frequencies or amplitudes, the legend will
% automatically handle it.
improvePlot;


    