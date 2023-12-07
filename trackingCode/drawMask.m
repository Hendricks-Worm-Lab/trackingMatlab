function drawMask(videoPath)
    [pathstr, name, ~] = fileparts(videoPath);
    [upperPath, ~, ~] = fileparts(pathstr);    

    % Read the max intensity stack
    inputFolder = 'maxIntensityStack';
    inputName = strcat(name,'.png');
    inputVideoPath = fullfile(upperPath, inputFolder, inputName);    
    maxIntensityStack = imread(inputVideoPath);

    % Create a new figure to display the maximum intensity stack
    figure;
    imshow(maxIntensityStack);
    title('Draw a mask and save it');

    % Initialize an empty mask image
    mask = false(size(maxIntensityStack, 1), size(maxIntensityStack, 2));

    % Use interactive tools to draw multiple shape masks
    while true
        % Let the user choose the shape type to draw
        choice = menu('Select shape type', 'Rectangle', 'Ellipse', 'Polygon', 'Freehand', 'Finish drawing');

        if choice == 1 % Draw a rectangle
            h = imrect;
            wait(h);
            mask = mask | createMask(h);
        elseif choice == 2 % Draw an ellipse
            h = imellipse;
            wait(h);
            mask = mask | createMask(h);
        elseif choice == 3 % Draw a polygon
            h = impoly;
            wait(h);
            mask = mask | createMask(h);
        elseif choice == 4 % Freehand drawing
            h = imfreehand;
            wait(h);
            mask = mask | createMask(h);
        elseif choice == 5 % Finish drawing
            break;
        end
    end

    % Close figure
    close;

    % save the mask
    % Create the full path for the output image
    outputFolder = 'mask';
    outputName = strcat(name,'.png');
    outputVideoPath = fullfile(upperPath, outputFolder, outputName);

    % Check if path exists
    if ~exist(fullfile(upperPath, outputFolder), 'dir')
        % Path does not exist, create it
        mkdir(fullfile(upperPath, outputFolder));
        disp(['Created path: ', fullfile(upperPath, outputFolder)]);
        fprintf('\n');
    else
        % Path already exists
        disp(['Path already exists: ', fullfile(upperPath, outputFolder)]);
        fprintf('\n');
    end
     
    % save the max intensity stack
    imwrite(mask, outputVideoPath);    

end