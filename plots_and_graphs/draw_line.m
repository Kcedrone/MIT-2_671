function [lineCoords] = draw_line()
    % returns lineCoords, format is [x1, y2; x2, y2]
    % Get the axis limits to make a starting guess for the line endpoints
    xlims = num2cell(get(gca, 'XLim'));
    [xmin, xmax] = deal(xlims{:});
    ylims = num2cell(get(gca, 'YLim'));
    [ymin, ymax] = deal(ylims{:});
    c_x = 0.5*(xmax - xmin);
    c_y = 0.5*(ymax - ymin);

    h = imline(gca, [c_x, c_y; 1.2*c_x, 1.2*c_y]);
    title_str = {   'Drag ends to alter line', ...
                    'Double click line when finished'};
    title(title_str);
    addNewPositionCallback(h,@(p) title(title_str(:)));
    fcn = makeConstrainToRectFcn('imline', get(gca,'XLim'), get(gca,'YLim'));
    setPositionConstraintFcn(h, fcn); 
    lineCoords = wait(h);
    api = iptgetapi(h);
    api.setColor('black');
    title({'',''}); % Clear title
    
  
end