function outputVideoPath = maskVideo(videoPath)
    [pathstr, name, ~] = fileparts(videoPath);
    [upperPath, ~, ~] = fileparts(pathstr);
    
    % 读取视频文件
    vidObj = VideoReader(videoPath);
    
    % 绘制蒙版
    % 读取第一帧并显示
    firstFrame = readFrame(vidObj);

    % 创建一个新的figure来显示第一帧
    figure;
    imshow(firstFrame);
    title('Draw a mask and save it');

    % 初始化一个空的蒙版图像
    mask = false(size(firstFrame, 1), size(firstFrame, 2));

    % 使用交互性工具绘制多个形状蒙版
    while true
        % 让用户选择绘制的形状类型
        choice = menu('Select shape type', 'Rectangle', 'Ellipse', 'Polygon', 'Freehand', 'Finish drawing');

        if choice == 1 % 绘制矩形
            h = imrect;
            wait(h);
            mask = mask | createMask(h);
        elseif choice == 2 % 绘制椭圆
            h = imellipse;
            wait(h);
            mask = mask | createMask(h);
        elseif choice == 3 % 绘制多边形
            h = impoly;
            wait(h);
            mask = mask | createMask(h);
        elseif choice == 4 % 自由绘制
            h = imfreehand;
            wait(h);
            mask = mask | createMask(h);
        elseif choice == 5 % 完成绘制
            break;
        end
    end

    % 关闭figure
    close;
    
    % 创建输出视频的完整路径
    outputName = strcat(name,'.avi');
    outputVideoPath = fullfile(upperPath, 'masked', outputName);
    
    % 创建一个输出视频对象
    outputVid = VideoWriter(outputVideoPath, 'Uncompressed AVI');
    outputVid.FrameRate = vidObj.FrameRate;
    open(outputVid);

    
    % 添加一个帧计数器
    frameCounter = 0;

    % 循环遍历视频中的每一帧
    while hasFrame(vidObj)
        currentFrame = readFrame(vidObj);

        % 累计帧计数器
        frameCounter = frameCounter + 1;
        
        % 蒙版
        img_masked = currentFrame;
        img_masked(repmat(~mask, [1 1 3])) = 0;
        
        % 写入输出视频
        writeVideo(outputVid, img_masked);
        close;

        % 使用退格字符回退光标位置，然后更新进度
        fprintf(repmat('\b', 1, 20)); % 根据需要回退光标，这里是4次
        fprintf('masking video...%3d%%', round((frameCounter/vidObj.NumFrames)*100));
    end
    
    fprintf('\n');

    % 关闭输出视频文件
    close(outputVid);

end