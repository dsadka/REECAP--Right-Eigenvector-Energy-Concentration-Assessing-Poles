function epsilon = compute_SAMP_plusplus_grid_features(left_modes, poles, params)
% COMPUTE_SAMP_PLUSPLUS_GRID_FEATURES
%   SAMP++ signal-detection features built on the OFFICIAL SAMP similarity:
%     rho   = grid+interpolation similarity feature (Eq. 40/43), scaled [0,1]
%     sigma = mode-correlation term (SAMP++ Eq. 19)
%     epsilon = alpha*rho_n + (1-alpha)*sigma_n          (SAMP++ Eq. 17)
%
%   This replaces the FFT-peak rho of the EUSIPCO snippet with the official
%   grid-based rho, per "official SAMP + the SAMP++ addition".  The FFT-based
%   SAMP++ (compute_SAMP_plusplus_signal_detection_features.m) is kept intact.
%
%   params : struct with .dt, optional .granularity_factor, optional .alpha_pp (default 0.5)

    if ~isfield(params,'alpha_pp'); alpha = 0.5; else; alpha = params.alpha_pp; end

    % --- rho : official grid-based similarity feature (already [0,1]) ---
    rho = compute_SAMP_signal_detection_features_grid(left_modes, poles, params);

    % --- sigma : mode correlation term (Eq. 19) ------------------------
    C = abs(cov(left_modes));
    C(logical(eye(size(C)))) = NaN;
    sigma = std(C, [], 2, 'omitnan');

    % --- combined feature (Eq. 17) -------------------------------------
    epsilon = alpha*(rho/max(rho)) + (1-alpha)*(sigma/max(sigma));
end
