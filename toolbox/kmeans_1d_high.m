% Deterministic 1-D 2-means: indices of the group with the higher mean.
function idx = kmeans_1d_high(x)

x = x(:);
n = numel(x);
if n <= 1
    idx = (1:n).';
    return
end

[xs, order] = sort(x);
cs  = [0; cumsum(xs)];
cs2 = [0; cumsum(xs.^2)];

best_cost = inf;
best_k = 1;
for k = 1:n-1
    cost_low  = cs2(k+1) - cs(k+1)^2 / k;
    cost_high = (cs2(n+1) - cs2(k+1)) - (cs(n+1) - cs(k+1))^2 / (n-k);
    if cost_low + cost_high < best_cost
        best_cost = cost_low + cost_high;
        best_k = k;
    end
end

idx = sort(order(best_k+1:n));

end
