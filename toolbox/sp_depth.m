% Score depth p of s_p (an estimate of the number of clusters).
%   pMode = 'clusters'    : true number of clusters (oracle)
%           'elbow'       : elbowOrder(sigma.^2) - 1  (number of values before the corner)
%           'elbow_raw'   : elbowOrder(sigma.^2)
%           'elbow_m1'    : elbowOrder(sigma.^2) - 2
%           'elbow_accel' : elbowOrderAcceleration(sigma.^2)  (scree acceleration rule)
%           'mean_elbow'  : number of singular values above their mean
%           'fft'         : number of peaks of the Hann-windowed |FFT| of the signal
%           'gap'         : argmax_k sigma_k / sigma_{k+1}
%           'sdd'         : number of sigma_k / sigma_1 >= 10^-2
%   sigma  : all singular values of Y0
%   r_max  : working rank; p is clipped to [1, r_max]
%   signal : the measured signal (used by 'fft')
function p = sp_depth(pMode, nClusters, sigma, r_max, signal)

sigma = sigma(:);
switch pMode
    case 'clusters'
        p = nClusters;
    case {'elbow', 'elbow_raw', 'elbow_m1'}
        k = elbowOrder(sigma.^2, 'linear');
        if isnan(k)                       % flat spectrum: no elbow
            p = 1;
        elseif strcmp(pMode, 'elbow_raw')
            p = k;
        elseif strcmp(pMode, 'elbow')
            p = k - 1;
        else
            p = k - 2;
        end
    case 'elbow_accel'
        p = elbowOrderAcceleration(sigma.^2);
        if isnan(p)
            p = 1;
        end
    case 'mean_elbow'
        p = sum(sigma > mean(sigma));
    case 'fft'
        p = nc_fft_peaks(signal);
    case 'gap'
        n = min(r_max, numel(sigma) - 1);
        [~, p] = max(sigma(1:n) ./ sigma(2:n+1));
    case 'sdd'
        p = sum(sigma / sigma(1) >= 10^-2);
    otherwise
        error('unknown pMode: %s', pMode);
end

p = max(1, min(round(p), r_max));

end
