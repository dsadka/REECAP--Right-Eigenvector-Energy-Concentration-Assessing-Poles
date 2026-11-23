function [k, distance, values] = elbowOrder(v, scale)
%ELBOWORDER Estimate an elbow in a descending eigenvalue spectrum.
% k = elbowOrder(v) uses the maximum distance from the endpoint chord.
% k = elbowOrder(v,'log') applies the method to log eigenvalues.
% [k,distance,values] also returns scores and sorted input values.
% k is the number of entries through the elbow (not necessarily clusters).
% Flat or two-point spectra have no identifiable elbow: k = NaN.
if nargin < 2
    scale = 'linear';
end
validateattributes(v, {'numeric'}, ...
    {'vector','real','finite','nonnegative','nonempty'}, mfilename, 'v');
scale = validatestring(scale, {'linear','log'}, mfilename, 'scale');
values = sort(double(v(:)), 'descend');
n = numel(values);
distance = zeros(n,1);
k = NaN;
if n < 3 || values(1) == values(end)
    return;
end
y = values / values(1);
if strcmp(scale, 'log')
    % Floor zero/tiny values to avoid log(0).
    y = log(max(y, eps));
end
if y(1) == y(end)
    return;
end
x = (0:n-1).' / (n-1);
y = (y-y(end)) / (y(1)-y(end));
% Endpoint chord in normalized coordinates is x+y=1.
distance = abs(x+y-1) / sqrt(2);
distance([1 end]) = 0;
[peak,k] = max(distance);
if peak <= 10*eps
    k = NaN; % A straight spectrum has no identifiable elbow.
end
end
