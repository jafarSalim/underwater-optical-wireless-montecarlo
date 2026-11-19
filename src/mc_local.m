function E = mc_local(w, planes, opt)
%MC_LOCAL  Monte Carlo with a hybrid estimator that reaches very weak signals.
%   The received light is split by where each photon scattered for the last
%   time before the receiver, which makes three disjoint, unbiased parts:
%   * never scattered (ballistic): Beer-Lambert times the beam share on the
%     aperture, analytically;
%   * last scattered more than opt.dmin before the receiver plane: the local
%     (semi-analytic) estimate - at every such scattering event the photon
%     sends w * p_HG(cos theta) * dOmega * exp(-c d) toward the aperture;
%   * last scattered within opt.dmin of the plane: counted when the photon
%     actually crosses the aperture (the point-receiver formula breaks down
%     that close).
%   With 1e5 photons this resolves received powers of 1e-8 and below.
%   Output: E.P(k, f) received power fraction at plane k collected within a
%   field of view up to E.fov(f) degrees, and E.H(k, j) the power arriving
%   with excess path E.xedges(j) .. E.xedges(j+1) metres (all FOVs).
N = opt.N;  g = opt.g;  D = opt.D;
z = zeros(N, 1);  x = z;  y = z;  s = z;
th = abs(opt.div * randn(N, 1));  ph = 2*pi*rand(N, 1);
ux = sin(th) .* cos(ph);  uy = sin(th) .* sin(ph);  uz = cos(th);
wt = ones(N, 1);  zl = -ones(N, 1);  pid = (1:N).';
K = numel(planes);  got = false(N, K);  dmin = opt.dmin;
fov = 1:90;                                     % FOV bins (deg)
xedges = [0 logspace(-4, 2.5, 120)];            % excess path bins (m)
A = zeros(K, numel(fov));  H = zeros(K, numel(xedges));
zmax = max(planes);
while ~isempty(wt)
    step = -log(rand(numel(wt), 1)) / w.c;
    z1 = z + uz .* step;
    % photons that last scattered close to a plane and now cross it inside the aperture
    for k = 1:K
        L = planes(k);
        hit = z < L & z1 >= L & uz > 0 & zl >= L - dmin;
        if ~any(hit), continue; end
        f = (L - z(hit)) ./ uz(hit);
        r = sqrt((x(hit) + ux(hit) .* f).^2 + (y(hit) + uy(hit) .* f).^2);
        hi = find(hit);
        in = r <= D/2 & ~got(pid(hi), k);
        hi = hi(in);  f = f(in);
        if isempty(hi), continue; end
        got(pid(hi), k) = true;
        ang = min(max(ceil(acosd(uz(hi))), 1), 90);
        A(k, :) = A(k, :) + accumarray(ang, wt(hi), [90 1]).';
        ex = s(hi) + f - L;
        bin = min(max(sum(ex >= xedges, 2), 1), numel(xedges));
        H(k, :) = H(k, :) + accumarray(bin, wt(hi), [numel(xedges) 1]).';
    end
    x = x + ux .* step;  y = y + uy .* step;  z = z1;  s = s + step;
    alive = z > 0 & z < zmax & sqrt(x.^2 + y.^2) < opt.maxr;
    x = x(alive);  y = y(alive);  z = z(alive);  s = s(alive);  zl = zl(alive);  pid = pid(alive);
    ux = ux(alive);  uy = uy(alive);  uz = uz(alive);  wt = wt(alive);
    if isempty(wt), break; end
    wt = wt * w.albedo;                          % this scattering event
    zl = z;
    for k = 1:K
        L = planes(k);
        ahead = z < L - dmin;
        if ~any(ahead), continue; end
        dx = -x(ahead);  dy = -y(ahead);  dz = L - z(ahead);
        d = sqrt(dx.^2 + dy.^2 + dz.^2);
        mu = (ux(ahead) .* dx + uy(ahead) .* dy + uz(ahead) .* dz) ./ d;
        pf = (1 - g^2) ./ (4*pi * (1 + g^2 - 2*g*mu).^1.5);
        cth = dz ./ d;
        dOm = pi * (D/2)^2 * cth ./ d.^2;
        c = wt(ahead) .* pf .* dOm .* exp(-w.c * d);
        ang = min(max(ceil(acosd(cth)), 1), 90);
        A(k, :) = A(k, :) + accumarray(ang, c, [90 1]).';
        ex = s(ahead) + d - L;
        bin = min(max(sum(ex >= xedges, 2), 1), numel(xedges));
        H(k, :) = H(k, :) + accumarray(bin, c, [numel(xedges) 1]).';
    end
    mu = hg_sample(g, numel(wt));
    [ux, uy, uz] = rotate_dir(ux, uy, uz, mu, 2*pi*rand(numel(wt), 1));
    low = wt < opt.wmin;
    surv = rand(numel(wt), 1) < 0.1;
    wt(low & surv) = wt(low & surv) * 10;
    keep = ~(low & ~surv);
    x = x(keep);  y = y(keep);  z = z(keep);  s = s(keep);  zl = zl(keep);  pid = pid(keep);
    ux = ux(keep);  uy = uy(keep);  uz = uz(keep);  wt = wt(keep);
end
A = A / N;  H = H / N;
% ballistic light: Beer-Lambert times the share of the Gaussian beam on the aperture
bal = exp(-w.c * planes) .* erf((D/2) ./ (sqrt(2) * opt.div * planes));
E.P = cumsum(A, 2) + bal(:);                     % ballistic arrives within 1 deg
E.scat = cumsum(A, 2);  E.bal = bal(:);
H(:, 1) = H(:, 1) + bal(:);
E.H = H;  E.fov = fov;  E.xedges = xedges;  E.planes = planes;  E.N = N;
end
