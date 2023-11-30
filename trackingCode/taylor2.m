videoFile = '2023_11_27_day_3_N2_worm_1-11272023135527-0000.avi'; % 视频文件
videoReader = VideoReader(videoFile);
outputVideo = VideoWriter('outputVideo4.mp4', 'MPEG-4');
% open(outputVideo);
frameCounter = 1;
radius = 45;

maxBrightness = zeros(videoReader.NumFrames, 1);
maxDifference = zeros(videoReader.NumFrames, 1);
velocity = zeros(videoReader.NumFrames, 1);
timeShift = 45;

% 设置缩放比例
scaleFactor = 2; % 2倍放大

previousX = NaN;
previousY = NaN;
previousTime = NaN;
previousFrame = NaN;

while hasFrame(videoReader) && frameCounter + timeShift < videoReader.NumFrames
    frame = readFrame(videoReader);
    
    % 计算速度
    currentTime = videoReader.CurrentTime;
    if ~isnan(previousX) && ~isnan(previousY) && ~isnan(previousTime)
        displacement = sqrt((centerX - previousX)^2 + (centerY - previousY)^2); % 位移
        timeInterval = currentTime - previousTime; % 时间间隔
        velocity(frameCounter) = displacement / timeInterval; % 速度
        disp(['帧 ', num2str(frameCounter - 1), ' 到帧 ', num2str(frameCounter), ' 之间的速度: ', num2str(velocity(frameCounter))]);
    end
    
    % 更新上一个位置和时间
    previousX = centerX;
    previousY = centerY;
    previousTime = currentTime;
    
    
%     if frameCounter >=3
%         a = A(frameCounter-2)/19.1509;
%     else
%         a = 1;
%     end
%     centerX = centroidsStruct(frameCounter + round(timeShift*a)).CentroidX;
%     centerY = centroidsStruct(frameCounter + round(timeShift*a)).CentroidY;
    centerX = centroidsStruct(frameCounter + timeShift).CentroidX;
    centerY = centroidsStruct(frameCounter + timeShift).CentroidY;
    
    % 创建一个与视频帧大小相同的逻辑遮罩
    [rows, columns, ~] = size(frame);
    [xx, yy] = meshgrid(1:columns, 1:rows);
    mask = (xx - centerX).^2 + (yy - centerY).^2 <= radius^2;
    
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

    % 找到最大亮度点的坐标和亮度值
    maskedGrayFrame = rgb2gray(maskedFrame); % 转换为灰度图像
    [maxBrightness(frameCounter), maxIdx] = max(maskedGrayFrame(:));
    [maxY, maxX] = ind2sub(size(maskedGrayFrame), maxIdx);
    
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
    x1 = max(1, centerX - radius * scaleFactor);
    x2 = min(columns, centerX + radius * scaleFactor);
    y1 = max(1, centerY - radius * scaleFactor);
    y2 = min(rows, centerY + radius * scaleFactor);
    croppedFrame = frame(y1:y2, x1:x2, :);
%     croppedFrame = differenceFrame(y1:y2, x1:x2, :);

    % 在裁剪后的帧上绘制圆圈和文本
    if maxDifference(frameCounter) >= 20
        croppedFrameWithCircle = insertShape(croppedFrame, 'Circle', [centerX - x1, centerY - y1, radius], 'LineWidth', 2, 'Color', 'green');
    else
        croppedFrameWithCircle = insertShape(croppedFrame, 'Circle', [centerX - x1, centerY - y1, radius], 'LineWidth', 2, 'Color', 'red');
    end

    frameCounter = frameCounter + 1;
    imshow(croppedFrameWithCircle)

    % 写入新视频
    % writeVideo(outputVideo, croppedFrameWithCircle);
end
close(outputVideo);