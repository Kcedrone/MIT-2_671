[file, path] = uigetfile('*.png');
ff = fullfile(path, file);

%%
img = imread(ff);

h = figure;
set(h, 'Visible', 'Off');
imshow(flipud(img));
hold on;
set(gca,'YDir','normal');
set(h, 'Visible', 'On');

button = 1;
xcoords = [];
ycoords = [];
while(button ~= 3)
    [x, y, button] = ginput(1);
    plot(x, y, 'r+');
    xcoords = [xcoords; x];
    ycoords = [ycoords; y];
end
hold off;

figure;
plot(xcoords, ycoords);