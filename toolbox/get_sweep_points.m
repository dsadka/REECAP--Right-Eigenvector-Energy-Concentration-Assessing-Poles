% x values of the SNR / spacing sweeps of the p_d and RMSE simulations,
% and the SNR and within-cluster spacing at one point.
%   'snr'     : SNR = 0:2:30 dB, spacing fixed at params.minSepR
%   'spacing' : within-cluster spacing = 0.5:0.15:2 [x 2*pi/N], SNR fixed at 20 dB
function [x, xlab] = get_sweep_points(sweep_var)

if strcmp(sweep_var, 'snr')
    x = 0:2:30;
    xlab = 'SNR [dB]';
else
    x = 0.5:0.15:2;
    xlab = 'pole spacing [\times 2\pi/N]';
end

end
