%% General Settings
% Figure 3: p_d (a, c) and frequency RMSE (b, d) of s_p and the baselines,
% vs SNR (a, b; pole spacing = 1 Rayleigh limit) and vs within-cluster pole spacing (c, d; SNR = 20 dB)
% Depth p of the s_p score (see toolbox/sp_depth.m):
% 'clusters' (true number of clusters) | 'elbow' | 'elbow_accel' | 'fft' | 'gap' | 'sdd' | ...
pMode = 'elbow';
sweeps = {'snr', 'spacing'};

root = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root, 'toolbox'));
out_dir = fullfile(root, 'figures');
if ~exist(out_dir, 'dir'); mkdir(out_dir); end
if strcmp(pMode, 'clusters'); tag = ''; else; tag = ['_' pMode]; end
set_sp_figure_settings(11);

for i = 1:numel(sweeps)
    %% Generate Data
    [Pd, RMSE, CRB, params] = gen_data_pd_rmse_baselines(sweeps{i}, pMode);
    names = params.methods;

    %% Produce graph: p_d  (Fig. 3a for 'snr', Fig. 3c for 'spacing')
    fname = fullfile(out_dir, ['pd_baselines_vs_' sweeps{i} tag]);
    plot_pd_rmse_panel(params.x, Pd, names, params.xlab, 'p_d', [0 1.02], [], fname);

    %% Produce graph: RMSE [dB]  (Fig. 3b for 'snr', Fig. 3d for 'spacing')
    fname = fullfile(out_dir, ['rmse_baselines_vs_' sweeps{i} tag]);
    plot_pd_rmse_panel(params.x, 10*log10(RMSE), names, params.xlab, 'RMSE(\theta) [dB]', [-30 10], ...
                       10*log10(CRB), fname);
end

%% Shared legends
plot_legend(names, 3, 11, false, fullfile(out_dir, ['pd_baselines_legend' tag]));
plot_legend(names, 4, 13, true, fullfile(out_dir, ['rmse_baselines_legend' tag]));
