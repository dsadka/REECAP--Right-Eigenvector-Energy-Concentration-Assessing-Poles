% Poles that s_p declares signal: 2-means on log10(s_p), keep the high group.
function [sel, k] = get_sp_selected_poles(MP, p)

s = MP.cum(p, :).';
idx = kmeans_1d_high(log10(max(s, realmin)));
sel = MP.poles(idx);
k = numel(idx);

end
