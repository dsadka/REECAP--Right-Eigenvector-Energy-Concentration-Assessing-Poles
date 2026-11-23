% For every truncation rank r = 1..MP.r: number of true (TP) and spurious (FP)
% poles among the r matrix-pencil poles.  Used by the order-sweep baselines.
function table = get_rank_detection_table(MP, true_poles, N)

r_full = MP.r;
M = numel(true_poles);
TP = zeros(r_full, 1);
FP = zeros(r_full, 1);
for r = 1:r_full
    labels = get_true_pole_labels(get_rank_k_poles(MP, r), true_poles, N);
    TP(r) = sum(labels);
    FP(r) = r - TP(r);
end

table.TPR = TP / M;
table.FPR = min(FP / max(r_full - M, 1), 1);
table.r_full = r_full;

end
