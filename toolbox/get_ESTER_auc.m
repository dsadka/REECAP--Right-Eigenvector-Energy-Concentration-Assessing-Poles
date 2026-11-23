% ESTER ROC area: sweep the peak fraction from 0 to 1; each fraction gives an order.
function a = get_ESTER_auc(table, J)

fracs = linspace(0, 1, 500);
TPR = zeros(numel(fracs)+1, 1);
FPR = zeros(numel(fracs)+1, 1);
for j = 1:numel(fracs)
    K = min(get_ESTER_model_order(J, fracs(j)), table.r_full);
    TPR(j+1) = table.TPR(K);
    FPR(j+1) = table.FPR(K);
end
a = roc_area_from_points(FPR, TPR);

end
