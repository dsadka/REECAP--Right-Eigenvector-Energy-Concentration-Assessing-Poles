% ESTER order: the last local peak of J that reaches frac * max(J).
function K = get_ESTER_model_order(J, frac)

n = numel(J);
is_peak = false(n, 1);
if n == 1
    is_peak(1) = true;
else
    is_peak(1)     = J(1) >= J(2);
    is_peak(2:n-1) = J(2:n-1) >= J(1:n-2) & J(2:n-1) >= J(3:n);
    is_peak(n)     = J(n) >= J(n-1);
end

K = find(is_peak & J >= frac*max(J), 1, 'last');
if isempty(K)
    [~, K] = max(J);
end

end
