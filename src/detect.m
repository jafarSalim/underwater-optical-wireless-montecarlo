function [P, t, wts] = detect(X, k, D, fov_deg)
%DETECT  Received power fraction at plane k for an aperture of diameter D (m)
%   and a field of view fov_deg (half angle). A photon is absorbed by the
%   receiver at its first crossing inside the aperture; it counts if its
%   angle to the axis is inside the field of view.
sel = find(X.k == k & X.r <= D/2);
[~, first] = unique(X.id(sel), 'first');      % first crossing inside the aperture
sel = sel(first);
ok = acosd(double(X.cth(sel))) <= fov_deg;
sel = sel(ok);
wts = double(X.w(sel));
t = double(X.t(sel));
P = sum(wts) / X.N;
end
