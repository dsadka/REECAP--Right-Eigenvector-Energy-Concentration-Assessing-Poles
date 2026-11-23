% ESTER criterion J(k) = 1 / ||U_up - U_down * Psi||^2, k = 1..k_max.
function J = get_ESTER_criterion(U, k_max)

J = zeros(k_max, 1);
for k = 1:k_max
    U_down = U(1:end-1, 1:k);
    U_up   = U(2:end, 1:k);
    Psi = U_down \ U_up;
    J(k) = 1 / max(norm(U_up - U_down*Psi, 2)^2, realmin);
end

end
