clc; clear; close all;

%% video path
% data path
dataPath = 'data';

% video file
videoName = '2023_11_27_day_3_N2_worm_1-11272023135527-0000.avi';

% raw data full file
videoFileRaw = fullfile(dataPath, '20231127', videoName);

%% mask video
videoFileMasked = maskVideo(videoFileRaw);

%% average frames (get the background of the video)
startFrame = 1;
averageFrame = getBackground(videoFileMasked, startFrame);

%% remove the background of the video
frameRate = 90;
videoFileTransparent = transparentVideo(videoFileMasked, averageFrame, frameRate);

%% get centroids
centroidsStruct = getCentroids(videoFileTransparent);

%% Calculate tracks
tracks = getTracks(centroidsStruct);

%% figure
g = figure; % 创建一个新图形窗口
hold on; % 保持当前图形，这样新添加的线条或点不会擦除旧的内容

frameNum  = length(centroidsStruct);

% 可选：为不同的轨迹设置颜色
colors = spring(frameNum); % 使用HSV颜色图为每条轨迹生成不同的颜色

% 遍历每条轨迹
for i = 1:length(tracks)
    track = tracks(i);
    positions = track.positions; % 获取轨迹的位置点
    frames = track.frames;

    % 绘制轨迹
    scatter(positions(:,1), positions(:,2), 3, colors(frames,:), 'filled'); % 使用第i个颜色和较宽的线条宽度绘制轨迹
    hold on
end

% Set the figure size to be square
figureWidth = 6;  % Specify the desired width of the figure in inches
figureHeight = 6; % Specify the desired height of the figure in inches
set(gcf, 'Units', 'inches', 'Position', [0, 0, figureWidth, figureHeight]);

% 设置图的其他属性
xlabel('X Position');
ylabel('Y Position');
title('Tracks Visualization');
xlim([0 1024])
ylim([0 1024])
grid on
ax = gca;
ax.YDir = 'reverse';

hold off; % 现在新添加的内容会擦除旧的内容

[pathstr, name, ~] = fileparts(videoFileRaw);
figurePath = fullfile(dataPath, 'tracks', name);
saveas(g, figurePath, 'jpg');
save(figurePath, 'tracks');

close all

allPoints = [];
for ii = 1:length(tracks)
    track = tracks(ii);
    positions = track.positions;
    allPoints = [allPoints; positions(:,1)];
end
% 统计x坐标
[counts, edges] = histcounts(allPoints);

% 绘制统计线
g2  = figure;
plot(edges(1:end-1), counts, '-o');
xlim([0 1024])
title('x coordinate');
xlabel('x axis');
figurePath2 = fullfile(dataPath, 'outputImage', name);
saveas(g2, figurePath2, 'jpg');
close all