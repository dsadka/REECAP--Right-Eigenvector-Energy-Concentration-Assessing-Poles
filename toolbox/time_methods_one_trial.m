% Wall-clock time [s] of one trial: the shared matrix-pencil decomposition
% (t_decomp) and each method's own detection step on top of it (t_methods).
% Methods: s_p, SAMP, SAMP++, Gap, SDD, ESTER, AIC, EVT, RIVES.
function [t_decomp, t_methods] = time_methods_one_trial(signal, L, noise_var, nClusters, pMode, params)

t_methods = zeros(1, 9);
H = create_hankel_matrix(signal, L);

% Shared matrix-pencil decomposition
tic;
Y0 = H(:, 1:end-1);
Y1 = H(:, 2:end);
[U, S, V] = svd(Y0, 'econ');
r = max(1, min(size(Y0)) - 1);
Ur = U(:, 1:r);
Sr = S(1:r, 1:r);
Vr = V(:, 1:r);
[W, D] = eig(Sr \ (Ur') * Y1 * Vr);
poles = diag(D);
cum = cumsum(abs(W).^2, 1);
sigma = diag(Sr);
left_mode = Ur * Sr * W;
t_decomp = toc;

% s_p: depth p + 2-means on log10(s_p)
tic;
p = sp_depth(pMode, nClusters, diag(S), r, signal);
get_true_idx(log10(max(cum(p,:).', realmin)), 'kmeans');
t_methods(1) = toc;

% SAMP: features + ISR threshold
tic;
right_mode = W \ Vr';
b_new = (left_mode(1,:).') .* right_mode(:,1);
e = compute_SAMP_signal_detection_features_grid(left_mode, poles, params);
samp_isr_mask(poles, b_new, e, size(left_mode,1));
t_methods(2) = toc;

% SAMP++: features + 2-means
tic;
e = compute_SAMP_plusplus_grid_features(left_mode, poles, params);
get_true_idx(e / max(e), 'kmeans');
t_methods(3) = toc;

% Gap
tic;
get_rank_by_singular_value_gap(sigma);
t_methods(4) = toc;

% SDD
tic;
get_rank_by_significant_digits(sigma, 2);
t_methods(5) = toc;

% ESTER
tic;
get_ESTER_model_order(get_ESTER_criterion(U, min(r, size(U,1) - 2)), 0.1);
t_methods(6) = toc;

% AIC and EVT (each runs its own likelihood sweep over all orders)
M_max = max(1, min(min(size(Y0)) - 1, size(Y0,1) - 2));
tic;
get_ITE_based_MP_model_order(signal(:), L, M_max, max(noise_var, eps));
t_methods(7) = toc;
tic;
get_ITE_based_MP_model_order(signal(:), L, M_max, max(noise_var, eps));
t_methods(8) = toc;

% RIVES (the angle threshold does not affect the time)
tic;
angles = get_RIVES_scores(U, min(r, size(U,1) - 2));
sum(angles > pi/4);
t_methods(9) = toc;

end
