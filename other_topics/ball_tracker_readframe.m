clc;        % Clear command window
close all;  % Close all figure windows
clearvars;  % Clear all variables from workspace

% Open dialog to select mp4 or m4v video file
[filename, path, success] = uigetfile('*.mp4; *.m4v');
if ~success
    fprintf('Error, no file selected.\n');
    return
end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Student parameters
START_TIME__s = 1.5; % Start analyzing frames after this time
END_TIME__s = 2.5;   % Stop analyzing frames after this time
FRAME_INTERVAL = 1; % Analyze every Nth frame
% Some high speed cameras save/encode their videos at a different framerate
% than they actually recorded them. Set this to the expected framerate. 
% Or set to zero if you don't know.
expected_frame_rate__fps = 480.0; 
DEBUG_PLOTS = false; % Whether MATLAB should create DEBUG plots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% HSV color masking parameters from Color Thresholder App:
% Define thresholds for channel 1 based on histogram settings
channel1Min = 0.119;
channel1Max = 0.340;

% Define thresholds for channel 2 based on histogram settings
channel2Min = 0.147;
channel2Max = 0.883;

% Define thresholds for channel 3 based on histogram settings
channel3Min = 0.260;
channel3Max = 0.862;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
input_file = fullfile(path, filename);

v = VideoReader(input_file);
frame_rate__fps = v.FrameRate;

% Skip ahead to the starting time
start_frame_num = floor(START_TIME__s * frame_rate__fps);
for i = 1:start_frame_num
    if hasFrame(v)
        discard_frame = readFrame(v);
    end
end

dt_frame__s = 1./frame_rate__fps;
if (expected_frame_rate__fps ~= 0)
    fprintf('Using %.1f fps frame rate\n', expected_frame_rate__fps);
    dt_frame__s = 1./expected_frame_rate__fps;
end

hFig = figure(1);
set(hFig, 'Name', 'Reference image', 'Visible', 'Off');
vidFrame = readFrame(v);
imshow(vidFrame);
set(hFig, 'units', 'normalized','outerposition',[0 0 1 1], 'Visible', 'On');
set(hFig, 'units', 'pixels');

% Get video dims to make a starting guess for the polygon vertices
width = v.width;
height = v.height;

% Rectangle to select region of interest
% This helps MATLAB reduce the number of pixels it needs to process
title_str = {   'Resize rectangle to enclose region of interest', ...
                'Double click inside rectangle when finished'};
title(title_str);
h = imrect(gca, [0.4*width, 0.1*height, 0.2*width, 0.6*height]);
addNewPositionCallback(h,@(p) title(title_str(:)));
fcn = makeConstrainToRectFcn('imrect', get(gca,'XLim'), get(gca,'YLim'));
setPositionConstraintFcn(h,fcn); 
rect_coords = wait(h);
api = iptgetapi(h);
if ~ishandle(hFig)
    fprintf(2, 'Error: Figure 1 closed prematurely.\n');
    return
end
api.setColor('green');

% Line to set pixel-to-physical units scale
title_str = {   'Resize line to match scale feature', ...
                'Double click line when finished'};
title(title_str);
h = imline(gca, [0.2*width, 0.5*height; 0.8*width, 0.5*height]);
fcn = makeConstrainToRectFcn('imline', get(gca,'XLim'), get(gca,'YLim'));
setPositionConstraintFcn(h, fcn); 
line_coords = wait(h);
api = iptgetapi(h);
if ~ishandle(hFig)
    fprintf(2, 'Error: Figure 1 closed prematurely.\n');
    return
end
api.setColor('green');

pause(0.05);
title('Figure 1: Reference image', 'FontSize', 24);


% Process coords from rectangle of interest
% Region of interest to zoom in
% Format of accepted position is [x,y,width,height]
% origin is top left, x positive to right, y positive down
% x,y are coords of top left corner of rectangle
% width, height are width and height of rectangle
coords = num2cell(rect_coords);
[x,y,w,h] = coords{:};
roi_X = max(1, floor(x)):min(width, ceil(x + w));
roi_Y = max(1, floor(y)):min(height, ceil(y+h));

% Return focus to the command window
commandwindow;

%% 
% Require proper start and end times.
START_TIME__s = max(0.0, START_TIME__s);
END_TIME__s = min(v.Duration-(2./frame_rate__fps), END_TIME__s); 

nFrames = floor((END_TIME__s - START_TIME__s) * frame_rate__fps / FRAME_INTERVAL);
delta_t_between_frames__s = (FRAME_INTERVAL/frame_rate__fps);

nSt = 1;
nEnd = nFrames;

if DEBUG_PLOTS
    if nFrames > 10
        fprintf('Warning, you might want to disable debug mode!\n');
    end
end

%%
% Pre-allocate variables to save values from loop
x_centroid = zeros(nFrames, 1);      % X pixel position of centroid of ball
y_centroid = zeros(nFrames, 1);      % Y pixel position of centroid of ball
video_timestamp = zeros(nFrames, 1); % Time stamp of video frames

% Set up a progress bar and cancel button 
waitbar_handle = waitbar(0, ' ', 'Name', 'Processing video...',...
                        'CreateCancelBtn', 'setappdata(gcbf,''canceling'',1)');

setappdata(waitbar_handle, 'canceling', 0);

% Iterate over the number of video frames.
i = 0;
keep_going = true;
while(hasFrame(v) && keep_going)    
    i = i+1;
    if FRAME_INTERVAL > 1
        for discard_ctr = 1:(FRAME_INTERVAL - 1)
            discard_frame = readFrame(v);
        end
    end

    if v.CurrentTime > END_TIME__s
        keep_going = false;
    end
    
    % Calculate the time of the the video frame
%     nextTime = START_TIME__s + (i-1)*delta_t_between_frames__s;

    if getappdata(waitbar_handle, 'canceling')
        fprintf(2, 'Canceled out of video processing.\n');
        delete(waitbar_handle);
        return

    end
    waitbar(i/nFrames, waitbar_handle, sprintf('Time %.2f s / %.2f s', v.CurrentTime, END_TIME__s));
    
%     % Check that the next time is valid
%     if nextTime < v.Duration
%         v.CurrentTime = nextTime;
%     else
%         fprintf('Error: video duration exceeded.\n');
%         return
%     end
        
    % Store the time stamp of the video frame in the array for later.
    video_timestamp(i) = v.CurrentTime;
    
    % Collect the current video frame as an image
    img_raw = readFrame(v);

    % Extract the region of interest of the video frame
    img = img_raw(roi_Y, roi_X, :);
    
    % Convert video frame to HSV color system
    I = rgb2hsv(img);

    % Create mask based on HSV thresholds
    % That is, identify parts of the image that satisfy the HSV criteria
    BW = (I(:,:,1) >= channel1Min ) & (I(:,:,1) <= channel1Max) & ...
         (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
         (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max);

    % Initialize output masked image based on input image.
    maskedRGBImage = img;

    % Set pixels where BW is false to zero.
    maskedRGBImage(repmat(~BW,[1 1 3])) = 0;

    % Detect "regions" in the image. 
    % If the video is clear and the HSV filter is effective, one of them 
    % will be the object of interest i.e. the tennis ball
    % However, sometimes other objects will also satisfy the region
    % identifier and you will need to filter out false positive.
    blobs = regionprops(BW, 'all');
    
    if DEBUG_PLOTS
        % Keep at most 10 images, give unique fig no. in the 900s
        figure(900 + mod(100 + i, 10)); 
        hold off;
        imshow(maskedRGBImage);
        hold on;
        % Label the regions detected at their measured centroid
        for k = 1:numel(blobs)
            x = blobs(k).Centroid(1);
            y = blobs(k).Centroid(2);

            text(x, y, sprintf('%d', k), 'Color', 'r', 'FontWeight', 'bold');
        end
        hold off;
    end
    
    if isempty(blobs)
        fprintf('Error: no blob detected in frame %d\n', i);
        
        % If none detected, use dummy values
            x_centroid(i) = NaN;
            y_centroid(i) = NaN;

    else
        % There can be lots of false positives from background 
        % Try to pick the real one by approx shape and reasonable size
        % MATLAB has many other region properties that can be used!
        % Check https://www.mathworks.com/help/images/ref/regionprops.html
        % for more details
        viable = ([blobs.Eccentricity] < 0.7) & ... 
                 ([blobs.Area] >= 4000.0);

        % Select only the viable blobs
        viable_blobs = blobs(viable);

        % Find the largest viable blob, expected to be the tennis ball
        [max_area, idx_max_area] = max([viable_blobs.Area]);

        ball_blob = viable_blobs(idx_max_area);
        
        % If no blob was identified as the tennis ball, set 
        if isempty(ball_blob)
            fprintf('Error: no viable blob detected in frame %d\n', i);
            x_centroid(i) = NaN;
            y_centroid(i) = NaN;
        else

            x_centroid(i) = ball_blob.Centroid(1);
            y_centroid(i) = ball_blob.Centroid(2);
            
            if DEBUG_PLOTS
                % Label the blob MATLAB thinks is the ball
                hold on;
                x = x_centroid(i);
                y = y_centroid(i);

                text(x, y, 'ball', 'Color', 'y', 'FontWeight', 'bold');
                hold off;
            end
            
        end
    end
    
end
fprintf('Finished processing frames...\n');
delete(waitbar_handle);
%% Check that the extreme ball centroid pixel locations were inside the region of interest
[minX, iminX] = min(x_centroid);
[maxX, imaxX] = max(x_centroid);
[minY, iminY] = min(y_centroid);
[maxY, imaxY] = max(y_centroid);

h2 = figure(2);
prevTime = v.CurrentTime;
labels={'Min X', 'Max X', 'Min Y', 'Max Y'};
frame_index_type = [iminX, imaxX, iminY, imaxY];
for jj = 1:4 
    set(0, 'CurrentFigure', h2)
    frame_index = frame_index_type(jj);
    frame_label = labels(jj);
    
    v.currentTime= START_TIME__s + (frame_index-1)*delta_t_between_frames__s;
    img_raw = readFrame(v);    
    
    % Extract the region of interest
    img = img_raw(roi_Y, roi_X, :);

    subplot(1, 4, jj);
    imshow(img); hold on;
    plot(x_centroid(frame_index), y_centroid(frame_index), 'g^'); hold on;
    title(frame_label);
end
v.CurrentTime = prevTime;

% Region of Interest is considered to be set in a valid way if
% The min and max X and Y pixel locations are not at the ROI boundaries. 
valid_ROI = ((minX > 1) & (maxX < range(roi_X))) & ...
            ((minY > 1) & (maxY < range(roi_Y)));

if ~valid_ROI
    % If not valid ROI, bail out of the program
    fprintf('Error, marker may have left the region of interest.\n');
    return
end

%% Save all results to MAT file to resume data analysis without redoing video analysis
% save('process_video_results.mat');

%% Delete the progress bar if it is still open
F = findall(0,'type','figure','tag','TMWWaitbar');
delete(F);