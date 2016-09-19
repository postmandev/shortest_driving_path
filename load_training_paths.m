%%

fprintf('Loading expert paths\n');

training_path = [];
p_idx = 1;

%dirstruct = dir('training_paths/*.mat');
%for i = 1:length(dirstruct),
    % Read one training path at a time
    %f = dirstruct(i).name;
    f_str = strcat(['training_paths/',paths_filename]);
    %fprintf('%s\n', f_str);
    load(f_str);
    for j = 1:length(paths)
        %training_path{p_idx} = paths{j};
        training_path{p_idx} = unique(round([scale 0; 0 scale]*paths{j}(:,:)')', 'rows', 'stable');
        p_idx = p_idx+1;
    end
%     if strcmp(f, 'paths.mat') == 0
%         delete(f_str);
%     end

paths = training_path;

%save('training_paths/paths.mat', 'paths');

clear training_path;

fprintf('--------------------------------------\n\n');


