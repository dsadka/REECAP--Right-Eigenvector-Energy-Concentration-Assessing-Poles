% Matrix pencil of the signal at working rank Khat (default: full rank).
% Returns a struct with the poles, the s_p scores of every depth
% (cum(p,i) = s_p of pole i = sum_{k<=p} |W(k,i)|^2), and the SVD of Y0.
function MP = get_full_rank_MP(signal, L, Khat)

if nargin < 3
    Khat = inf;
end

H  = create_hankel_matrix(signal, L);
Y0 = H(:, 1:end-1);
Y1 = H(:, 2:end);

[U, S, V] = svd(Y0, 'econ');
r_max = min(size(Y0)) - 1;
r = max(1, min(round(Khat), r_max));

Ur = U(:, 1:r);
Sr = S(1:r, 1:r);
Vr = V(:, 1:r);
[W, D] = eig(Sr \ (Ur') * Y1 * Vr);

MP.poles     = diag(D);
MP.cum       = cumsum(abs(W).^2, 1);    % s_p scores, one row per depth p
MP.left_mode = Ur * Sr * W;             % SAMP left modes
MP.sigma     = diag(S);                 % all singular values of Y0
MP.r         = r;
MP.H = H;  MP.U = U;  MP.S = S;  MP.V = V;  MP.Y1 = Y1;

end
