s = tf('s');

alpha = 1.0;
w_n = 2*pi*1.5;
zeta = 0.01;

tr_fcn = alpha*w_n^2/(s^2 + (zeta*w_n)*s + w_n^2);
tr_fcn2 = alpha*w_n^2/(s^2 + (10*zeta*w_n)*s + w_n^2);
tr_fcn3 = alpha*w_n^2/(s^2 + (100*zeta*w_n)*s + w_n^2);

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

% Create the Bode plot
figure('rend', 'painters', 'pos', [100 100 1000 800]);
bodeplot(tr_fcn, 'r-', tr_fcn2, 'g--', tr_fcn3, 'b:', opts);

% Make the line(s) thicker
linehandle = findobj(gcf, 'Type', 'Line');
for i=1:length(linehandle)
    set(linehandle(i), 'LineWidth', 3);
end

% Iterate over axes for format tweaks
axis_handles=findobj(gcf, 'Type', 'Axes');
for i=1:length(axis_handles)
    ax = axis_handles(i);
    ax.YRuler.LineWidth=2.0;
    ax.YGridHandle.LineWidth=2.0;
    ax.YGridHandle.MinorLineWidth=2.0;
    
    ax.XRuler.LineWidth=2.0;
    ax.XGridHandle.LineWidth=2.0;
    ax.XGridHandle.MinorLineWidth=2.0;
    
    % Find magnitude axis handle for subsequent plotting 
    % (e.g. add experimental data to the plot)
    ylab=get(get(ax,'ylabel'),'string');
    if contains(ylab, 'Magnitude')
        mag_ax = ax;
    else
        phase_ax = ax;
    end
end

legend(mag_ax,'zeta=0.01','zeta=0.1','zeta=1.0','Location', 'NorthEast');