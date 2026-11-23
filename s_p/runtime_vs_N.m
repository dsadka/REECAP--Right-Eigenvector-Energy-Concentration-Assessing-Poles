%% General Settings
% Run time vs number of samples N of s_p and the baselines
% Depth p of the s_p score (see toolbox/sp_depth.m):
% 'clusters' (true number of clusters) | 'elbow' | 'elbow_accel' | 'fft' | 'gap' | 'sdd' | ...
pMode = 'elbow';

root = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root, 'toolbox'));
out_dir = fullfile(root, 'figures');
if ~exist(out_dir, 'dir'); mkdir(out_dir); end
if strcmp(pMode, 'clusters'); tag = ''; else; tag = ['_' pMode]; end
set_sp_figure_settings(11);

%% Generate Data
[T, T_decomp, params] = gen_data_runtime(pMode);
names = params.methods;
fname = fullfile(out_dir, ['runtime_vs_N' tag]);
save([fname '_data.mat'], 'T', 'T_decomp', 'params');

% Average time ratios over the N grid
ratio = T(:, strcmp(names, 'EVT')) ./ T(:, strcmp(names, 'REECAP'));
disp(['time EVT / REECAP : mean ', num2str(mean(ratio), 3)])
ratio = T(:, strcmp(names, 'REECAP')) ./ T(:, strcmp(names, 'SDD'));
disp(['time REECAP / SDD : mean ', num2str(mean(ratio), 3)])

%% Produce graph
plot_runtime(params.N_range, T, T_decomp, names, fname);
plot_legend(names, 3, 13, false, [fname '_legend'], true);
