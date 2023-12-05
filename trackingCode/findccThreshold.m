function [minSizeValue, maxSizeValue] = findccThreshold(videoFile)

% % 假设 videoFile 是视频文件的路径
% videoFile = 'R2WF2.avi';

% 全局变量声明
global minSizeValue maxSizeValue guiFigure originalAxes processedAxes minValueText maxValueText v currentFrame frameText;

% 初始化视频读取对象和当前帧数
v = VideoReader(videoFile);
currentFrame = 1;

% 初始化全局变量
minSizeValue = 100;
maxSizeValue = 500;
guiFigure = figure('Name', 'Image Processing GUI', 'NumberTitle', 'off', 'Position', [100, 100, 1200, 800]);

% 读取第一帧
frame1 = readFrame(v);
if size(frame1, 3) == 3
    frame1 = rgb2gray(frame1);
end

% 主函数入口
createGUI(frame1);

% 暂停执行，直到GUI关闭或uiresume被调用
uiwait(guiFigure);

% 函数继续执行时获取全局变量的值
global minSizeValue maxSizeValue;
end

function createGUI(frame1)
    global originalAxes processedAxes minValueText maxValueText frameText v currentFrame;

    % 创建子图以显示原始图像和处理后的图像
    originalAxes = subplot(3, 2, [1,3]);
    imshow(frame1);
    title('Original Image');

    processedAxes = subplot(3, 2, [2,4]);
    imshow(frame1);
    title('Processed Image');

    % 计算小步长和大步长
    minValue = 0;
    maxValue = 10000;
    stepSize = 25; % 每次点击的步长
    smallStep = stepSize / (maxValue - minValue);
    largeStep = smallStep; % 如果需要，这里可以设置不同的大步长
    
    % 设置滑动条和它们的文本标签
    minValueText = uicontrol('Style', 'text', 'Position', [950 220 120 20], 'String', 'Min Size: 100');
    uicontrol('Style', 'slider', 'Min', minValue, 'Max', maxValue, 'Value', 100, 'Position', [950 200 200 20], ...
        'SliderStep', [smallStep largeStep], 'Callback', @(src, evt) slider_callback(src, evt, 'Min'));
    
    maxValueText = uicontrol('Style', 'text', 'Position', [950 170 120 20], 'String', 'Max Size: 500');
    uicontrol('Style', 'slider', 'Min', minValue, 'Max', maxValue, 'Value', 500, 'Position', [950 150 200 20], ...
        'SliderStep', [smallStep largeStep], 'Callback', @(src, evt) slider_callback(src, evt, 'Max'));

    % 创建帧滑动条和它的文本标签
    frameText = uicontrol('Style', 'text', 'Position', [950 320 120 20], 'String', ['Frame: ' num2str(currentFrame)]);
    uicontrol('Style', 'slider', 'Min', 1, 'Max', v.NumFrames, 'Value', 1, 'Position', [950 300 200 20], ...
        'Callback', @(src, evt) frame_slider_callback(src, evt));

    % 添加一个按钮来结束选择
    uicontrol('Style', 'pushbutton', 'String', 'End Selection', 'Position', [950 100 120 40], 'Callback', @endSelection);
end

% 滑块回调函数
function slider_callback(src, ~, type)
    global minSizeValue maxSizeValue processedAxes minValueText maxValueText v currentFrame originalAxes;

    sliderValue = get(src, 'Value');

    % 更新全局变量和文本标签
    if strcmp(type, 'Min')
        minSizeValue = sliderValue;
        set(minValueText, 'String', ['Min Size: ' num2str(sliderValue, '%.0f')]);
    else
        maxSizeValue = sliderValue;
        set(maxValueText, 'String', ['Max Size: ' num2str(sliderValue, '%.0f')]);
    end

    % 重新读取当前帧并更新图像
    v.CurrentTime = (currentFrame-1) / v.FrameRate;
    frame1 = readFrame(v);
    if size(frame1, 3) == 3
        frame1 = rgb2gray(frame1); % 转换为灰度图像（如果需要）
    end

    % 更新原始图像和处理后的图像
    axes(originalAxes);
    imshow(frame1);
    title('Original Image');

    updateImageDisplay(frame1, minSizeValue, maxSizeValue);
end

% 帧滑块回调函数
function frame_slider_callback(src, ~)
    global currentFrame frameText v originalAxes;

    % 获取滑块值并更新当前帧数
    currentFrame = round(get(src, 'Value'));
    set(frameText, 'String', ['Frame: ' num2str(currentFrame)]);

    % 读取并显示新的帧
    v.CurrentTime = (currentFrame-1) / v.FrameRate;
    frame1 = readFrame(v);
    if size(frame1, 3) == 3
        frame1 = rgb2gray(frame1); % 转换为灰度图像（如果需要）
    end

    % 显示新帧
    axes(originalAxes);
    imshow(frame1);
    title('Original Image');

    % 重新调用 updateImageDisplay 以更新处理后的图像
    global minSizeValue maxSizeValue;
    updateImageDisplay(frame1, minSizeValue, maxSizeValue);
end

% 结束选择的按钮回调函数
function endSelection(~, ~)
    global guiFigure;

    % 显示选择的最大和最小值
    global minSizeValue maxSizeValue;
    disp(['Selected Min Size: ' num2str(minSizeValue)]);
    disp(['Selected Max Size: ' num2str(maxSizeValue)]);

    % 恢复 findccThreshold 函数的执行
    uiresume(guiFigure);

    % 关闭 GUI 窗口
    close(guiFigure);
end

% 更新图像显示
function updateImageDisplay(frame, minSize, maxSize)
    global processedAxes;

    % 在处理后的图像轴中显示图像
    axes(processedAxes);
    bw = imbinarize(frame); % 假设 frame 是灰度图像
    cc = bwconncomp(bw);
    stats = regionprops(cc, 'Area');
    areas = [stats.Area];
    idx = find(areas >= minSize & areas <= maxSize);
    filteredImage = ismember(labelmatrix(cc), idx);
    imshow(filteredImage);
    title(['Connected components with areas between ', num2str(minSize), ' and ', num2str(maxSize)]);
end