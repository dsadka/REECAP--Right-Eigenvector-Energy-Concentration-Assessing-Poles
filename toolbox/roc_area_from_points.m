% Area under an ROC curve given by (P_FA, P_D) points.
function a = roc_area_from_points(FPR, TPR)

[FPR, order] = sort(FPR(:));
TPR = TPR(:);
a = trapz(FPR, TPR(order));

end
