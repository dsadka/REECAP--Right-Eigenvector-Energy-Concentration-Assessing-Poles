% x-axis label of a sweep, and whether its x values are integers.
function [xlab, is_integer] = get_sweep_label(sweep_var)

is_integer = false;
switch sweep_var
    case 'SNR',             xlab = 'SNR [dB]';
    case 'N',               xlab = 'number of samples N';
    case 'nClusters',       xlab = 'number of clusters';      is_integer = true;
    case 'polesPerCluster', xlab = 'poles per cluster';       is_integer = true;
    case 'minSepR',         xlab = 'pole spacing [\times 2\pi/N]';
    case 'damping',         xlab = 'max per-pole damping';
end

end
