function [h] = plot_residuals_standalone(x, y_observed, y_predicted)
if nargin == 0
    % Sample data for testing
    x = 1:10;
    y_observed = 2*x + randn(size(x));
    y_predicted = y_observed + 2*randn(size(x));
    
end
% Make variables into columns
x = x(:);
y_observed = y_observed(:);
y_predicted = y_predicted(:);

residual = y_observed - y_predicted;

% If there are more than 30 data points, we can fit a histogram to
% the residuals and see how well they approximate a normal
% distribution.
N_pts = length(x);

h = figure;
if N_pts >= 30
    subplot(2,1,1);
end
plot(x, residual, 'bo');
hold on;

title('Residual plot');
xlabel('X value');
ylabel('Residual (data - fit)');
improvePlot;
ax = gca;
xL = xlim;
line(xL, [0 0],'color','k', 'linewidth', ax.LineWidth) %x-axis

% Plot histogram of residuals
if N_pts >= 30
    N_bins = 20;

    subplot(2,1,2);
    %     h = histogram(residual, N_bins, 'Normalization', 'pdf', 'DisplayStyle', 'Stairs', 'LineWidth', 2, 'DisplayName', 'Histogram');
    h = histogram(residual, N_bins, 'Normalization', 'pdf', 'DisplayName', 'Histogram', 'LineWidth', 3);
    hold on;
    xlabel('Residual value');
    ylabel('Probability');
    h.EdgeColor = 'white';
    h.FaceAlpha = 0.5;
    bin_edges = h.BinEdges;

    % Fit data to a Guassian model (i.e. normal PDF)
    sd = std(residual);
    mu = mean(residual);
    x = linspace(min(bin_edges), max(bin_edges), 100);
    g = normpdf(x, mu, sd);
    plot(x, g, '-', 'LineWidth', h.LineWidth, 'Color', 'k', 'DisplayName', 'Norm. distr');
    legend('show');

    improvePlot;
    ax = gca;
    yL = ylim;
    line([0 0], yL, 'color', 'k', 'linewidth', ax.LineWidth, 'HandleVisibility', 'off'); % y-axis
end

end


