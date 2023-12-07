clc; clear; close all;

%% all video path in raw data folder
% data path (the path to contain both raw data folder and processed data folder)
dataPath = 'data';

% raw data path (the path to contain all video without any processed)
rawVideoPath = 'OneDrive_2_11-30-2023';

% get the full raw data path
folderPath = fullfile(dataPath, rawVideoPath);

% get all items in a folder
items = dir(folderPath);

% filter out files (excluding folders)
files = items(~[items.isdir]);

% get all full video files
rawVideoFiles = cell(length(files), 1);

for k = 1:length(files)
    filename = files(k).name;
    rawVideoFile = fullfile(folderPath, filename);
    rawVideoFiles{k} = rawVideoFile; % save full file path
end

%% mask video
% get max instensity stack for video to draw mask
for fileIdx = 1:length(rawVideoFiles)
    rawVideoFile = string(rawVideoFiles(fileIdx));
    getMaxIntensityStack(rawVideoFile);
    fprintf('\n');
end

% run this for draw mask for every video
for fileIdx = 1:length(rawVideoFiles)
    rawVideoFile = string(rawVideoFiles(fileIdx));
    drawMask(rawVideoFile);
end

% this function will mask every file
for fileIdx = 1:length(rawVideoFiles)
    rawVideoFile = string(rawVideoFiles(fileIdx));
    maskVideo(rawVideoFile);
    fprintf('\n');
end

%% average frames (get the background of the video)
startFrame = 1;
for fileIdx = 1:length(rawVideoFiles)
    rawVideoFile = string(rawVideoFiles(fileIdx));
    getBackground(rawVideoFile, startFrame);
    fprintf('\n');
end

%% remove the background of the video
frameRateScaler = 1; % change this when you want to speed up or slow down the video
for fileIdx = 1:length(rawVideoFiles)
    rawVideoFile = string(rawVideoFiles(fileIdx));
    removeBackground(rawVideoFile, frameRateScaler);
    fprintf('\n');
end

%% get centroids
% run this to find threshold for all videos
for fileIdx = 1:length(rawVideoFiles)
    rawVideoFile = string(rawVideoFiles(fileIdx));
    findccThreshold(rawVideoFile);
end

for fileIdx = 1:length(rawVideoFiles)
    rawVideoFile = string(rawVideoFiles(fileIdx));
    getCentroids(rawVideoFile);
    fprintf('\n');
end

%% Calculate tracks
for fileIdx = 1:length(rawVideoFiles)
    rawVideoFile = string(rawVideoFiles(fileIdx));
    getTracks(rawVideoFile);
    fprintf('\n');
end

%% Get head lifting
for fileIdx = 1:length(rawVideoFiles)
    rawVideoFile = string(rawVideoFiles(fileIdx));
    getHeadLifting(rawVideoFile);
    fprintf('\n');
end

%% figure
% this is used to show tracks
for fileIdx = 1:length(rawVideoFiles)
    rawVideoFile = string(rawVideoFiles(fileIdx));
    plotTracks(rawVideoFile)
    fprintf('\n');
end

% this is used to show head liftings
for fileIdx = 1:length(rawVideoFiles)
    rawVideoFile = string(rawVideoFiles(fileIdx));
    plotHeadLifting(rawVideoFile)
    fprintf('\n');
end