function outputVideoPath = maskVideo(videoPath)
    [pathstr, name, ~] = fileparts(videoPath);
    [upperPath, ~, ~] = fileparts(pathstr);
    
    % Read the mask
    maskFolder = 'mask';
    maskName = strcat(name,'.png');
    maskPath = fullfile(upperPath, maskFolder, maskName);
    mask = imread(maskPath);

    % Find all non-zero element row and column indices
    [rows, cols] = find(mask);
    
    % Calculate top, bottom, left, and right bounds
    top = min(rows);
    bottom = max(rows);
    left = min(cols);
    right = max(cols);

    % cropped mask
    mask_cropped = mask(top:bottom, left:right);
    
    % Create the full path for the output video
    outputName = strcat(name,'.avi');
    outputFolder = 'masked';
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
    
    % open video file
    vidObj = VideoReader(videoPath);

    % Create an output video object
    outputVid = VideoWriter(outputVideoPath, 'Uncompressed AVI');
    outputVid.FrameRate = vidObj.FrameRate;
    open(outputVid);

    % Add a frame counter
    frameCounter = 0;

    % Loop through each frame in the video
    while hasFrame(vidObj)
        currentFrame = readFrame(vidObj);

        % Accumulate frame counter
        frameCounter = frameCounter + 1;
        
        % Mask
        img_masked = currentFrame(top:bottom, left:right);
        img_masked(repmat(~mask_cropped, [1 1 3])) = 0;
        
        % Write to the output video
        writeVideo(outputVid, img_masked);
        close;

        % Use the backspace character to move the cursor back, then update progress
        if frameCounter>1
            fprintf(repmat('\b', 1, 20)); % Move the cursor back as needed, here it's 4 times
        end
        fprintf('masking video...%3d%%', round((frameCounter/vidObj.NumFrames)*100));
    end
    fprintf('\n');

    % Close the output video file
    close(outputVid);

    fprintf('Finished mask video for %s\n', name);

end