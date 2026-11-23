% Frequencies, dampings and amplitudes of the clustered signal.
% The cluster centers are fixed; each pole gets a random damping ~ U[0, dampMax].
function [freqs, damps, amps, M, nClusters] = gen_cluster_poles(params, N)

ray = 2*pi/N;                                          % Rayleigh cell
nClusters = params.nClusters;
centers = params.w1 + (0:nClusters-1) * params.centerSepR * ray;

freqs = [];
damps = [];
for c = 1:nClusters
    offsets = (0:params.polesPerCluster-1) * params.minSepR * ray;
    offsets = offsets - mean(offsets);                 % center the cluster
    freqs = [freqs, centers(c) + offsets];             %#ok<AGROW>
    damps = [damps, params.dampMax * rand(1, params.polesPerCluster)]; %#ok<AGROW>
end

M = numel(freqs);
amps = ones(1, M);

end
