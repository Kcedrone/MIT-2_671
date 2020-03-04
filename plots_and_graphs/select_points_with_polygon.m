function [xs_in_poly, ys_in_poly] = select_points_with_polygon(x, y)
    % Get the axis limits to make a starting guess for the polygon vertices
    xlims = num2cell(get(gca, 'XLim'));
    [xmin, xmax] = deal(xlims{:});
    ylims = num2cell(get(gca, 'YLim'));
    [ymin, ymax] = deal(ylims{:});
    c_x = 0.5*(xmax - xmin);
    c_y = 0.5*(ymax - ymin);

    h = impoly(gca, [c_x,c_y; 1.2*c_x,c_y; 1.2*c_x,1.2*c_y; c_x,1.2*c_y]);
    title_str = {   'Drag edges to move polygon, drag vertices to alter polygon shape', ...
                    'Hold "A" when you click mouse to add a vertex', ...
                    'Double click inside region when finished'};
    title(title_str);
    addNewPositionCallback(h,@(p) title(title_str(:)));
    fcn = makeConstrainToRectFcn('impoly', get(gca,'XLim'), get(gca,'YLim'));
    setPositionConstraintFcn(h,fcn); 
    acceptedPosition = wait(h);
    api = iptgetapi(h);
    api.setColor('black');
    title({'','',''}); % Clear title
    
    % Check whether each point is in the polygon
    M=length(x);
    point_mask = zeros(M,1);
    for j=1:M
        point_mask(j) = inpolygon(x(j), y(j), acceptedPosition(:,1), acceptedPosition(:,2));
    end
    
    xs_in_poly = x(point_mask > 0);
    ys_in_poly = y(point_mask > 0);
    
    hold on;
    plot(xs_in_poly, ys_in_poly, 'r^');
  
end