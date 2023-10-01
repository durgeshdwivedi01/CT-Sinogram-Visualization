% Create a blank grayscale image
phantom_image = zeros(256, 256);

% Add one large gray-shaded circle
center = [128, 128]; % Center of the image
radii_large = 50; % Radius for the large circle (darkest gray)
[X, Y] = meshgrid(1:256);
mask_large = sqrt((X - center(1)).^2 + (Y - center(2)).^2) <= radii_large;
phantom_image(mask_large) = 0.3;

% First Small Circle (medium gray, to the top-right of the center)
center_small1 = [center(1) + 20, center(2) - 20];
radii_small1 = 15;
mask_small1 = sqrt((X - center_small1(1)).^2 + (Y - center_small1(2)).^2) <= radii_small1;
phantom_image(mask_small1) = 0.6;

% Second Small Circle (lightest gray, to the bottom-left of the center)
center_small2 = [center(1) - 20, center(2) + 20];
radii_small2 = 15;
mask_small2 = sqrt((X - center_small2(1)).^2 + (Y - center_small2(2)).^2) <= radii_small2;
phantom_image(mask_small2) = 0.9;

% Introduce a diamond-shaped artifact within the circle
diamond_center = [center(1), center(2)];
diamond_size = 10;
mask_diamond = abs(X - diamond_center(1)) + abs(Y - diamond_center(2)) <= diamond_size;
phantom_image(mask_diamond) = 1; % Maximum intensity

% Parameters for sinogram
theta = 0:179;

% Get the size of the first projection
[R_first, xp] = radon(phantom_image, theta(1));
sinogram = zeros(length(R_first), length(theta));

% Create a figure for side-by-side display
% ... [Previous code for creating the phantom and sinogram remains unchanged]

% Create a figure for side-by-side display
figure;

for i = 1:length(theta)
    [R, ~] = radon(phantom_image, theta(i));
    sinogram(:, i) = R;

    % Display the phantom with X-ray tube, detector, pencil beam, and legends
    subplot(1, 2, 1);
    imshow(phantom_image, 'Border', 'tight');
    axis off;
    hold on;

    % X-ray tube and Detector positions closer to the center
    xray_pos = [center(1) + 70*cosd(theta(i)), center(2) + 70*sind(theta(i))];
    detector_pos = [center(1) - 70*cosd(theta(i)), center(2) - 70*sind(theta(i))];

    % X-ray tube (triangle)
    h1 = plot(xray_pos(1), xray_pos(2), '^r', 'MarkerSize', 10, 'LineWidth', 2, 'DisplayName', 'X-ray Tube');
    % Dummy line for the detector legend
    h2 = plot(NaN, NaN, 's', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b', 'DisplayName', 'Detector');
    % Detector (rectangle)
    rectangle('Position', [detector_pos(1)-4, detector_pos(2)-4, 8, 8], 'EdgeColor', 'b', 'LineWidth', 2);
    % Artifact (diamond with black outline)
    h3 = plot(diamond_center(1), diamond_center(2), 'wd', 'MarkerSize', 10, 'LineWidth', 2, 'MarkerEdgeColor', 'k', 'DisplayName', 'Artifact');

    % Pencil beam
    line([xray_pos(1), detector_pos(1)], [xray_pos(2), detector_pos(2)], 'Color', 'c', 'LineWidth', 1.5);

    % Add legends outside the main figure
    lgd = legend([h1, h2, h3], 'Location', 'southoutside', 'Orientation', 'horizontal');
    title('Phantom with Circles and Artifact');
    hold off;

    % ... [Rest of the code for displaying the sinogram and creating the GIF remains unchanged]


    % Display the current sinogram
    subplot(1, 2, 2);
    imshow(sinogram, [], 'XData', theta, 'YData', xp, 'InitialMagnification', 'fit');
    xlabel('Theta (degrees)');
    ylabel('Detector Position');
    title(['Sinogram up to ' num2str(theta(i)) ' degrees']);
    drawnow;

    % Save as GIF
    frame = getframe(gcf);
    im = frame2im(frame);
    [A, map] = rgb2ind(im, 256);
    if i == 1
        imwrite(A, map, 'sinogram_with_diamond_artifact.gif', 'gif', 'LoopCount', Inf, 'DelayTime', 0.1);
    else
        imwrite(A, map, 'sinogram_with_diamond_artifact.gif', 'gif', 'WriteMode', 'append', 'DelayTime', 0.1);
    end
end
