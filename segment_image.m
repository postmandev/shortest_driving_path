%%

close all;

im = imread('aerial_color_small.jpg');
d = size(im);
n_pixels = d(1)*d(2);

%%

cform = makecform('srgb2lab');
C = applycform(im,cform);

ab = reshape(double(C(:,:,2:3)), n_pixels, 2);

k = 7;
[cidx, c_mu] = kmeans(ab, k, 'distance', 'sqEuclidean','Replicates',3);
pixel_labels = reshape(cidx, sz(1), sz(2));

rgb_label = repmat(pixel_labels, [1 1 3]);
feature_layer = cell(1,3);

for c = 1:k
    color = im;
    color(rgb_label ~= c) = 0;
    feature_layer{c} = color;
    figure; imshow(feature_layer{c});
end

BW = rgb2gray(im);

c = c+1;
feature_layer{c} = edge(BW, 'sobel');
figure; imshow(feature_layer{c});
c = c+1;
feature_layer{c} = edge(BW, 'canny');
figure; imshow(feature_layer{c});

c = c+1;
[bw,feature_layer{c}] = roads_rails_paths(im);
figure; imshow(feature_layer{c});

%%

map_ycbcr = rgb2ycbcr(im);
map_hsv = rgb2hsv(im);
%grad = gradient(double(rgb2gray(im)));

G = fspecial('gaussian', 3,3);
map_hsv_blur = imfilter(map_hsv, G);
figure; imshow(edge(map_ycbcr(:,:,1), 'prewitt'));
figure; imshow(map_ycbcr(:,:,1));
figure; imshow(map_ycbcr(:,:,2));

%%

G = fspecial('gaussian', 15,15);
im_blur = imfilter(im, G);

cform = makecform('srgb2lab');
C = applycform(im_blur,cform);

ab = reshape(double(C(:,:,2:3)), num_px, 2);

k = 5;
[cidx, c_mu] = kmeans(ab, k, 'distance', 'sqEuclidean','Replicates',3);
pixel_labels = reshape(cidx, d(1), d(2));

rgb_label = repmat(pixel_labels, [1 1 3]);
feature_layer = cell(1,3);

for c = 1:k
    color = im_blur;
    color(rgb_label ~= c) = 0;
    feature_layer{c} = color;
    figure; imshow(feature_layer{c});
end
