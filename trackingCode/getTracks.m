function tracks = getTracks(videoPath)
% get the path and name of the input video
[pathstr, name, ~] = fileparts(videoPath);
[upperPath, ~, ~] = fileparts(pathstr);    
       
% Read the centroids
centroidsFolder = 'centroids';
centroidsName = strcat(name,'.mat');
centroidsPath = fullfile(upperPath, centroidsFolder, centroidsName);
load(centroidsPath, 'centroidsStruct');
S = centroidsStruct;

% create a VideoWriter object to hold the processed video.
% Create the full path for the output video
outputName = strcat(name,'.mat');
outputFolder = 'tracks';
outputPath = fullfile(upperPath, outputFolder, outputName);

% Check if path exists
if ~exist(fullfile(upperPath, outputFolder), 'dir')
    % Path does not exist, create it
    mkdir(fullfile(upperPath, outputFolder));
    fprintf('Created path: %s\n', fullfile(upperPath, outputFolder));
else
    % Path already exists
    fprintf('Path already exists: %s\n', fullfile(upperPath, outputFolder));
end

% get frame number
numFrames = length(S);  

% 初始化一个数组来保存轨迹
tracks = struct('positions', {}, 'frames', {}, 'disappeared', {});

% 设定阈值
thresholdDistance = 10;  % 例如，10个单位
minTrackLength = 30;  % 保留长度至少为30帧的轨迹
maxDisappearFrames = 10;  % 允许轨迹消失的最大帧数

% 遍历每一帧  
for k = 1:numFrames-1
    currentTargets = [S(k).CentroidX S(k).CentroidY];
    nextTargets = [S(k+1).CentroidX S(k+1).CentroidY];
    
    % 为当前帧的每个目标找到下一帧中的最近目标
    for i = 1:size(currentTargets, 1)
        currentPoint = currentTargets(i, :);
        distances = sqrt(sum((nextTargets - currentPoint).^2, 2));  % 计算到下一帧每个点的欧氏距离
        [minDistance, indexOfMin] = min(distances);  % 找到最近的点

        % 这里，您可以设定一个距离阈值来判断目标是否“消失”
        if minDistance < thresholdDistance
            % 如果当前目标在轨迹中，则添加新位置
            existingTrackIndex = find(arrayfun(@(x) ismember(currentPoint, x.positions, 'rows'), tracks), 1);
            if ~isempty(existingTrackIndex)
                % 添加新位置到现有轨迹
                tracks(existingTrackIndex).positions(end+1, :) = nextTargets(indexOfMin, :);
                tracks(existingTrackIndex).frames(end+1) = k + 1;
                tracks(existingTrackIndex).disappeared = 0; % 如果找到匹配项，则重置消失计数
            else
                newTrack = struct('positions', [currentPoint; nextTargets(indexOfMin, :)], 'frames', [k, k + 1], 'disappeared', 0);
                tracks(end+1) = newTrack;
            end
        end
    end
    
    % 更新所有轨迹的"消失"计数器
    for i = 1:length(tracks)
        if ~ismember(k, tracks(i).frames)
            tracks(i).disappeared = tracks(i).disappeared + 1;
        else
            tracks(i).disappeared = 0;  % 如果在当前帧中找到，则重置
        end
    end

    removeIdx = false(1, length(tracks)); % 初始化逻辑索引数组
    for j = 1:length(tracks)
        track = tracks(j);
        if size(track.positions, 1) < 5 && track.disappeared > 20
            removeIdx(j) = true; % 标记需要移除的轨迹
        end
    end
    tracks(removeIdx) = []; % 在循环外移除标记的轨迹

    % use the backspace character to move the cursor back, then update the progress
    if k>1
        fprintf(repmat('\b', 1, 28)); % use the backspace character four times to move the cursor back as needed
    end
    fprintf('Getting tracks ... %4d/%4d', k, numFrames);
end
fprintf('\n');

%% move short tracks
removeIdx = false(1, length(tracks)); % 初始化逻辑索引数组
for j = 1:length(tracks)
    track = tracks(j);
    if size(track.positions, 1) < minTrackLength
        removeIdx(j) = true; % 标记需要移除的轨迹
    end
end
tracks(removeIdx) = []; % 在循环外移除标记的轨迹

save(outputPath, "tracks");

fprintf('Finished tracking for %s\n', name);
end