% Area under the ROC curve of a score (higher score = more likely true).
% Ties are collapsed, so tied candidates get half credit.
% Returns NaN when there are no true or no spurious candidates.
function a = roc_area(score, labels)

score  = score(:);
labels = logical(labels(:));
P  = sum(labels);
Nn = sum(~labels);
if P == 0 || Nn == 0
    a = NaN;
    return
end

[s, order] = sort(score, 'descend');
y  = labels(order);
tp = cumsum(y);
fp = cumsum(~y);
last = [diff(s) ~= 0; true];                 % last index of each tied run

TPR = [0; tp(last) / P];
FPR = [0; fp(last) / Nn];
a = trapz(FPR, TPR);

end
