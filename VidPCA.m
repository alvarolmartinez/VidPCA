%% VidPCA: PCA for Video Compression
%
% This script demonstrates the application of Principal Component Analysis (PCA)
% using Singular Value Decomposition (SVD) for video compression in Octave.

%% Function to Create GIF from Images
function createGIF(image_directory, image_prefix, output_name, num_frames)
    % Create a GIF from a series of images
    % Arguments:
    %   image_directory - Directory containing the images
    %   image_prefix - Prefix for the image files
    %   output_name - Name of the output GIF file
    %   num_frames - Number of frames in the animation

    for i = 1:num_frames
        image_path = [image_directory, "/", image_prefix, num2str(i), ".jpg"];
        img = imread(image_path);
        
        if i == 1
            imwrite(img, output_name, 'gif', 'LoopCount', Inf, 'DelayTime', 0.1);
        else
            imwrite(img, output_name, 'gif', 'WriteMode', 'append', 'DelayTime', 0.1);
        end
    end
end

%% Function to Save Images from Tensor
function saveImagesFromTensor(images_tensor, output_directory, file_prefix)
    % Save images extracted from a tensor to files
    % Arguments:
    %   images_tensor - 3D tensor of images
    %   output_directory - Directory to save the images
    %   file_prefix - Prefix for the saved image files

    if ~exist(output_directory, 'dir')
        mkdir(output_directory);
    end

    num_frames = size(images_tensor, 3);

    for i = 1:num_frames
        image = images_tensor(:, :, i);
        filename = fullfile(output_directory, [file_prefix, num2str(i), '.jpg']);
        imwrite(image, filename);
    end
end

%% Main Video Processing
image_directory = "Frames/";
image_prefix = "ezgif-frame-";
num_frames = 14;

% Load Images and Initialize Arrays
first_image = imread([image_directory, "/", image_prefix, "1.jpg"]);
image_size = size(first_image);
grayscale_images = zeros(image_size(1), image_size(2), num_frames);

for i = 1:num_frames
    image = imread([image_directory, "/", image_prefix, num2str(i), ".jpg"]);
    if size(image, 3) == 3
        grayscale_images(:, :, i) = rgb2gray(image);
    else
        grayscale_images(:, :, i) = image;
    end
end

% Flatten the tensor into a matrix
flattened_images = zeros(image_size(1) * image_size(2), num_frames);
for i = 1:num_frames
    flattened_images(:, i) = grayscale_images(:, :, i)(:);
end

% Perform Singular Value Decomposition (SVD)
[U, S, V] = svd(flattened_images);

% Compress the video by retaining a subset of the principal components
num_components = 5;
compressed_flattened_images = U(:, 1:num_components) * S(1:num_components, 1:num_components) * V(:, 1:num_components)';

% Reconstruct the compressed video tensor
compressed_images = zeros(image_size(1), image_size(2), num_frames);
for i = 1:num_frames
    current_matrix = reshape(compressed_flattened_images(:,i), image_size);
    min_val = min(current_matrix(:));
    max_val = max(current_matrix(:));
    compressed_images(:, :, i) = (current_matrix - min_val) / (max_val - min_val);
end

% Saving Compressed Images and Creating GIF
saveImagesFromTensor(compressed_images, 'CompressedFrames', 'frame_');
createGIF('CompressedFrames', 'frame_', 'compressedmovie.gif', num_frames);