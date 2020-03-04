function [xclicks, yclicks] = select_N_points(N_clicks)
%% Select N points on the plot
% In this example, the inflection points
title(sprintf('Select %d point(s)', N_clicks));
[xclicks, yclicks] = ginput(N_clicks);
title('');

% Add clicked point(s) to plot
hold on
for i=1:length(xclicks)
    plot(xclicks(i), yclicks(i), 'ro');
end

end