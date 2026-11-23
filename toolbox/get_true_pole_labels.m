% Labels each estimated pole as true (1) or spurious (0).
% The true and estimated poles are paired one-to-one by matchpairs on the
% squared pole distance; a pair is accepted only within a radius of
% 2 Rayleigh cells (2 * 2*pi/N).  Matched estimated poles are the true ones.
function labels = get_true_pole_labels(est_poles, true_poles, N)

tol = (2 * 2*pi/N)^2 / 2;                           % matchpairs accepts cost < 2*tol
C = abs(est_poles(:).' - true_poles(:)).^2;         % M(true) x E(estimated)
pairs = matchpairs(C, tol);

labels = false(numel(est_poles), 1);
labels(pairs(:,2)) = true;

end
