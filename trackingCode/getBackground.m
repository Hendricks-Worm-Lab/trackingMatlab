function averageFrame = getBackground(videoPath, startFrame)
    % deal with option input
    if nargin < 2 || isempty(startFrame)
        startFrame = 1; % set 'defaultValue' as your desired default value
    end    
    
    vidObj = VideoReader(videoPath);
    
    
    % initialize the average frame and frame counter
    averageFrameStack = zeros(vidObj.Height, vidObj.Width, 'uint8');
    frameCounter = 0;

    numFrame = vidObj.NumFrame-startFrame+1;
    
    % iterate through each frame of the video after start frame
    while hasFrame(vidObj) 
        if frameCounter >= startFrame
            currentFrame = readFrame(vidObj);
            % convert it to grayscale
            currentGrayFrame = rgb2gray(currentFrame);
            % average
            averageFrameStack = double(averageFrameStack) + double(currentGrayFrame);
        end
        
        % cumulative frame counter
        frameCounter = frameCounter + 1;

        % 使用退格字符回退光标位置，然后更新进度
        fprintf(repmat('\b', 1, 25)); % 根据需要回退光标，这里是4次
        fprintf('getting background...%3d%%', round((frameCounter/vidObj.NumFrames)*100));
    end
    averageFrame = uint8(averageFrameStack / numFrame);

    fprintf('\n');

end