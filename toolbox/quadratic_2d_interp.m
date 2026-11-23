function [theta_ref, alpha_ref] = quadratic_2d_interp(Pgrid, theta_vec, alpha_vec, a0, t0)
%QUADRATIC_2D_INTERP Richards-style 1D quadratic interpolation applied in theta then alpha.
%   Pgrid    : Na x Nt similarity values (rows = damping/alpha, cols = theta)
%   theta_vec: 1 x Nt frequency grid (columns of Pgrid)
%   alpha_vec: Na x 1 damping grid   (rows of Pgrid)
%   a0, t0   : row (alpha) and column (theta) index of the coarse peak

    [Na, Nt] = size(Pgrid);
    dtheta = theta_vec(2) - theta_vec(1);
    dalpha = alpha_vec(2) - alpha_vec(1);
    theta0 = theta_vec(t0);
    alpha0 = alpha_vec(a0);

    % -------------------------
    % 1) THETA: quadratic peak interpolation (Eq. 5.96-5.97)
    % -------------------------
    t0_m1 = mod(t0-2, Nt) + 1;
    t0_p1 = mod(t0,   Nt) + 1;
    fm = Pgrid(a0, t0_m1);
    f0 = Pgrid(a0, t0);
    fp = Pgrid(a0, t0_p1);
    denT = (fm - 2*f0 + fp);
    if denT < 0
        dT = (fm - fp) / (2*denT);        % Eq. (5.97)
        dT = max(min(dT, 1), -1);
    else
        dT = 0;
    end
    theta_ref = wrapToPi_local(theta0 + dT*dtheta);

    % -------------------------
    % 2) ALPHA: same, using the row neighbours
    % -------------------------
    if a0 == 1 || a0 == Na
        alpha_ref = alpha0;
        return;
    end
    fm = Pgrid(a0-1, t0);
    f0 = Pgrid(a0,   t0);
    fp = Pgrid(a0+1, t0);
    denA = (fm - 2*f0 + fp);
    if denA < 0
        dA = (fm - fp) / (2*denA);        % Eq. (5.97)
        dA = max(min(dA, 1), -1);
    else
        dA = 0;
    end
    alpha_ref = min(max(alpha0 + dA*dalpha, 0), 1);
end

function th = wrapToPi_local(th)
    th = mod(th + pi, 2*pi) - pi;
end
