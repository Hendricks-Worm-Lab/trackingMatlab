function getHeadLifting(videoPath)
    % get the path and name of the input video
    [pathstr, name, ~] = fileparts(videoPath);
    [upperPath, ~, ~] = fileparts(pathstr);
    
    % Read the tracks
    tracksFolder = 'tracks';
    tracksName = strcat(name,'.mat');
    tracksPath = fullfile(upperPath, tracksFolder, tracksName);
    load(tracksPath, 'tracks')

    % read the masked video
    maskedFolder = 'masked';
    maskedName = strcat(name,'.avi');
    maskedVideoPath = fullfile(upperPath, maskedFolder, maskedName);
    videoReader = VideoReader(maskedVideoPath);

    % create a VideoWriter object to hold the processed video.
    % Create the full path for the output video
    outputName = strcat(name,'.avi'); outputvariableName = strcat(name,'.mat');
    outputFolder = 'headLifting';
    outputVideoPath = fullfile(upperPath, outputFolder, outputName);
    outputVariablePath = fullfile(upperPath, outputFolder, outputvariableName);

    % Check if path exists
    if ~exist(fullfile(upperPath, outputFolder), 'dir')
        % Path does not exist, create it
        mkdir(fullfile(upperPath, outputFolder));
        fprintf('Created path: %s\n', fullfile(upperPath, outputFolder));
    else
        % Path already exists
        fprintf('Path already exists: %s\n', fullfile(upperPath, outputFolder));
    end

    outputVideo = VideoWriter(outputVideoPath, 'Uncompressed AVI');
    open(outputVideo);
    frameCounter = 1;
    radius = 45;
    
    maxDifference = zeros(videoReader.NumFrames, 1);
    timeShift = 30;
    
    % 设置缩放比例
    scaleFactor = 2; % 2倍放大
    
    previousFrame = NaN;
    while hasFrame(videoReader) && frameCounter + timeShift <= videoReader.NumFrames
        frame = readFrame(videoReader);
        
        % 找到头所在的大致位置
        centerX = tracks.positions(frameCounter + timeShift, 1);
        centerY = tracks.positions(frameCounter + timeShift, 2);
        if isempty(centerX)
            break
        end
        
        % 创建一个与视频帧大小相同的逻辑遮罩
        [rows, columns, ~] = size(frame);
        [xx, yy] = meshgrid(1:columns, 1:rows);
        mask = (xx - centerX(1)).^2 + (yy - centerY(1)).^2 <= radius^2;
        
        % 创建一个只有圆形区域的帧
        maskedFrame = frame;
        if frameCounter>1
            maskPreviousFrame = previousFrame;
        else
            maskPreviousFrame = frame;
        end
        for channel = 1:3 % 处理每个颜色通道
            maskedFrame(:,:,channel) = maskedFrame(:,:,channel) .* uint8(mask);
            maskPreviousFrame(:,:,channel) = maskPreviousFrame(:,:,channel) .* uint8(mask);
        end
    
        % 找到最大亮度区别的坐标和亮度值
        maskedGrayFrame = rgb2gray(maskedFrame); % 转换为灰度图像
        previousMaskedGrayFrame = rgb2gray(maskPreviousFrame);
        if frameCounter>1
            difference = maskedGrayFrame-previousMaskedGrayFrame;
            maxDifference(frameCounter) = max(difference(:));
        else
            difference = maskedGrayFrame;
        end
        previousFrame = frame;
        
        % 创建一个减去前一帧的帧
        differenceFrame = frame;
            for channel = 1:3 % 处理每个颜色通道
                differenceFrame(:,:,channel) = difference;
            end
    
        % 裁剪和缩放帧
        x1 = round(centerX) - radius * scaleFactor;
        x2 = round(centerX) + radius * scaleFactor;
        y1 = round(centerY) - radius * scaleFactor;
        y2 = round(centerY) + radius * scaleFactor;
        
        % 计算裁剪帧的目标尺寸
        targetWidth = radius * scaleFactor * 2;
        targetHeight = radius * scaleFactor * 2;
        
        % 创建一个新的全黑帧
        croppedFrame = zeros(targetHeight, targetWidth, size(frame, 3), 'like', frame);
        
        % 计算原始帧中的有效区域
        validX1 = max(1, x1);
        validX2 = min(columns, x2);
        validY1 = max(1, y1);
        validY2 = min(rows, y2);
        
        % 计算在新帧中的对应位置
        newX1 = validX1 - x1 + 1;
        newX2 = validX2 - x1 + 1;
        newY1 = validY1 - y1 + 1;
        newY2 = validY2 - y1 + 1;
        
        % 将原始帧的有效区域复制到新帧的对应位置
        croppedFrame(newY1:newY2, newX1:newX2, :) = frame(validY1:validY2, validX1:validX2, :);
    
        % 在裁剪后的帧上绘制圆圈和文本
        if maxDifference(frameCounter) >= 10
            croppedFrameWithCircle = insertShape(croppedFrame, 'Circle', [centerX - x1, centerY - y1, radius], 'LineWidth', 2, 'Color', 'green');
        else
            croppedFrameWithCircle = insertShape(croppedFrame, 'Circle', [centerX - x1, centerY - y1, radius], 'LineWidth', 2, 'Color', 'red');
        end
    
        frameCounter = frameCounter + 1;
        imshow(croppedFrameWithCircle); pause(0.1); % pause is for image visualiz.
    
        % 写入新视频
        writeVideo(outputVideo, croppedFrameWithCircle);
        
        % use the backspace character to move the cursor back, then update the progress
        if frameCounter>1
            fprintf(repmat('\b', 1, 35)); % use the backspace character four times to move the cursor back as needed
        end
        fprintf('Getting head liftings ... %4d/%4d', frameCounter + timeShift, videoReader.NumFrames);
    end
    fprintf('\n');

    close(outputVideo);
    
    save(outputVariablePath, 'maxDifference');

    fprintf('Finished finding head lifting for %s\n', name);
end