% Gap ROC area: sweep a threshold over the ratios sigma_k / sigma_{k+1};
% the order is the first k whose ratio exceeds the threshold.
function a = get_GAP_auc(table, sigma)

n_thr = 500;
r_full = table.r_full;
ratios = sigma(1:r_full) ./ sigma(2:r_full+1);
thresholds = linspace(0, 1.001 * max([ratios(isfinite(ratios)); 1]), n_thr);

TPR = zeros(n_thr+1, 1);
FPR = zeros(n_thr+1, 1);
for j = 1:n_thr
    k = find(ratios > thresholds(j), 1, 'first');
    if isempty(k)
        k = r_full;
    end
    TPR(j+1) = table.TPR(k);
    FPR(j+1) = table.FPR(k);
end
a = roc_area_from_points(FPR, TPR);

end
