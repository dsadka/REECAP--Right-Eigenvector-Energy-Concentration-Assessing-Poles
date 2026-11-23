%% General Settings
% Depth p of the s_p score (see toolbox/sp_depth.m):
% 'clusters' (true number of clusters) | 'elbow' | 'elbow_accel' | 'fft' | 'gap' | 'sdd' | ...
pMode = 'elbow';
sweeps = {'SNR', 'N', 'nClusters', 'polesPerCluster', 'minSepR', 'damping'};

root = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root, 'toolbox'));
out_dir = fullfile(root, 'figures');
if ~exist(out_dir, 'dir'); mkdir(out_dir); end
if strcmp(pMode, 'clusters'); tag = ''; else; tag = ['_' pMode]; end
set_sp_figure_settings(11);

%% Generate Data
% Detection AUC of s_p, SAMP, SAMP++, SDD, Gap, ESTER and RIVES along each sweep
AUC = cell(1, numel(sweeps));
X = cell(1, numel(sweeps));
for i = 1:numel(sweeps)
    [AUC{i}, params] = gen_data_auc_baselines(sweeps{i}, pMode);
    X{i} = params.x;
end
names = params.methods;

%% Produce graphs
% One panel per sweep, all with the same y-axis range
y_min = min(cellfun(@(a) min(a(:)), AUC));
y_lim = [max(0, floor((y_min - 0.03)/0.1)*0.1), 1.02];
for i = 1:numel(sweeps)
    [xlab, is_integer] = get_sweep_label(sweeps{i});
    plot_auc_panel(X{i}, AUC{i}, names, xlab, is_integer, y_lim, ...
                   fullfile(out_dir, ['auc_baselines_' sweeps{i} tag]));
end
plot_legend(names, 3, 13, false, fullfile(out_dir, ['auc_baselines_legend' tag]));
