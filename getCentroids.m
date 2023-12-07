function getCentroids(videoPath)
    % get the path and name of the input video
    [pathstr, name, ~] = fileparts(videoPath);
    [upperPath, ~, ~] = fileparts(pathstr);
    
    % Read the ccThreshold
    ccThresholdFolder = 'ccThreshold';
    ccThresholdName = strcat(name,'.mat');
    ccThresholdPath = fullfile(upperPath, ccThresholdFolder, ccThresholdName);
    load(ccThresholdPath, 'minArea', 'maxArea')

    % Read the background removed video
    backgoundRemovedFolder = 'backgroundRemoved';
    backgoundRemovedName = strcat(name,'.avi');
    backgoundRemovedVideoPath = fullfile(upperPath, backgoundRemovedFolder, backgoundRemovedName);

    % read video
    vidObj = VideoReader(backgoundRemovedVideoPath);
    
    % create a VideoWriter object to hold the processed video.
    % Create the full path for the output video
    outputName = strcat(name,'.avi'); outputVariableName = strcat(name,'.mat');
    outputFolder = 'centroids';
    outputVideoPath = fullfile(upperPath, outputFolder, outputName);
    outputVariablePath = fullfile(upperPath, outputFolder, outputVariableName);

    % Check if path exists
    if ~exist(fullfile(upperPath, outputFolder), 'dir')
        % Path does not exist, create it
        mkdir(fullfile(upperPath, outputFolder));
        fprintf('Created path: %s\n', fullfile(upperPath, outputFolder));
    else
        % Path already exists
        fprintf('Path already exists: %s\n', fullfile(upperPath, outputFolder));
    end
    
    % creat a ouptput video object
    outputVid = VideoWriter(outputVideoPath, 'Uncompressed AVI');
    outputVid.FrameRate = vidObj.FrameRate;
    open(outputVid);
    
    % initialize a frame counter
    frameCounter = 0;
    
    % initialize a structure array to store centroid information
    centroidsStruct = struct([]);
    
    while hasFrame(vidObj)
        % read a frame
        frame = readFrame(vidObj);
        
        % increment the frame counter
        frameCounter = frameCounter + 1;
        
        % process frames
        videoFrames = im2gray(frame);

        % remove small and large connected component
        % minArea = 100; maxArea = 1100;
        bwImg = removeConnectivity(videoFrames, minArea, maxArea);

        % compute connected component
        CC = bwconncomp(bwImg);
    
        % initialize variable to store centroids
        centroids = zeros(CC.NumObjects, 2);
            
        % iterate through each connected component
        for i = 1:CC.NumObjects
            % get all pixel indices of the current component
            pixelIdx = CC.PixelIdxList{i};
                
            % convert linear indices to subscript indices
            [rows, cols] = ind2sub(size(bwImg), pixelIdx);
                
            % calculate the centroid of the current component
            centroids(i,1) = mean(cols); % x
            centroids(i,2) = mean(rows); % y
        end
        
        cImg = repmat(bwImg, [1, 1, 3]);
        % Define the radius around each point to turn red (adjust this as needed)
        radius = 1;
        
        for i = 1:size(centroids, 1)
            y = round(centroids(i, 2));
            x = round(centroids(i, 1));
        
            % Create a mask to specify the region around the point
            [X, Y] = meshgrid(x-radius:x+radius, y-radius:y+radius);
            
            % Ensure that the indices are within the image boundaries
            X(X < 1) = 1;
            X(X > size(cImg, 2)) = size(cImg, 2);
            Y(Y < 1) = 1;
            Y(Y > size(cImg, 1)) = size(cImg, 1);
        
            % Set the pixels in the specified region to red
            cImg(Y, X, 1) = 1; % Set the red channel to 1
            cImg(Y, X, 2) = 0; % Set the green channel to 0
            cImg(Y, X, 3) = 0; % Set the blue channel to 0
        end
    
        % store centroid information in a structure
        centroidsStruct(frameCounter).CentroidX = centroids(:,1);
        centroidsStruct(frameCounter).CentroidY = centroids(:,2);

        % write intp output video
        writeVideo(outputVid, cImg);
        close;
    
        % use the backspace character to move the cursor back, then update the progress
        if frameCounter>1
            fprintf(repmat('\b', 1, 26)); % use the backspace character four times to move the cursor back as needed
        end
        fprintf('Getting centroids ... %3d%%', round((frameCounter/vidObj.NumFrames)*100));
    end
    fprintf('\n');

    % 关闭输出视频文件
    close(outputVid);

    save(outputVariablePath, "centroidsStruct");

    fprintf('Finished getting centroids for %s\n', name);
end