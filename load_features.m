%%

fprintf('\nLoading feature layers\n');

features = [];
f_bw = [];
dirstruct = dir('feature_layers/*.m');
for i = 1:1:length(dirstruct),
    % Read one feature layer at a time
    f = dirstruct(i).name;
    C = strsplit(f, '.');
    fun = str2func(C{1});
    [BW,maskedRGBImage] = feval(fun, im);
    %feature = double(reshape(BW, num_px, 1)')/256;
    feature = double(reshape(rgb2gray(maskedRGBImage), num_px, 1)')/256;
    features = [features; feature];
    f_bw = [f_bw; BW];
    figure(i); imshow(rgb2gray(maskedRGBImage)); title(C{1}); axis image; drawnow;
    %figure; imshow(BW);
end

% features = [features; (features(1,:)+features(2,:))];
% features = [features; (features(5,:)-features(3,:)+features(2,:)+features(1,:))];

%%
G = fspecial('gaussian', 20,20);
im_blur = imfilter(im, G);

G = fspecial('gaussian', 10,10);
im_blur = imfilter(im_blur, G);

cform = makecform('srgb2lab');
C = applycform(im_blur,cform);

ab = reshape(double(C(:,:,2:3)), num_px, 2);

k = 24;
[cidx, c_mu] = kmeans(ab, k, 'distance', 'sqEuclidean','Replicates',3);
pixel_labels = reshape(cidx, d(1), d(2));

rgb_label = repmat(pixel_labels, [1 1 3]);

for c = 1:k
    color = im;
    color(rgb_label ~= c) = 0;
    GRAY = rgb2gray(color);
    feature = double(reshape(GRAY, num_px, 1)')/256;
    features = [features; feature];
    f_bw = [f_bw; dither(GRAY)];
    h = figure; imshow(color);
    str = sprintf('image%0.0f.png',c);
    saveas(h, str);
end



%%
% feature = double(reshape(im(:,:,1), num_px, 1)')/256;
% features = [features; feature];
% feature = double(reshape(im(:,:,2), num_px, 1)')/256;
% features = [features; feature];
% feature = double(reshape(im(:,:,3), num_px, 1)')/256;
% features = [features; feature];
% 
% I = rgb2ycbcr(im);
% feature = double(reshape(I(:,:,1), num_px, 1)')/256;
% features = [features; feature];
% feature = double(reshape(I(:,:,2), num_px, 1)')/256;
% features = [features; feature];
% feature = double(reshape(I(:,:,3), num_px, 1)')/256;
% features = [features; feature];

% I = rgb2hsv(im);
% feature = double(reshape(I(:,:,1), num_px, 1)')/256;
% features = [features; feature];
% feature = double(reshape(I(:,:,2), num_px, 1)')/256;
% features = [features; feature];
% feature = double(reshape(I(:,:,3), num_px, 1)')/256;
% features = [features; feature];
% 
% feature = double(reshape(rgb2gray(im), num_px, 1)')/256;
% features = [features; feature];

% feature = double(ones(num_px,1)*0.5)';
% features = [features; feature];
% feature = double(reshape(edge(rgb2gray(im), 'sobel'), num_px, 1)')/256;
% features = [features; feature];


fprintf('--------------------------------------\n\n');
