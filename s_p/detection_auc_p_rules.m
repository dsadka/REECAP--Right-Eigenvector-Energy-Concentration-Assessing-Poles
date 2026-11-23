%% General Settings
% Compares rules for the depth p of the s_p score:
% p = #clusters (oracle), elbow, elbow (accel.), Gap, SDD and FFT
sweeps = {'SNR', 'N', 'nClusters', 'polesPerCluster', 'minSepR', 'damping'};

root = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root, 'toolbox'));
out_dir = fullfile(root, 'figures');
if ~exist(out_dir, 'dir'); mkdir(out_dir); end
set_sp_figure_settings(11);

%% Generate Data
AUC = cell(1, numel(sweeps));
X = cell(1, numel(sweeps));
for i = 1:numel(sweeps)
    [AUC{i}, params] = gen_data_auc_p_rules(sweeps{i});
    X{i} = params.x;
end
names = cellfun(@get_pMode_name, params.pModes, 'UniformOutput', false);

%% Produce graphs
% One panel per sweep, all with the same y-axis range
y_min = min(cellfun(@(a) min(a(:)), AUC));
y_lim = [max(0, floor((y_min - 0.03)/0.1)*0.1), 1.02];
for i = 1:numel(sweeps)
    [xlab, is_integer] = get_sweep_label(sweeps{i});
    if strcmp(sweeps{i}, 'damping')
        xlab = 'maximum allowed damping';
    end
    plot_auc_panel(X{i}, AUC{i}, names, xlab, is_integer, y_lim, ...
                   fullfile(out_dir, ['auc_p_rules_' sweeps{i}]));
end
plot_legend(names, 3, 13, false, fullfile(out_dir, 'auc_p_rules_legend'));
