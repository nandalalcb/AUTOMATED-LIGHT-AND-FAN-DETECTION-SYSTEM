function image_detection_GUI
    % Create GUI Figure (Unchanged UI)
    fig = figure('Name', 'Image Detection GUI', 'NumberTitle', 'off', 'Position', [100, 100, 800, 600], ...
                 'MenuBar', 'none', 'Resize', 'off', 'Color', [0.8 0.9 1]);

    % UI Components
    btnUpload = uicontrol('Style', 'pushbutton', 'String', 'Upload Image', ...
                          'Position', [50, 500, 150, 40], 'FontSize', 12, 'Callback', @uploadImage);
    btnDetect = uicontrol('Style', 'pushbutton', 'String', 'Detect Objects', ...
                          'Position', [250, 500, 150, 40], 'FontSize', 12, 'Callback', @detectObjects, 'Enable', 'off');
    lblStatus = uicontrol('Style', 'text', 'String', 'Status: Waiting for Image...', ...
                          'Position', [50, 450, 700, 30], 'FontSize', 12, 'HorizontalAlignment', 'left', ...
                          'BackgroundColor', [0.8 0.9 1]);
    axesImg = axes('Parent', fig, 'Position', [0.1, 0.1, 0.8, 0.6]);

    % Global Variables
    img = [];
    net = yolov4ObjectDetector('csp-darknet53-coco');  % Load YOLOv4 for people detection

    % Upload Image Function
    function uploadImage(~, ~)
        [file, path] = uigetfile({'*.jpg;*.png;*.jpeg', 'Image Files (*.jpg,*.png,*.jpeg)'});
        if isequal(file, 0)
            return;
        end
        imgPath = fullfile(path, file);
        img = imread(imgPath);
        imshow(img, 'Parent', axesImg);
        lblStatus.String = "Status: Image Loaded!";
        btnDetect.Enable = 'on';
    end

    % Object Detection Function
    function detectObjects(~, ~)
        if isempty(img)
            lblStatus.String = "Status: No Image Loaded!";
            return;
        end
        lblStatus.String = "Status: Detecting Objects...";
        drawnow;

        % Convert Image to Grayscale
        grayImg = rgb2gray(img);

        % ------------ FAN DETECTION ------------
        [centers, radii, metrics] = imfindcircles(grayImg, [30 150], 'Sensitivity', 0.9);
        fanDetected = false;
        if ~isempty(centers)
            edgeImg = edge(grayImg, 'Canny');
            for i = 1:size(centers, 1)
                x = round(centers(i, 1));
                y = round(centers(i, 2));
                r = round(radii(i));
                region = edgeImg(max(1, y-r):min(end, y+r), max(1, x-r):min(end, x+r));
                edgeDensity = sum(region(:)) / numel(region);
                if edgeDensity > 0.05
                    fanDetected = true;
                    viscircles(centers(i, :), radii(i), 'Color', 'b', 'LineWidth', 2);
                end
            end
        end

        % ------------ LIGHT DETECTION ------------
        hsvImg = rgb2hsv(img);
        brightness = hsvImg(:, :, 3);
        ceilingRegion = brightness(1:round(size(brightness, 1) * 0.33), :);
        threshold = mean2(ceilingRegion) + 0.2 * std2(ceilingRegion);
        binLight = ceilingRegion > threshold;
        binLight = imopen(binLight, strel('disk', 2));
        binLight = imclose(binLight, strel('disk', 5));
        lightDetected = sum(binLight(:)) / numel(binLight) > 0.02;

        % ------------ PERSON DETECTION (YOLOv4) ------------
        peopleDetected = false;
        [bboxes, scores, labels] = detect(net, img, 'Threshold', 0.05);
        for i = 1:length(labels)
            if labels(i) == "person"
                peopleDetected = true;
            end
        end

        % Display Image with Results
        imshow(img, 'Parent', axesImg);
        hold on;
        for i = 1:size(bboxes, 1)
            rectangle('Position', bboxes(i, :), 'EdgeColor', 'r', 'LineWidth', 2);
            text(bboxes(i, 1), bboxes(i, 2) - 10, labels(i), 'Color', 'red', 'FontSize', 12, 'FontWeight', 'bold', 'BackgroundColor', 'white');
        end

        % Display Detection Results
        finalMessage = sprintf("People Detected: %s\nLights Detected: %s\nFans Detected: %s\n", ...
                               string(peopleDetected), string(lightDetected), string(fanDetected));

        if ~peopleDetected && (fanDetected || lightDetected)
            finalMessage = strcat(finalMessage, "⚠️ Alert: No one is in the room. Please turn off the lights and fan!");
        end

        text(10, 50, finalMessage, 'Color', 'red', 'FontSize', 14, 'FontWeight', 'bold', 'BackgroundColor', 'white');
        hold off;
        lblStatus.String = "Status: Detection Complete!";
    end
end
