function [mask, tau] = samp_isr_mask(poles, b_tilde, epsilon, N_L)
% SAMP_ISR_MASK  ISR signal subset for SAMP (Eq. 46 / renumbered Eq. 49).
%   Given the (Eq-43-normalized, [0,1]-scaled) features epsilon, the MP poles,
%   the amplitudes b_tilde and the mode length N_L, returns the logical mask of
%   signal-related modes:  epsilon_i > ((1-ISR_i)/(1+ISR_i))^2.
%
%   poles   : nModes x 1   MP eigenvalues
%   b_tilde : nModes x 1   amplitudes (left_mode(1,:).' .* right_mode(:,1))
%   epsilon : nModes x 1   SAMP features (already scaled to [0,1])
%   N_L     : scalar       number of rows of the left-mode matrix

    poles = poles(:);  bt = abs(b_tilde(:));
    Avan  = poles.' .^ ((0:N_L-1).');          % N_L x nModes
    c     = 10*sqrt(N_L) ./ vecnorm(Avan);     % 1 x nModes
    ISR   = c(:) ./ bt;
    tau   = ((1 - ISR) ./ (1 + ISR)).^2;       % Eq. 46/49 lower bound
    mask  = epsilon(:) > tau(:);
end
