% Matrix-pencil poles at rank k (the poles an order estimate k keeps).
function poles = get_rank_k_poles(MP, k)

k = round(k);
if k < 1
    poles = [];
    return
end
k = min(k, MP.r);

Ur = MP.U(:, 1:k);
Sr = MP.S(1:k, 1:k);
Vr = MP.V(:, 1:k);
poles = eig(Sr \ (Ur') * MP.Y1 * Vr);

end
