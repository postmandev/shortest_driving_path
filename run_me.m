
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;
clear all;
close all;

% addpath('feature_layers');
addpath('matlab');
% addpath('images');
% addpath('training_paths');
% addpath('models');

if ~exist('costs', 'var')
    load('models/car_model.mat');
%load('walking_model.mat');
end

I = imread('images/aerial_color.jpg');
scale = 0.25;
I = imresize(I, scale);

f = figure('Visible','off','Position',[1,1,1400,800]);
imshow(I);  colormap(1-gray);
hold on;

btn2 = uicontrol('Style', 'pushbutton', 'String', 'Reset', ...
        'Position', [10 10 100 20], 'Callback', @doReset);
    
%f.Visible = 'on';

dim = size(I);


num_pts = 2;
points = zeros(num_pts,2);

for i=1:num_pts
    [x,y] = ginput(1);
    plot(x, y, 'ro', 'LineWidth', 10);
    hold on;
    points(i,:) = [x,y];
    drawnow;
end

t_goal(:,1) = points(:,2);
t_goal(:,2) = points(:,1);

goal = [t_goal(end,1) t_goal(end,2)];
tic;
ctg = dijkstra_matrix(costs,ceil(goal(1)),ceil(goal(2)));
%ctg2 = dijkstra_matrix(costs2,ceil(goal(1)),ceil(goal(2)));
toc

[ip1, jp1] = dijkstra_path(ctg, costs, ceil(t_goal(1,1)), ceil(t_goal(1,2)));
%[ip2, jp2] = dijkstra_path(ctg2, costs2, ceil(t_goal(1,1)), ceil(t_goal(1,2)));

hold on;
plot(jp1, ip1, 'b-', 'LineWidth', 4);
%plot(jp2, ip2, 'r-', 'LineWidth', 4);
drawnow;
