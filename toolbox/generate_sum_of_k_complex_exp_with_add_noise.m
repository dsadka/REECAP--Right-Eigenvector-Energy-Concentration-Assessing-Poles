function [f, noise, noise_var] = generate_sum_of_k_complex_exp_with_add_noise(freqs, alpha, phases, amps, dt, T, SNR, noise_type)

if length(freqs) ~= length(alpha)
    error('Number of freqs and dumps is different')
end

if length(freqs) ~= length(amps)
    error('Number of freqs and amps is different')
end

% These guards WARN (once per MATLAB session) but no longer stop execution.
persistent warnedNyq warnedFreqOrd warnedAmpOrd

if any(freqs >= 1/(2*dt))
    if isempty(warnedNyq)
        warning('genExp:Nyquist', ...
            ['freq >= 1/(2*dt) = %.4g. This model is exp(1i*freq*t) (no 2*pi), so real ' ...
             'aliasing only occurs at pi/dt = %.4g; below that it is fine. Continuing. (shown once)'], ...
             1/(2*dt), pi/dt);
        warnedNyq = true;
    end
end

if ~isequal(freqs, sort(freqs, 'descend'))
    if isempty(warnedFreqOrd)
        warning('genExp:FreqOrder', ...
            ['freqs are not in descending order -- allowed. Each amp/damp/phase pairs with ' ...
             'its own freq by index, so ordering is only a convention. Continuing. (shown once)']);
        warnedFreqOrd = true;
    end
end

if ~isequal(amps, sort(amps, 'descend'))
    if isempty(warnedAmpOrd)
        warning('genExp:AmpOrder', ...
            ['amps are not in descending order -- allowed. Amplitude is independent of ' ...
             'frequency (paired by index); ordering is only a convention. Continuing. (shown once)']);
        warnedAmpOrd = true;
    end
end

t = 0:dt:T;

s = zeros(length(freqs));
for i=1: length(freqs)
    s(i)   = -alpha(i)  + 1i*freqs(i);
    h(i,:) = amps(i) * exp(s(i) .* t + 1i*phases(i)) ;
end



% fc = sum(amps.*exp((-alpha + 1i*freqs)*t + 1i*phases),1);
fc = sum(h,1);

noise = [];
noise_var=[];
f = fc;
if ~isempty(SNR)
    
    % white, complex Gaussian noise 
    if strcmp(noise_type, 'normal')
        n = randn(size(fc)) + 1i*randn(size(fc));
    elseif strcmp(noise_type, 'uniform')
        n = rand(size(fc))  + 1i*rand(size(fc));
    elseif strcmp(noise_type, 'bi_normal')
        n = randsn(size(fc), 0, 2, 1, 0.1) + 1i*randsn(size(fc), 0, 2, 1, 0.1);
    elseif strcmp(noise_type, 't_student')
        n = trnd(1, size(fc)) + 1i*trnd(1, size(fc));
    end

    Es = sum(amps.^2);
    En = var(n);

    SNR_linear = 10^(SNR/ 10);

    alpha = sqrt( Es/ ( En * SNR_linear ) );
    f     = fc+alpha*n;
    noise = f-fc;
   

    noise_var = var(noise);
end


end

function samples = randsn(N, mu1, mu2, sigma1, sigma2)
%RANDSN  Zero-mean Gaussian-mixture (bi-normal) samples.
%   N : size vector (e.g. size(fc)) or scalar, as for rand.  sigma1, sigma2 are standard deviations.
%   With prob. p a sample is N(mu1, sigma1^2), otherwise N(mu2, sigma2^2).  The theoretical mixture
%   mean p*mu1 + (1-p)*mu2 is subtracted so the noise has NO DC component (a non-zero mean adds a
%   constant = an extra pole at z = 1).  The variance is not normalised here: the caller scales the
%   noise to the requested SNR via var(n).
p = 0.85;                                   % probability of the main component
r = rand(N);
samples = (r < p).*normrnd(mu1, sigma1, N) + ...
          (r >= p).*normrnd(mu2, sigma2, N);
mixtureMean = p*mu1 + (1-p)*mu2;            % = 0.3 for (mu1,mu2) = (0,2)
samples = samples - mixtureMean;
end
