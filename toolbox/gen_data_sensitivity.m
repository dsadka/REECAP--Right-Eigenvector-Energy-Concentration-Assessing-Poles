% Sensitivity of the s_p detection AUC to its hyperparameters.
% Each line fixes one value of sens_var; the x-axis sweeps x_var.
%   sens_var = 'p'    : depth p = 10 values from 1 to Khat (= L-1)
%            = 'L'    : pencil parameter L = 10 values from N/3 to N/2
%            = 'Khat' : working rank Khat = K + f*(L-K), f = 10 values from 0 to 1
%                       (K = number of poles at the current x point)
% The hyperparameters that are not varied use L = N/3, full rank and p = sp_depth(pMode).
% For sens_var = 'p' one extra (last) column holds p = sp_depth(pMode).
function [AUC, params] = gen_data_sensitivity(sens_var, x_var, pMode)

%% Settings
params = get_cluster_settings();
params.Nrep = 500;
params.SNR = 0;                               % SNR when it is not swept
n_lines = 10;
params.sens_var = sens_var;
params.x_var = x_var;
switch x_var
    case 'SNR',             params.x = -10:2:16;
    case 'N',               params.x = round(linspace(51, 201, 8));
    case 'nClusters',       params.x = 1:6;
    case 'polesPerCluster', params.x = 2:6;
    case 'minSepR',         params.x = linspace(1, 3, 8);
    case 'damping',         params.x = linspace(0, 0.1, 8);
end

L0 = floor(params.N * params.Lfrac);
params.Khat_nominal = min(L0, params.N - L0) - 1;   % full working rank at the base N
switch sens_var
    case 'p'
        params.lines = 1:2:params.Khat_nominal;
        if numel(params.lines) > n_lines
            params.lines = unique(round(linspace(1, params.Khat_nominal, n_lines)));
        end
    case 'L'
        params.lines = linspace(1/3, 1/2, n_lines);
    case 'Khat'
        params.lines = linspace(0, 1, n_lines);
end
params.has_bold = strcmp(sens_var, 'p');
n_cols = numel(params.lines) + params.has_bold;
AUC = nan(numel(params.x), n_cols);

for i = 1:numel(params.x)
    [clu, SNR, N] = set_sweep_value(params, x_var, params.x(i), params.SNR);
    interval = (N-1) * params.dt;
    for j = 1:n_cols
        rng(params.seed);
        auc_sum = 0;
        auc_cnt = 0;
        for rep = 1:params.Nrep
            [freqs, damps, amps, M, nClusters] = gen_cluster_poles(clu, N);
            true_poles = exp(-damps*params.dt + 1i*freqs*params.dt);
            signal = generate_sum_of_k_complex_exp_with_add_noise(freqs, damps, zeros(1,M), amps, ...
                                                                  params.dt, interval, SNR, params.noise);
            % Hyperparameters of this line
            L = floor(N * params.Lfrac);
            Khat = inf;
            p = [];
            if j <= numel(params.lines)
                switch sens_var
                    case 'L',    L = floor(N * params.lines(j));
                    case 'Khat', Khat = max(1, round(M + params.lines(j) * (min(L, N-L) - M)));
                    case 'p',    p = params.lines(j);
                end
            end

            MP = get_full_rank_MP(signal, L, Khat);
            if isempty(p)
                p = sp_depth(pMode, nClusters, MP.sigma, MP.r, signal);
            end
            p = max(1, min(p, MP.r));

            a = roc_area(MP.cum(p,:), get_true_pole_labels(MP.poles, true_poles, N));
            if isfinite(a)
                auc_sum = auc_sum + a;
                auc_cnt = auc_cnt + 1;
            end
        end
        AUC(i,j) = auc_sum / max(auc_cnt, 1);
    end
    disp([x_var, ' = ', num2str(params.x(i)), ' done'])
end

end
