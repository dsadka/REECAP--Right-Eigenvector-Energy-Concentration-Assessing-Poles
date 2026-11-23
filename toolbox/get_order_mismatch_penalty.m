% Penalty pen for each missing or extra pole in the frequency RMSE (each adds pen^2).
%   SNR sweep     : pen^2 = noise variance sigma_w^2
%   spacing sweep : pen^2 = 1 / (2*pi*spacing)^2
function pen = get_order_mismatch_penalty(sweep_var, amps, SNR, spacing)

if strcmp(sweep_var, 'snr')
    pen = sqrt(sum(amps.^2) / 10^(SNR/10));
else
    pen = 1 / (2*pi*spacing);
end

end
