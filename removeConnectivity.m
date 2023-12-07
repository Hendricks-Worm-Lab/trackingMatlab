function resultImg = removeConnectivity(img, minArea, maxArea)
    % 将图像二值化（假设需要处理的图像是二值图像）
    bwImg = imbinarize(img);

    % 标记连通域
    labeledImg = bwlabel(bwImg);

    % 使用regionprops获取连通域属性
    stats = regionprops(labeledImg, 'Area');

    % 创建一个与原始图像大小相同的二值掩码
    mask = zeros(size(labeledImg));

    % 遍历每个连通域
    for i = 1:numel(stats)
        % 如果连通域的面积大于或等于指定的最小面积（minArea），将其标记为1
        if stats(i).Area >= minArea && stats(i).Area <= maxArea
            mask(labeledImg == i) = 1;
        end
    end

    % % 将二值掩码应用于原始图像
    % resultImg = img;
    % resultImg(mask == 0) = 0;
    resultImg = mask;
end