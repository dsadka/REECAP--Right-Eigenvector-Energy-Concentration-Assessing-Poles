% Default signal settings shared by all the clustered-pole simulations.
% nClusters clusters, centers 15 Rayleigh cells apart, each cluster with
% polesPerCluster poles spaced minSepR Rayleigh cells apart (1 Rayleigh cell = 2*pi/N).
% Equal unit amplitudes, random damping ~ U[0, dampMax].
function params = get_cluster_settings()

params.nClusters       = 3;      % number of clusters
params.polesPerCluster = 2;      % poles per cluster
params.minSepR         = 1;      % within-cluster pole spacing [x 2*pi/N]
params.centerSepR      = 15;     % cluster-center separation [x 2*pi/N]
params.w1              = 0.15;   % first cluster center [rad/sample]
params.dampMax         = 0.05;   % per-pole damping ~ U[0, dampMax]

params.N       = 71;             % number of samples
params.Lfrac   = 1/3;            % pencil parameter L = floor(N/3)
params.dt      = 1;
params.noise   = 'normal';
params.seed    = 1;

end
