% Matrix pencil at the effective rank (as in the SAMP toolbox get_MP_components
% with rank_type = 'effective').  Returns the left modes, the poles and the
% amplitudes b_new used by the SAMP ISR threshold.
function [left_mode, poles, b_new] = get_effective_rank_MP_components(H)

Y0 = H(:, 1:end-1);
Y1 = H(:, 2:end);

r = round(erank(Y0));
if r == min(size(Y0))                   % for lowering the noise level in case of full rank
    r = r - 1;
end

[U, S, V] = svd(Y0, 'econ');
Ur = U(:, 1:r);
Sr = S(1:r, 1:r);
Vr = V(:, 1:r);
[W, D] = eig(Sr \ (Ur') * Y1 * Vr);

poles = diag(D);
left_mode  = Ur * Sr * W;
right_mode = W \ Vr';
b_new = (left_mode(1,:).') .* right_mode(:,1);

end
