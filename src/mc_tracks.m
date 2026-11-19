function T = mc_tracks(w, n, opt, maxev)
%MC_TRACKS  Full trajectories of n photons (positions at every scattering event),
%   used only for pictures. Rows: photons; pages: events; NaN after death.
if nargin < 4, maxev = 60; end
P = nan(n, maxev + 1, 3);  W = nan(n, maxev + 1);
th = abs(opt.div * randn(n, 1));  ph = 2*pi*rand(n, 1);
u = [sin(th).*cos(ph) sin(th).*sin(ph) cos(th)];
r = zeros(n, 3);  wt = ones(n, 1);
P(:, 1, :) = reshape(r, n, 1, 3);  W(:, 1) = 1;
alive = true(n, 1);
for e = 1:maxev
    st = -log(rand(n, 1)) / w.c;
    r = r + u .* st;
    wt = wt * w.albedo;
    alive = alive & r(:, 3) > -1;
    P(alive, e + 1, :) = reshape(r(alive, :), [], 1, 3);
    W(alive, e + 1) = wt(alive);
    [a, b, c3] = rotate_dir(u(:, 1), u(:, 2), u(:, 3), hg_sample(opt.g, n), 2*pi*rand(n, 1));
    u = [a b c3];
end
T.P = P;  T.W = W;
end
