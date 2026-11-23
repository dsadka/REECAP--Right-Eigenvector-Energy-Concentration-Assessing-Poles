% p_d and frequency RMSE of s_p and the baselines.
% Each method selects poles with its own detection rule (one fixed operating point).
%   p_d  = P(Mhat = M), Mhat = number of selected poles
%   RMSE = sqrt(mean over trials of get_freqmatch_error): one-to-one frequency
%          pairing of the selected and true poles + a penalty per missing or extra pole
% binormal (optional) = [tail_frac, mu2, sigma2]: use bi-normal instead of normal noise
%          (see generate_signal_with_binormal_noise.m)
function [Pd, RMSE, CRB, params] = gen_data_pd_rmse_baselines(sweep_var, pMode, binormal)

if nargin < 3
    binormal = [];
end

%% Settings
params = get_cluster_settings();
params.Nrep = 500;
params.fixedSNR = 20;                            % SNR of the spacing sweep
params.granularity_factor = 2;                   % SAMP grid granularity
params.ESTER_frac  = 0.1;                        % ESTER peak fraction
params.RIVES_angle = 1.3;                        % RIVES angle threshold [rad]
params.methods = {'REECAP', 'SAMP', 'SAMP++', 'SDD', 'Gap', 'ESTER', 'RIVES', 'AIC', 'EVT'};
params.sweep_var = sweep_var;
[params.x, params.xlab] = get_sweep_points(sweep_var);

N = params.N;
L = floor(N * params.Lfrac);
interval = (N-1) * params.dt;
nM = numel(params.methods);
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
        if isempty(binormal)
            [signal, ~, noise_var] = generate_sum_of_k_complex_exp_with_add_noise(freqs, damps, zeros(1,M), amps, ...
                                                                                  params.dt, interval, SNR, params.noise);
        else
            [signal, noise_var] = generate_signal_with_binormal_noise(freqs, damps, amps, params.dt, interval, SNR, binormal);
        end
        MP = get_full_rank_MP(signal, L);
        pen = get_order_mismatch_penalty(sweep_var, amps, SNR, clu.minSepR);
        k_max = min(MP.r, size(MP.U,1) - 2);

        % Selected poles of every method
        sel = cell(1, nM);

        % s_p
        p = sp_depth(pMode, nClusters, MP.sigma, MP.r, signal);
        sel{1} = get_sp_selected_poles(MP, p);

        % SAMP: effective-rank pencil + ISR threshold
        [lm, poles, b_new] = get_effective_rank_MP_components(MP.H);
        e = compute_SAMP_signal_detection_features_grid(lm, poles, params);
        sel{2} = poles(samp_isr_mask(poles, b_new, e / max(e), size(lm,1)));

        % SAMP++: full-rank pencil + 2-means on the features
        e = compute_SAMP_plusplus_grid_features(MP.left_mode, MP.poles, params);
        sel{3} = MP.poles(kmeans_1d_high(e / max(e)));

        % SDD, Gap, ESTER: order estimate -> rank-k poles
        sel{4} = get_rank_k_poles(MP, get_rank_by_significant_digits(MP.sigma, 2));
        sel{5} = get_rank_k_poles(MP, get_rank_by_singular_value_gap(MP.sigma));
        J = get_ESTER_criterion(MP.U, k_max);
        sel{6} = get_rank_k_poles(MP, get_ESTER_model_order(J, params.ESTER_frac));

        % RIVES: poles of the oversized ESPRIT fit above the angle threshold
        [angles, rives_poles] = get_RIVES_scores(MP.U, k_max);
        sel{7} = rives_poles(angles > params.RIVES_angle);

        % AIC and EVT (noise variance known)
        M_max = min(MP.r, (N-L) - 2);
        [M_aic, ~, ~, M_evt] = get_ITE_based_MP_model_order(signal(:), L, M_max, max(noise_var, eps));
        sel{8} = get_rank_k_poles(MP, M_aic);
        sel{9} = get_rank_k_poles(MP, M_evt);

        for j = 1:nM
            hits(j)   = hits(j) + (numel(sel{j}) == M);
            sq_err(j) = sq_err(j) + get_freqmatch_error(sel{j}, true_poles, params.dt, pen);
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
