function d = make_frames()
%MAKE_FRAMES  Frames for assets/photons.gif: 3000 photons leave a laser in coastal
%   water; snapshots every 1.2 m of travel, side view, colour = remaining weight.
c = palette();  [opt, W] = sim_cfg();
rand('seed', 21);  randn('seed', 21);
d = fullfile(tempdir, 'uwoc_frames');
if ~exist(d, 'dir'), mkdir(d); end
old = dir(fullfile(d, '*.png'));
for k = 1:numel(old), delete(fullfile(d, old(k).name)); end
w = W(3);  n = 3000;
T = mc_tracks(w, n, opt, 80);
% cumulative path length per event
P = T.P;  seg = sqrt(sum(diff(P, 1, 2).^2, 3));  cum = [zeros(n, 1) cumsum(seg, 2)];
nf = 40;  sk = linspace(0.3, 24, nf);
for f = 1:nf
    pos = nan(n, 3);  wt = nan(n, 1);
    for i = 1:n
        j = find(cum(i, :) >= sk(f), 1);
        if isempty(j) || j == 1 || isnan(cum(i, j)), continue; end
        a = (sk(f) - cum(i, j-1)) / max(cum(i, j) - cum(i, j-1), eps);
        pos(i, :) = squeeze(P(i, j-1, :)).' + a * (squeeze(P(i, j, :)).' - squeeze(P(i, j-1, :)).');
        wt(i) = T.W(i, j-1);
    end
    h = figure('visible', 'off', 'position', [0 0 1100 420], 'color', c.bg);
    ax = axes('position', [0.05 0.14 0.92 0.74]);  hold on;
    ok = ~isnan(wt);
    scatter(pos(ok, 3), pos(ok, 1), 6, log10(max(wt(ok), 1e-4)), 'filled');
    colormap(ax, c.map);  caxis([-2.5 0]);
    plot([0 0], [-0.1 0.1], '-', 'color', c.laser, 'linewidth', 6);
    plot([20 20], [-0.025 0.025], '-', 'color', c.white, 'linewidth', 6);
    text(20.3, 0.6, 'receiver at 20 m', 'color', c.fg, 'fontsize', 11);
    xlim([-0.5 25]);  ylim([-3 3]);
    xlabel('distance (m)');  ylabel('sideways (m)');
    title(sprintf('coastal water: photons after %.1f m of travel (%.0f ns)', sk(f), sk(f) / (299792458/1.34) * 1e9), 'color', c.fg);
    style_axes(ax, c);
    set(h, 'inverthardcopy', 'off', 'PaperPositionMode', 'auto');
    print(h, fullfile(d, sprintf('f%03d.png', f)), '-dpng', '-r90');
    close(h);
end
end
