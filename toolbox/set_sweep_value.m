% Returns the signal settings, SNR and N at one point of a sweep.
% sweep_var : 'SNR' | 'N' | 'nClusters' | 'polesPerCluster' | 'minSepR' | 'damping'
function [params, SNR, N] = set_sweep_value(params, sweep_var, x, SNR)

N = params.N;
switch sweep_var
    case 'SNR',             SNR = x;
    case 'N',               N = x;
    case 'nClusters',       params.nClusters = x;
    case 'polesPerCluster', params.polesPerCluster = x;
    case 'minSepR',         params.minSepR = x;
    case 'damping',         params.dampMax = x;
end

end
