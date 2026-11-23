% SDD ROC area: sweeping the significant-digits cutoff is the same as sweeping
% the truncation rank over 1..r_full.
function a = get_SDD_auc(table)

a = roc_area_from_points([0; table.FPR], [0; table.TPR]);

end
