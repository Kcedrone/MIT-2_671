s = tf('s');

R = 6.8e3;
C = 0.1e-6;

tr_fcn = 1/(1+R*C*s);

figure('rend', 'painters', 'pos', [100 100 1000 800]);

% Plot options for Bode plot
opts = bodeoptions('cstprefs');
opts.FreqUnits = 'Hz'; % Radians are nice, but let's pay respect to Heinrich
opts.MagUnits = 'abs'; % dB, we don't need no stinkin' dB
opts.MagScale = 'log'; % Logarithmic mag. scale
opts.TickLabel.FontSize = 18;
opts.XLabel.FontSize = 24;
opts.YLabel.FontSize = 24;
opts.Title.FontSize = 24;
opts.Grid = 'on';
opts.GridColor = 0.2*[1,1,1];

bodeplot(tr_fcn, 'r-',   tr_fcn^2, 'g--' , tr_fcn^3, 'b:', opts);

linehandle = findobj(gcf, 'Type', 'Line');
for i=1:length(linehandle)
    set(linehandle(i), 'LineWidth', 3);
end


% Still working on reformatting built-in Bode plots...
axis_handles=findobj(gcf, 'Type', 'Axes');
for i=1:length(axis_handles)
    ax = axis_handles(i);
    
    % Change default font size (tick labels, legend, etc.)
    set(ax, 'FontSize', 20, 'FontName', 'Arial', 'LineWidth', 2);

    % Change font size for axis text labels
    set(get(ax, 'XLabel'),'FontSize', 24, 'FontWeight', 'Bold');
    set(get(ax, 'YLabel'),'FontSize', 24, 'FontWeight', 'Bold');
    
    ylab=get(get(ax,'ylabel'),'string');
    if strfind(ylab, 'Magnitude')
        mag_ax = ax;
    else
        phase_ax = ax;
    end

end

% Add manual data
% First order experimental data
f = [100, 500, 1000, 2000, 4000, 8000];
Vpp1 = [1.0133, 1.01, 0.99924, 0.9861, 0.97812, 0.97482];
Vpp2 = [1.0104, 0.94385, 0.79812, 0.55085, 0.32260, 0.17762];
ph12 = -1.0*[0.3, 20, 40, 58.4, 63.6, 72.08];

mag = Vpp2./Vpp1;

hold on
plot(f, mag, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r', 'Parent', mag_ax)
plot(f, ph12, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r', 'Parent', phase_ax)

% Third order experimental data
f = [100, 500, 1000, 2000, 2500, 3000, 5000];
Vpp1 = [1.011, 0.99554, 0.99130, 0.98624, 0.98215, 0.98176, 0.97516];
Vpp2 = [0.94423, 0.45986, 0.24027, 0.10848, 0.079115, 0.063145, 0.015117];
ph12 = -1.0*[24.47, 80.51, 117.73, 146.04, 164.98, 177, 204];

mag = Vpp2./Vpp1;

plot(f, mag, 'bo', 'MarkerSize', 10, 'MarkerFaceColor', 'b', 'Parent', mag_ax)
plot(f, ph12, 'bo', 'MarkerSize', 10, 'MarkerFaceColor', 'b', 'Parent', phase_ax)