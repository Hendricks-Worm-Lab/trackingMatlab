function centroidsStruct = getCentroids(videoPath)
        
    % find minArea and maxArea
    [minArea, maxArea] = findccThreshold(videoPath);

    [pathstr, name, ext] = fileparts(videoPath);
    [upperPath, ~, ~] = fileparts(pathstr);
    
    outputName = strcat(name, ext);
    outputVideoPath = fullfile(upperPath, 'centroids', outputName);
    
    % read video
    vidObj = VideoReader(videoPath);
    
    % obtain video information
    videoWidth = vidObj.Width;
    videoHeight = vidObj.Height;
    frameRate = vidObj.FrameRate;

    % 创建一个输出视频对象
    outputVid = VideoWriter(outputVideoPath, 'Uncompressed AVI');
    outputVid.FrameRate = frameRate;
    open(outputVid);
    
    % initialize a frame counter
    allFrameCount = 0;
    
    % initialize a structure array to store centroid information
    centroidsStruct = struct([]);
    
    while hasFrame(vidObj)
        % read a frame
        frame = readFrame(vidObj);
        
        % increment the frame counter
        allFrameCount = allFrameCount + 1;
        
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
        centroidsStruct(allFrameCount).CentroidX = centroids(:,1);
        centroidsStruct(allFrameCount).CentroidY = centroids(:,2);

        % 写入输出视频
        writeVideo(outputVid, cImg);
        close;
    
        % 使用退格字符回退光标位置，然后更新进度
        fprintf(repmat('\b', 1, 4)); % 根据需要回退光标，这里是4次
        fprintf('%3d%%', round((allFrameCount/vidObj.NumFrames)*100));
    end
    
    fprintf('\n');

    % 关闭输出视频文件
    close(outputVid);
end