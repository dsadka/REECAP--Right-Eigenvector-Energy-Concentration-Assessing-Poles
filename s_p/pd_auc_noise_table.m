%% General Settings
% Table: area under the p_d-vs-SNR curve (mean p_d over SNR = 0..30 dB) of REECAP and
% the baselines, under normal noise N(0,1) and bi-normal noise 0.75*N(0,1) + 0.25*N(3,0.25^2)
% (applied independently to the real and imaginary parts)
% Depth p of the s_p score (see toolbox/sp_depth.m):
% 'clusters' (true number of clusters) | 'elbow' | 'elbow_accel' | 'fft' | 'gap' | 'sdd' | ...
pMode = 'elbow';
noise_names = {'Normal', 'Bi-normal'};
binormal = {[], [0.25, 3, 0.25]};           % [] = normal; [tail_frac, mu2, sigma2]

root = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root, 'toolbox'));
out_dir = fullfile(root, 'figures');
if ~exist(out_dir, 'dir'); mkdir(out_dir); end
if strcmp(pMode, 'clusters'); tag = ''; else; tag = ['_' pMode]; end

%% Generate Data
AUC = [];
for k = 1:numel(binormal)
    [Pd, ~, ~, params] = gen_data_pd_rmse_baselines('snr', pMode, binormal{k});
    AUC(:,k) = trapz(params.x, Pd).' / (params.x(end) - params.x(1)); %#ok<AGROW>
end

%% Produce table
disp(array2table(AUC, 'RowNames', params.methods, 'VariableNames', noise_names))
plot_table(params.methods, noise_names, AUC, fullfile(out_dir, ['pd_auc_noise_table' tag]));
