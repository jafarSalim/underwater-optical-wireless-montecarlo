function X = mc_photons(w, planes, opt)
%MC_PHOTONS  Monte Carlo photon transport from a source at z = 0 along +z.
%   w: one water type (a, b, c). planes: receiver distances (m).
%   opt.N (photons), opt.div (source half-angle, rad, Gaussian), opt.g (HG asymmetry),
%   opt.wmin (weight cut-off), opt.maxr (lateral escape radius, m).
%   Weights: the free path is drawn with the extinction c and the weight is
%   multiplied by the albedo b/c at every scattering (absorption as weight loss).
%   Returns every forward crossing of every plane: X.k (plane index), X.r
%   (radius, m), X.cth (cos of the angle to the axis), X.w (weight), X.t
%   (path length, m), X.id (photon), in the order they happen.
N = opt.N;
z = zeros(N, 1);  x = z;  y = z;  s = z;
th = abs(opt.div * randn(N, 1));  ph = 2*pi*rand(N, 1);
ux = sin(th) .* cos(ph);  uy = sin(th) .* sin(ph);  uz = cos(th);
wt = ones(N, 1);  id = (1:N).';
K = numel(planes);  cap = 4 * N * K;
Xk = zeros(cap, 1, 'uint8');  Xr = zeros(cap, 1, 'single');  Xc = Xr;  Xw = Xr;  Xt = Xr;  Xi = zeros(cap, 1, 'uint32');
nrec = 0;
zmax = max(planes);
while ~isempty(id)
    step = -log(rand(numel(id), 1)) / w.c;
    z1 = z + uz .* step;
    % planes crossed going forward in this step
    for k = 1:K
        L = planes(k);
        hit = z < L & z1 >= L & uz > 0;
        if any(hit)
            f = (L - z(hit)) ./ uz(hit);
            xx = x(hit) + ux(hit) .* f;  yy = y(hit) + uy(hit) .* f;
            m = nnz(hit);
            if nrec + m > cap   % grow
                Xk = [Xk; zeros(cap, 1, 'uint8')];  Xr = [Xr; zeros(cap, 1, 'single')];
                Xc = [Xc; zeros(cap, 1, 'single')];  Xw = [Xw; zeros(cap, 1, 'single')];
                Xt = [Xt; zeros(cap, 1, 'single')];  Xi = [Xi; zeros(cap, 1, 'uint32')];  cap = 2 * cap;
            end
            j = nrec + (1:m);
            Xk(j) = k;  Xr(j) = sqrt(xx.^2 + yy.^2);  Xc(j) = uz(hit);  Xw(j) = wt(hit);
            Xt(j) = s(hit) + f;  Xi(j) = id(hit);
            nrec = nrec + m;
        end
    end
    x = x + ux .* step;  y = y + uy .* step;  z = z1;  s = s + step;
    % scatter
    wt = wt * w.albedo;
    mu = hg_sample(opt.g, numel(id));
    [ux, uy, uz] = rotate_dir(ux, uy, uz, mu, 2*pi*rand(numel(id), 1));
    % kill: weight too low (Russian roulette), behind the source, too far sideways or beyond the last plane
    alive = z > 0 & sqrt(x.^2 + y.^2) < opt.maxr & z < zmax + 5 / w.c;
    low = wt < opt.wmin;
    surv = rand(numel(id), 1) < 0.1;
    wt(low & surv) = wt(low & surv) * 10;
    alive = alive & ~(low & ~surv);
    x = x(alive);  y = y(alive);  z = z(alive);  s = s(alive);
    ux = ux(alive);  uy = uy(alive);  uz = uz(alive);  wt = wt(alive);  id = id(alive);
end
X.k = Xk(1:nrec);  X.r = Xr(1:nrec);  X.cth = Xc(1:nrec);  X.w = Xw(1:nrec);
X.t = Xt(1:nrec);  X.id = Xi(1:nrec);  X.N = N;  X.planes = planes;
end
