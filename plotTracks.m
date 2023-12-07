function plotTracks(videoPath)
    % get the path and name of the input video
    [pathstr, name, ~] = fileparts(videoPath);
    [upperPath, ~, ~] = fileparts(pathstr);  

    % Read the tracks
    tracksFolder = 'tracks';
    tracksName = strcat(name,'.mat');
    tracksPath = fullfile(upperPath, tracksFolder, tracksName);
    load(tracksPath, 'tracks')

    % Create the full path for the output figure
    outputName = name;
    outputFolder = 'plotTracks';
    figurePath = fullfile(upperPath, outputFolder, outputName);
    
    % Check if path exists
    if ~exist(fullfile(upperPath, outputFolder), 'dir')
        % Path does not exist, create it
        mkdir(fullfile(upperPath, outputFolder));
        fprintf('Created path: %s\n', fullfile(upperPath, outputFolder));
    else
        % Path already exists
        fprintf('Path already exists: %s\n', fullfile(upperPath, outputFolder));
    end

    g = figure; % creat a new figure window
    hold on; % Maintain the current figure, so that newly added lines or points will not erase the old content
    
    maxFrame = 0;
    for i = 1:length(tracksPath)
        maxFrame = max(maxFrame, max(tracks(i).frames));
    end
    
    % 可选：为不同的轨迹设置颜色
    colors = spring(maxFrame); % 使用HSV颜色图为每条轨迹生成不同的颜色
    
    % 遍历每条轨迹
    for i = 1:length(tracks)
        track = tracks(i);
        positions = track.positions; % 获取轨迹的位置点
        frames = track.frames;
    
        % 绘制轨迹
        scatter(positions(:,1), positions(:,2), 3, colors(frames,:), 'filled'); % 使用第i个颜色和较宽的线条宽度绘制轨迹
        hold on
    end
    
    % 设置图的其他属性
    xlabel('X Position');
    ylabel('Y Position');
    title('Tracks Visualization');
    ax = gca;
    ax.YDir = 'reverse';
    
    hold off; % 现在新添加的内容会擦除旧的内容
    
    saveas(g, figurePath, 'jpg');
    
    close all
    fprintf('Finished plot tracks for %s\n', name);
end