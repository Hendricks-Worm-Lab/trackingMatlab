function removeBackground(videoPath, frameRateScaler)
    % deal with option input
    if nargin < 2 || isempty(frameRateScaler)
        frameRateScaler = 1; % set 'defaultValue' as your desired default value
    end
    
    % get the path and name of the input video
    [pathstr, name, ~] = fileparts(videoPath);
    [upperPath, ~, ~] = fileparts(pathstr);

    % Read the masked video
    maskedFolder = 'masked';
    maskedName = strcat(name,'.avi');
    maskedVideoPath = fullfile(upperPath, maskedFolder, maskedName);

    % read the background
    backgroundFolder = 'background';
    backgroundName = strcat(name,'.png');
    backgroundPath = fullfile(upperPath, backgroundFolder, backgroundName);    
    averageFrame = imread(backgroundPath);
    
    % create a VideoWriter object to hold the processed video.
    % Create the full path for the output video
    outputName = strcat(name,'.avi');
    outputFolder = 'backgroundRemoved';
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
    
    % open the video file to prepare for writing the processed video
    vidObj = VideoReader(maskedVideoPath);

    % Create an output video object
    outputVid = VideoWriter(outputVideoPath, 'Uncompressed AVI');
    outputVid.FrameRate = vidObj.FrameRate * frameRateScaler;
    open(outputVid);
    
    % add a frame counter
    frameCounter = 0;
    
    % iterate through each frame of the video
    while hasFrame(vidObj)
        currentFrame = readFrame(vidObj);
        currentGrayFrame = rgb2gray(currentFrame);
        
        % cumulative frame counter
        frameCounter = frameCounter + 1;
        
        % compare the current frame and the average frame on a per-pixel basis
        % if the pixel is different, keep it; otherwise, set it to the background
        diffFrame = abs(double(currentGrayFrame) - double(averageFrame));
        
        % count the threshold
        % determine the integer boundaries of the histogram
        binEdges = min(diffFrame(:)):max(diffFrame(:));
        % Calculate the histogram using integer boundaries
        [counts, edges] = histcounts(diffFrame(:), binEdges);
        percentCounts = counts/length(diffFrame(:));
        % Identify bins with counts below a certain threshold. 
        % For instance, we can select bins lower than 0.001 as the standard for sparse areas.
        sparseThreshold = 1e-3;
        sparseBins = find(percentCounts <= sparseThreshold);

        % set a threshold to determine if a pixel is different, adjust the threshold as needed
        threshold = sparseBins(1);
        foregroundPixels = diffFrame > threshold;

        
        % set the foreground pixels to the value of the current frame, 
        % and the background pixels to 0 (or another background color)
        processedFrame = currentFrame;
        for channel = 1:3
            processedFrame(:, :, channel) = currentFrame(:, :, channel) .* uint8(foregroundPixels);
        end
        
        % write the processed frame to the output video
        writeVideo(outputVid, processedFrame);
    
        % use the backspace character to move the cursor back, then update the progress
        if frameCounter>1
            fprintf(repmat('\b', 1, 28)); % use the backspace character four times to move the cursor back as needed
        end
        fprintf('Removing background ... %3d%%', round((frameCounter/vidObj.NumFrames)*100));
    end
    fprintf('\n');

    % close the VideoWriter object to save the video
    close(outputVid);
    
    % close the video reader object
    delete(vidObj);

    fprintf('Finished removing background for %s\n', name);

end