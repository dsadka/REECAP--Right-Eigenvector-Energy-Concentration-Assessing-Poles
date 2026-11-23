% Detection ROC AUC of s_p for different rules of choosing the depth p,
% along one sweep.  All rules see the same trials.
function [AUC, params] = gen_data_auc_p_rules(sweep_var)

%% Settings
params = get_cluster_settings();
params.Nrep = 500;
params.SNR = 0;                               % SNR when it is not swept
params.pModes = {'clusters', 'elbow', 'elbow_accel', 'gap', 'sdd', 'fft'};
params.sweep_var = sweep_var;
switch sweep_var
    case 'SNR',             params.x = linspace(-12, 16, 8);
    case 'N',               params.x = round(linspace(51, 201, 8));
    case 'nClusters',       params.x = 1:5;
    case 'polesPerCluster', params.x = 2:6;
    case 'minSepR',         params.x = linspace(1, 3, 8);
    case 'damping',         params.x = linspace(0, 0.1, 8);
end

nM = numel(params.pModes);
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

        for j = 1:nM
            p = sp_depth(params.pModes{j}, nClusters, MP.sigma, MP.r, signal);
            a = roc_area(MP.cum(p,:), labels);
            if isfinite(a)
                auc_sum(j) = auc_sum(j) + a;
                auc_cnt(j) = auc_cnt(j) + 1;
            end
        end
    end
    AUC(i,:) = auc_sum ./ max(auc_cnt, 1);
    disp([sweep_var, ' = ', num2str(params.x(i)), ' done'])
end

end
