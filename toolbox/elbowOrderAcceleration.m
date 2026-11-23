function [k, acceleration, values] = elbowOrderAcceleration(v)
%ELBOWORDERACCELERATION Estimate order using the scree acceleration rule.
%   The elbow maximizes the positive second difference.
%   k counts the entries preceding the elbow, so k = 1 is possible.
%   Returns NaN when no positive acceleration is identifiable.
validateattributes(v, {'numeric'}, ...
    {'vector','real','finite','nonnegative','nonempty'}, mfilename, 'v');
values = sort(double(v(:)), 'descend');
n = numel(values);
acceleration = zeros(n,1);
k = NaN;
if n < 3 || values(1) == values(end)
    return;
end
% Normalize for numerical stability; this preserves the maximizing index.
y = values / values(1);
y = (y - y(end)) / (y(1) - y(end));
% acceleration(j) = y(j-1) - 2*y(j) + y(j+1).
acceleration(2:n-1) = diff(y, 2);
[peak, r] = max(acceleration(2:n-1));
if peak > 10*eps
    j = r + 1;       % Elbow index in the original spectrum
    k = j - 1;       % Number of entries preceding the elbow
end
end
