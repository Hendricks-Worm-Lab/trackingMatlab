function tracks = getTracks(S)

% 假设 S 已经是您的输入结构体
numFrames = length(S);  % 获取帧数

% 初始化一个数组来保存轨迹
tracks = struct('positions', {}, 'frames', {}, 'disappeared', {});

% 设定阈值
thresholdDistance = 10;  % 例如，50个单位
minTrackLength = 30;  % 保留长度至少为5帧的轨迹
maxDisappearFrames = 10;  % 允许轨迹消失的最大帧数

% 遍历每一帧  
for k = 1:min(numFrames-1,2400)
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
end

%% move short tracks
removeIdx = false(1, length(tracks)); % 初始化逻辑索引数组
for j = 1:length(tracks)
    track = tracks(j);
    if size(track.positions, 1) < minTrackLength
        removeIdx(j) = true; % 标记需要移除的轨迹
    end
end
tracks(removeIdx) = []; % 在循环外移除标记的轨迹2

end