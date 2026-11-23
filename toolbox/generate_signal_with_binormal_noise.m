% Sum of damped complex exponentials (zero phases) + bi-normal noise at a given SNR.
% Each real and imaginary noise sample is drawn independently from
%   N(mu2, sigma2^2) with probability tail_frac, and from N(0,1) otherwise,
% with binormal = [tail_frac, mu2, sigma2].  The noise is NOT centered (its mean is
% tail_frac*mu2 per axis).  It is scaled so that sum(amps.^2) / var(noise) = SNR.
function [signal, noise_var] = generate_signal_with_binormal_noise(freqs, damps, amps, dt, interval, SNR, binormal)

t = 0:dt:interval;
clean = zeros(1, numel(t));
for k = 1:numel(freqs)
    clean = clean + amps(k) * exp((-damps(k) + 1i*freqs(k)) * t);
end

n = binormal_samples(numel(t), binormal) + 1i*binormal_samples(numel(t), binormal);
alpha = sqrt(sum(amps.^2) / (var(n) * 10^(SNR/10)));
signal = clean + alpha*n;
noise_var = alpha^2 * var(n);

end

function x = binormal_samples(n, binormal)

r = rand(1, n);
x = randn(1, n);
tail = r < binormal(1);
x(tail) = binormal(2) + binormal(3) * randn(1, sum(tail));

end
