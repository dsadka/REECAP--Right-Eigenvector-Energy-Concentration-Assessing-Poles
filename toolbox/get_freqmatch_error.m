% Per-trial squared frequency error of the selected poles.
% The selected and true frequencies are paired one-to-one (matchpairs); each
% missing or extra pole adds pen^2.  The error is the mean of the paired
% squared errors and the penalty entry |Mhat - M| * pen^2.
function e = get_freqmatch_error(sel, true_poles, dt, pen)

true_f = angle(true_poles(:)) / dt;
est_f  = angle(sel(:)) / dt;

if isempty(est_f)
    d = zeros(0, 1);
else
    D = abs(true_f.' - est_f).^2;                % E x M
    pairs = matchpairs(D, 1e6);                  % full matching, no repetitions
    d = abs(est_f(pairs(:,1)) - true_f(pairs(:,2))).^2;
end

n_miss = abs(numel(est_f) - numel(true_f));
e = mean([d; n_miss * pen^2]);

end
