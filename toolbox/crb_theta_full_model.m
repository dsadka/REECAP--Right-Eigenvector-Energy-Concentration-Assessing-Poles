function crb_theta = crb_theta_full_model(amps, phases, damps, freqs, nv, N, dt)
% CRB_THETA_FULL_MODEL  Frequency Cramer-Rao bound (variance), per pole.
%   Full joint-estimation model (all 4M parameters estimated together):
%     y(n) = sum_i amps_i e^{j phases_i} e^{(-damps_i + j freqs_i) n dt} + w,  w ~ (0, nv).
%   Generalizes the attached CRB_unbiased_full_model.m (M=2, 8x8 FIM) to any M,
%   with identical per-pole gradients and the same 2/nv scaling.  Returns the
%   M-vector of CRB variances for the frequencies {freqs_i}; RMSE bound = sqrt(.).
    M = numel(freqs);
    s = -damps(:).' + 1i*freqs(:).';
    FIM = zeros(4*M);
    for n = 0:N-1
        ndt = n*dt;  g = zeros(4*M,1);
        for i = 1:M
            base = exp(1i*phases(i)) * exp(s(i)*ndt);   % e^{j phi} e^{s n dt}
            b    = amps(i);
            g(4*i-3) = -base;               % d/d amplitude
            g(4*i-2) = -1i*b*base;          % d/d phase
            g(4*i-1) =  ndt*b*base;         % d/d damping
            g(4*i  ) = -1i*ndt*b*base;      % d/d frequency
        end
        FIM = FIM + real(g*g');
    end
    FIM = FIM * (2/nv);
    iF  = inv(FIM);                         %#ok<MINV>  (small dense FIM)
    dd  = real(diag(iF));
    crb_theta = dd(4*(1:M));               % frequency entries (index 4i per pole)
end
