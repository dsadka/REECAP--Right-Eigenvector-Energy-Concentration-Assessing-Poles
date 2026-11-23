%% General Settings
% Sensitivity of the s_p detection AUC to its hyperparameters
sens_var = 'Khat';            % hyperparameter varied across the curves: 'p' | 'L' | 'Khat'
x_var = 'damping';            % x-axis: 'SNR' | 'N' | 'nClusters' | 'polesPerCluster' | 'minSepR' | 'damping'
% Depth p of the s_p score when p is not varied (see toolbox/sp_depth.m):
% 'clusters' (true number of clusters) | 'elbow' | 'elbow_accel' | 'fft' | 'gap' | 'sdd' | ...
pMode = 'elbow';

root = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root, 'toolbox'));
out_dir = fullfile(root, 'figures');
if ~exist(out_dir, 'dir'); mkdir(out_dir); end
if strcmp(pMode, 'clusters'); tag = ''; else; tag = ['_' pMode]; end
set_sp_figure_settings(13, 'latex');

%% Generate Data
[AUC, params] = gen_data_sensitivity(sens_var, x_var, pMode);

%% Produce graph
plot_sensitivity(AUC, params, fullfile(out_dir, ['sensitivity_' sens_var '_vs_' x_var tag]));
