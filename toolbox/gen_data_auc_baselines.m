% Detection ROC AUC (true vs spurious pole) of s_p and the baselines along one sweep.
%   s_p    : score s_p(i) = sum_{k<=p} |W(k,i)|^2, depth p from sp_depth(pMode)
%   SAMP   : SAMP features (grid version)
%   SAMP++ : SAMP++ features (grid version)
%   SDD    : sweep of the truncation rank
%   Gap    : sweep of a threshold on sigma_k / sigma_{k+1}
%   ESTER  : sweep of the ESTER peak fraction
%   RIVES  : angle of each oversized-ESPRIT pole from the noise subspace
% AUC(i, j) = mean AUC over the trials at sweep point i for method j.
function [AUC, params] = gen_data_auc_baselines(sweep_var, pMode)

%% Settings
params = get_cluster_settings();
params.Nrep = 500;
params.SNR = 0;                               % SNR when it is not swept
params.granularity_factor = 2;                % SAMP grid granularity
params.methods = {'REECAP', 'SAMP', 'SAMP++', 'SDD', 'Gap', 'ESTER', 'RIVES'};
params.sweep_var = sweep_var;
switch sweep_var
    case 'SNR',             params.x = linspace(-12, 16, 8);
    case 'N',               params.x = round(linspace(51, 201, 8));
    case 'nClusters',       params.x = 1:5;
    case 'polesPerCluster', params.x = 2:6;
    case 'minSepR',         params.x = linspace(1, 3, 8);
    case 'damping',         params.x = linspace(0, 0.1, 8);
end

nM = numel(params.methods);
AUC = nan(numel(params.x), nM);

for i = 1:numel(params.x)
    [clu, SNR, N] = set_sweep_value(params, sweep_var, params.x(i), params.SNR);
    L = floor(N * params.Lfrac);
    interval = (N-1) * params.dt;
    rng(params.seed);

    auc_sum = zeros(1, nM);
    auc_cnt = zeros(1, nM);
    for rep = 1:params.Nrep
        [freqs, damps, amps, M, nClusters] = gen_cluster_poles(clu, N);
        true_poles = exp(-damps*params.dt + 1i*freqs*params.dt);
        signal = generate_sum_of_k_complex_exp_with_add_noise(freqs, damps, zeros(1,M), amps, ...
                                                              params.dt, interval, SNR, params.noise);
        MP = get_full_rank_MP(signal, L);
        labels = get_true_pole_labels(MP.poles, true_poles, N);
        a = nan(1, nM);

        % s_p
        p = sp_depth(pMode, nClusters, MP.sigma, MP.r, signal);
        a(1) = roc_area(MP.cum(p,:), labels);

        % SAMP and SAMP++
        eps_samp   = compute_SAMP_signal_detection_features_grid(MP.left_mode, MP.poles, params);
        eps_samppp = compute_SAMP_plusplus_grid_features(MP.left_mode, MP.poles, params);
        eps_samp(~isfinite(eps_samp)) = 0;
        eps_samppp(~isfinite(eps_samppp)) = 0;
        a(2) = roc_area(eps_samp, labels);
        a(3) = roc_area(eps_samppp, labels);

        % SDD, Gap and ESTER (order sweeps)
        table = get_rank_detection_table(MP, true_poles, N);
        k_max = min(MP.r, size(MP.U,1) - 2);
        a(4) = get_SDD_auc(table);
        a(5) = get_GAP_auc(table, MP.sigma);
        a(6) = get_ESTER_auc(table, get_ESTER_criterion(MP.U, k_max));

        % RIVES
        [angles, rives_poles] = get_RIVES_scores(MP.U, k_max);
        a(7) = roc_area(angles, get_true_pole_labels(rives_poles, true_poles, N));

        ok = isfinite(a);
        auc_sum(ok) = auc_sum(ok) + a(ok);
        auc_cnt(ok) = auc_cnt(ok) + 1;
    end
    AUC(i,:) = auc_sum ./ max(auc_cnt, 1);
    disp([sweep_var, ' = ', num2str(params.x(i)), ' done'])
end

end
