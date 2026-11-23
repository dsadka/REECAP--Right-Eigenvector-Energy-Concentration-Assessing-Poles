function epsilon = compute_SAMP_signal_detection_features_grid(left_modes, poles, params)
% COMPUTE_SAMP_SIGNAL_DETECTION_FEATURES_GRID
%   Official (updated) SAMP similarity-based signal-detection features.
%   Coarse grid similarity P_i(z) (Eq. 36), peak over the grid (Eq. 40),
%   refined by a biquadratic 2-D interpolation of the peak, then the
%   close-pole normalization (Eq. 43).  Returns epsilon scaled to [0,1].
%
%   This is the grid+interpolation version (the official SAMP after the
%   review cycles).  The earlier FFT-peak + k-means detector is kept in
%   compute_SAMP_signal_detection_features.m and is NOT replaced.
%
%   left_modes : N_L x nModes  left modes (Ur*Sr*Q)
%   poles      : nModes x 1     MP eigenvalues (lambda)
%   params     : struct with .dt and optional .granularity_factor (default 1)

    if ~isfield(params,'granularity_factor'); params.granularity_factor = 1; end
    if ~isfield(params,'dt');                 params.dt = 1;                 end
    dt = params.dt;   gf = params.granularity_factor;
    poles = poles(:);

    N = size(left_modes,1);
    % --- coarse grid (theta x damping) ---------------------------------
    dtheta    = gf * pi/N;
    dalpha    = gf / (2*N);
    thetaGrid = -pi:dtheta:pi;   thetaGrid = thetaGrid(1:end-1);
    dampGrid  = (0:dalpha:1)';
    lambdaGrid = exp(-(dampGrid*dt) + 1i*thetaGrid*dt);     % Na x Nt
    Na = size(lambdaGrid,1);   Nt = size(lambdaGrid,2);

    ln = left_modes ./ vecnorm(left_modes);
    % --- similarity on every grid point in one shot (Eq. 36) -----------
    zvec  = lambdaGrid(:).';
    Agrid = zvec .^ ((0:N-1).');
    denom = sum(abs(Agrid).^2, 1);
    P     = abs(ln' * Agrid).^2 ./ denom;                   % nModes x G
    nModes = size(ln,2);

    % --- coarse peak (Eq. 40) ------------------------------------------
    [max_coarse, idx] = max(P, [], 2);
    a0_all = mod(idx-1, Na) + 1;         % damping (row) index
    t0_all = floor((idx-1)/Na) + 1;      % frequency (col) index

    % --- biquadratic 2-D interpolation refinement ----------------------
    Avan = @(z) (z .^ (0:N-1)).';
    epsilon = max_coarse;
    for l = 1:nModes
        Pg = reshape(P(l,:).', Na, Nt);                     % Na x Nt
        [theta_i, alpha_i] = quadratic_2d_interp(Pg, thetaGrid, dampGrid, a0_all(l), t0_all(l));
        z_i = exp(-(alpha_i*dt) + 1i*theta_i*dt);
        a_i = Avan(z_i);
        P_i = abs(a_i' * ln(:,l)).^2 ./ norm(a_i).^2;
        epsilon(l) = max(max_coarse(l), P_i);
    end

    % --- close-pole normalization (Eq. 43) + scale to [0,1] ------------
    diff_matrix    = poles ./ poles.';
    damps_sum_diff = sum(abs(diff_matrix).^2, 1).^2;
    epsilon = epsilon ./ damps_sum_diff(:);
    epsilon = epsilon / max(epsilon);
end
