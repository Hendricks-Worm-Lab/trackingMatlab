function getBackground(videoPath, startFrame)
    % deal with option input
    if nargin < 2 || isempty(startFrame)
        startFrame = 1; % set 'defaultValue' as your desired default value
    end 
    
    % get the path and name of the input video
    [pathstr, name, ~] = fileparts(videoPath);
    [upperPath, ~, ~] = fileparts(pathstr);    
       
    % Read the maskedVideo
    maskedFolder = 'masked';
    maskedName = strcat(name,'.avi');
    maskedVideoPath = fullfile(upperPath, maskedFolder, maskedName);
    vidObj = VideoReader(maskedVideoPath);

    % save the max intensity stack
    % Create the full path for the output image
    outputFolder = 'background';
    outputName = strcat(name,'.png');
    outputVideoPath = fullfile(upperPath, outputFolder, outputName);

    % Check if path exists
    if ~exist(fullfile(upperPath, outputFolder), 'dir')
        % Path does not exist, create it
        mkdir(fullfile(upperPath, outputFolder));
        fprintf('Created path: %s\n', fullfile(upperPath, outputFolder));
    else
        % Path already exists
        fprintf('Path already exists: %s\n', fullfile(upperPath, outputFolder));
    end
    
    % initialize the average frame and frame counter
    averageFrameStack = zeros(vidObj.Height, vidObj.Width, 'uint8');
    frameCounter = 0;
    
    % get the number of the frames to get average
    numFrame = vidObj.NumFrame-startFrame+1;
    
    % iterate through each frame of the video after start frame
    while hasFrame(vidObj) 
        % cumulative frame counter
        frameCounter = frameCounter + 1;

        if frameCounter >= startFrame
            currentFrame = readFrame(vidObj);
            % convert it to grayscale
            currentGrayFrame = rgb2gray(currentFrame);
            % average
            averageFrameStack = double(averageFrameStack) + double(currentGrayFrame);
        end

        % Use the backspace character to move the cursor back, then update progress
        if frameCounter>1
            fprintf(repmat('\b', 1, 26)); % Move the cursor back as needed, here it's 4 times
        end
        fprintf('Getting background ...%3d%%', round((frameCounter/vidObj.NumFrames)*100));
    end
    fprintf('\n');

    averageFrame = uint8(averageFrameStack / numFrame);
     
    % save the max intensity stack
    imwrite(averageFrame, outputVideoPath);
    
    fprintf('Finished getting background for %s\n', name);

end