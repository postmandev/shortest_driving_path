function generate_training_paths()

    close all;
    fullpath = 'training_paths/car_paths.mat';
    %fullpath = 'training_paths/walking_paths.mat';
    addpath('images/');
    addpath('training_paths/');
    addpath('matlab/');
    
    im = imread('aerial_color.jpg');

    f = figure('Visible','off','Position',[1,1,1400,800]);
    ax = axes('Units','pixels');
    h = imshow(im);

    if exist(fullpath, 'file') == 2
        load(fullpath);
        path_idx = length(paths);
        tmp_path = [];
        j = 1;
        for t = 1:path_idx
            if length(paths{t}) > 0
                tmp_path{j} = paths{t};
                j = j+1;
            end
        end
        paths = tmp_path;
        path_idx = length(tmp_path) + 1;
    else 
        path_idx = 1;
        paths = [];
    end
    
    f.Visible = 'on';
    
    num = 50;
    plot_h = cell(num,1);
    rand_colors = rand(num,3);
    for g = 1:num
        hold on;
        if g < path_idx
            plot_h{g} = plot(paths{g}(:,1), paths{g}(:,2), 'o-', 'Color', rand_colors(g,:));
            
        else
            plot_h{g} = plot(0, 0, 'o-', 'Color', rand_colors(g,:));
        end
    end
    
    
    btn1 = uicontrol('Style', 'pushbutton', 'String', 'Add Training Path', ...
        'Position', [100 100 100 20], 'Callback', @add_path);
    
    btn2 = uicontrol('Style', 'pushbutton', 'String', 'Save Paths', ...
        'Position', [210 100 100 20], 'Callback', @save_paths);
    
    %f.Visible = 'on';
    
    function save_paths(source, callbackdata)
        save(fullpath, 'paths');
        close(gcf);
    end

    function add_path(source, callbackdata)
        %path = [];
        [x,y] = getline(f);
        path = [round(x),round(y)];
        hold on;
        set(plot_h{path_idx}, 'xdata', x, 'ydata', y);
        hold off;
        
        px_x = [];
        px_y = [];
        
        for i = 1:length(path)-1,
            [px_xx, px_yy] = getMapCellsFromRay(path(i,1),path(i,2), path(i+1,1), path(i+1,2));
            
            px_x = [px_x; px_xx];
            px_y = [px_y; px_yy];
        end
        
        paths{path_idx} = [px_x px_y];
        path_idx = path_idx + 1;
    end
    
end

