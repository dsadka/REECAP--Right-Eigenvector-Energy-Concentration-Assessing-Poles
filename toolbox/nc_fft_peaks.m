% Number of clusters = number of peaks of the Hann-windowed |FFT| of the signal
% (N-point FFT, no zero padding) that reach at least half of the largest peak.
function p = nc_fft_peaks(signal)

x = signal(:);
n = numel(x);
w = 0.5 - 0.5*cos(2*pi*(0:n-1).' / (n-1));          % Hann window
X = abs(fft(x .* w));

is_peak = X > circshift(X, 1) & X >= circshift(X, -1);   % circular local maxima
p = max(1, sum(is_peak & X >= 0.5 * max(X)));

end
