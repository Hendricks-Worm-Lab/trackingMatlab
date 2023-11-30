function outputVideoPath = transparentVideo(videoPath, averageFrame, frameRate)
    % deal with option input
    if nargin < 3 || isempty(frameRate)
        frameRate = 30; % set 'defaultValue' as your desired default value
    end
    
    % get the path and name of the input video
    [pathstr, name, ~] = fileparts(videoPath);
    [upperPath, ~, ~] = fileparts(pathstr);
    
    % create a VideoWriter object to hold the processed video.
    outputVideoPath = fullfile(upperPath, 'transparent', strcat(name,'.avi'));
    outputVid = VideoWriter(outputVideoPath, 'Uncompressed AVI');
    outputVid.FrameRate = frameRate;
    open(outputVid);
    
    % reopen the video file to prepare for writing the processed video
    vidObj = VideoReader(videoPath);
    
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
        % 确定直方图的整数边界
        binEdges = min(diffFrame(:)):max(diffFrame(:));
        % 使用整数边界计算直方图
        [counts, edges] = histcounts(diffFrame(:), binEdges);
        percentCounts = counts/length(diffFrame(:));
        % 找出计数低于某个阈值的箱子
        % 例如，我们可以选择计数为0或1的箱子作为稀疏区域的标准
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
        fprintf(repmat('\b', 1, 26)); % use the backspace character four times to move the cursor back as needed
        fprintf('Removing background...%3d%%', round((frameCounter/vidObj.NumFrames)*100));
    end
    
    % close the VideoWriter object to save the video
    close(outputVid);
    
    % close the video reader object
    delete(vidObj);

end