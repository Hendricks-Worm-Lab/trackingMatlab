function getMaxIntensityStack(videoPath)
    [pathstr, name, ~] = fileparts(videoPath);
    [upperPath, ~, ~] = fileparts(pathstr);

    % save the max intensity stack
    % Create the full path for the output image
    outputFolder = 'maxIntensityStack';
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

    % read video file
    vidObj = VideoReader(videoPath);
    
    % Read the first frame as the initial stack
    maxIntensityStack = readFrame(vidObj);

    % frame counter
    frameCounter = 0;
    
    % Iterate through each frame in the video
    while hasFrame(vidObj)
        frameCounter = frameCounter + 1;

        frame = readFrame(vidObj);
        
        % Update the maximum intensity stack
        maxIntensityStack = max(maxIntensityStack, frame);

        % Use the backspace character to move the cursor back, then update progress
        if frameCounter>1
            fprintf(repmat('\b', 1, 34)); % Move the cursor back as needed, here it's 4 times
        end
        fprintf('Getting max intensity stack...%3d%%', round((frameCounter/vidObj.NumFrames)*100));
    end
    fprintf('\n');
     
    % save the max intensity stack
    imwrite(maxIntensityStack, outputVideoPath);
    
    fprintf('Finished max intensity stack for %s\n', name);
end