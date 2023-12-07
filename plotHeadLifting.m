function plotHeadLifting(videoPath)
    % get the path and name of the input video
    [pathstr, name, ~] = fileparts(videoPath);
    [upperPath, ~, ~] = fileparts(pathstr);    

    % Read the tracks
    tracksFolder = 'headLifting';
    tracksName = strcat(name,'.mat');
    tracksPath = fullfile(upperPath, tracksFolder, tracksName);
    load(tracksPath, 'maxDifference')

    % Create the full path for the output figure
    outputName = name;
    outputFolder = 'plotHeadLifting';
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
    
    frameRate = 10;
    headLifting = find(maxDifference>=10)/frameRate;
    % 或者，创建一个使用垂直线表示放电时间的图
    g = figure('Position', [100, 100, 1000, 100]); % 位置：100,100，宽度：1000，高度：200
    for i = 1:length(headLifting)
        line([headLifting(i) headLifting(i)], [0 1], 'Color', 'black'); % 画一条从 y=0 到 y=1 的垂直线
    end
    xlim([0 length(maxDifference)/frameRate+0.1]); % 设置 x 轴的范围
    ylim([0 1]); % 设置 y 轴的范围
    xlabel('Time (s)');
    ylabel('Head Lifting Event');
    title('Head Lifting Times');

    saveas(g, figurePath, 'jpg');
    
    close all
    fprintf('Finished plot head lifting for %s\n', name);
end