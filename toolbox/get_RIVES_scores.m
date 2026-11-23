% RIVES: fit an oversized ESPRIT model of order M_over and score each pole by
% its angle from the noise subspace (larger angle = more signal-like).
function [angles, poles] = get_RIVES_scores(U, M_over)

U_over = U(:, 1:M_over);
poles = eig(U_over(1:end-1,:) \ U_over(2:end,:));

n_rows = size(U, 1);
angles = zeros(M_over, 1);
for j = 1:M_over
    if poles(j) == 0
        v = [1; zeros(n_rows-1, 1)];
    else
        v = poles(j) .^ (0:n_rows-1).';
        v = v / norm(v);
    end
    angles(j) = asin(min(1, norm(U_over' * v)));
end

end
