% p_d = P(Mhat = M) and frequency RMSE of s_p when the depth p (number of
% clusters) is known (oracle) or estimated by the elbow or FFT rule.
% The poles s_p keeps are the high group of a 2-means on log10(s_p).
function [Pd, RMSE, CRB, params] = gen_data_pd_rmse_p_rules(sweep_var)

%% Settings
params = get_cluster_settings();
params.Nrep = 200;
params.fixedSNR = 20;                            % SNR of the spacing sweep
params.pModes = {'clusters', 'elbow', 'fft'};
params.sweep_var = sweep_var;
[params.x, params.xlab] = get_sweep_points(sweep_var);

N = params.N;
L = floor(N * params.Lfrac);
interval = (N-1) * params.dt;
nM = numel(params.pModes);
nX = numel(params.x);
Pd   = nan(nX, nM);
RMSE = nan(nX, nM);
CRB  = nan(nX, 1);

for i = 1:nX
    clu = params;
    if strcmp(sweep_var, 'snr')
        SNR = params.x(i);
    else
        SNR = params.fixedSNR;
        clu.minSepR = params.x(i);
    end
    rng(params.seed);

    hits = zeros(1, nM);
    sq_err = zeros(1, nM);
    crb_sum = 0;
    crb_cnt = 0;
    for rep = 1:params.Nrep
        [freqs, damps, amps, M, nClusters] = gen_cluster_poles(clu, N);
        true_poles = exp(-damps*params.dt + 1i*freqs*params.dt);
        [signal, ~, noise_var] = generate_sum_of_k_complex_exp_with_add_noise(freqs, damps, zeros(1,M), amps, ...
                                                                              params.dt, interval, SNR, params.noise);
        MP = get_full_rank_MP(signal, L);
        pen = get_order_mismatch_penalty(sweep_var, amps, SNR, clu.minSepR);

        for j = 1:nM
            p = sp_depth(params.pModes{j}, nClusters, MP.sigma, MP.r, signal);
            [sel, k] = get_sp_selected_poles(MP, p);
            hits(j)   = hits(j) + (k == M);
            sq_err(j) = sq_err(j) + get_freqmatch_error(sel, true_poles, params.dt, pen);
        end

        crb = crb_theta_full_model(amps, zeros(1,M), damps, freqs, noise_var, N, params.dt);
        crb_sum = crb_sum + sum(crb);
        crb_cnt = crb_cnt + M;
    end
    Pd(i,:)   = hits / params.Nrep;
    RMSE(i,:) = sqrt(sq_err / params.Nrep);
    CRB(i)    = sqrt(crb_sum / crb_cnt);
    disp([sweep_var, ' = ', num2str(params.x(i)), ' done'])
end

end
