%%

clean_slate = 1;

if clean_slate == 1
    clear all;
    clc;
    
    paths_filename = 'walking_paths.mat';
    %paths_filename = 'car_paths.mat';
    
    addpath('feature_layers');
    addpath('matlab');
    addpath('images');
    addpath('training_paths');
    addpath('models');

    im = imread('aerial_color.jpg');
    scale = 0.25;
    im = imresize(im, scale);
%     figure(1); imshow(im);
%     pause;
    d = size(im);
    num_px = d(1)*d(2);

    load_features;
    load_training_paths;

end
%%
close all;

num_features = size(features,1);
num_paths = length(paths);

wts = ones(num_features,1);
%wts = rand(num_features,1);

costs = 0.1 + exp(reshape(wts'*features, d(1),d(2)));

min_cost = min(costs(:));
max_cost = max(costs(:));

figure(1);
plot_h = imshow((costs-min_cost)/(max_cost-min_cost),[0,1]);


ex_path = cell(1, num_paths);
dijk_path = cell(1, num_paths);
wt_plot = cell(num_features,1);
wt_hist = wts;

hold on;
for i = 1:num_paths
    ex_path{i} = plot(paths{i}(2:end-1,1), paths{i}(2:end-1,2), 'm.', 'LineWidth', 2);
    dijk_path{i} = plot(0,0, 'b.', 'LineWidth', 2);
end

figure(2);
rand_colors = rand(num_features,3);
for i = 1:num_features
    wt_plot{i} = plot(0, wt_hist(i), '-d', 'Color', rand_colors(i,:));
    hold on;
end

grid on;
drawnow;

%eta = 0.0001;
eta = 1e-3;

t = 1;

prev_cost = Inf;

while t < 600
    
    costs = 1e-5 + exp(reshape(wts'*features, d(1),d(2)));
    min_cost = min(costs(:));
    max_cost = max(costs(:));

    set(plot_h, 'cdata', (costs-min_cost)/(max_cost-min_cost));
    
    ex_f_cost = zeros(num_features,1);
    dijk_f_cost = zeros(num_features,1);
    
    for i = 1:num_paths,
        
        u_path = unique(paths{i}, 'rows', 'stable');
        path_dim = [min(u_path)-1; max(u_path)+1];
        path = bsxfun(@minus, u_path, path_dim(1,:))+1;
        costs_patch = costs(path_dim(1,2):path_dim(2,2), path_dim(1,1):path_dim(2,1));
        
        start = path(1,:);
        goal = path(end,:);
        
        ctg = dijkstra_matrix(costs_patch, ceil(goal(2)),ceil(goal(1)));
        [dijk_rows, dijk_cols] = dijkstra_path(ctg, costs_patch, ceil(start(2)), ceil(start(1)));
        
        ex_ind = sub2ind(d(1:2), ceil(u_path(:,2)), ceil(u_path(:,1)));
        dijk_ind = sub2ind(d(1:2), ceil(dijk_rows+path_dim(1,2)), ceil(dijk_cols+path_dim(1,1)));
        
        ex_f_cost = ex_f_cost + sum(bsxfun(@times, features(:,ex_ind), costs(ex_ind)'), 2);
        dijk_f_cost = dijk_f_cost + sum(bsxfun(@times, features(:,dijk_ind), costs(dijk_ind)'), 2);
        
        set(dijk_path{i}, 'xdata', dijk_cols+path_dim(1,1), 'ydata', dijk_rows+path_dim(1,2));
        drawnow;
    end
    
    J = ex_f_cost - dijk_f_cost;
    cost = norm(J)
    abs(cost - prev_cost)
    
    if abs(cost - prev_cost) < 1e-3
        costs = 0.1 + exp(reshape(wts'*features, d(1),d(2)));
        break;
    else
        reg_lambda = 2e-10; % 1e-13
        wts = wts - eta * J + (reg_lambda/num_paths)*(cost^2);
        %eta = eta / t;
        prev_cost = cost;
        t = t+1;
        wt_hist = [wt_hist wts];
        if mod(t,1) == 0
            for i = 1:num_features,
                set(wt_plot{i}, 'xdata', (1:t)-1, 'ydata', wt_hist(i,:));
            end
        end
    end
    
    drawnow;
    
    
end

min_cost = min(costs(:));
max_cost = max(costs(:));

set(plot_h, 'cdata', (costs-min_cost)/(max_cost-min_cost));
    
%save('walking_model.mat', 'costs', 'wts');
%save('car_model.mat', 'costs', 'wts');


