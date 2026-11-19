function r = exp1_paths()
%EXP1_PATHS  What the photons do: trajectories over a 10 m link in three water types.
c = palette();  [opt, W] = sim_cfg();
rand('seed', 11);  randn('seed', 11);
h = new_figure(1800, 560);
show = [2 3 4];
for j = 1:3
    w = W(show(j));
    T = mc_tracks(w, 250, opt, 40);
    ax = subplot(1, 3, j);  hold on;
    for i = 1:size(T.P, 1)
        z = squeeze(T.P(i, :, 3));  x = squeeze(T.P(i, :, 1));
        ok = ~isnan(z);
        z = z(ok);  x = x(ok);
        % stop drawing at 10 m
        cut = find(z > 10, 1);
        if ~isempty(cut), z = z(1:cut);  x = x(1:cut); end
        wv = T.W(i, ok);  a = max(min(wv(min(numel(z), end))^0.3, 1), 0.2);
        plot(z, x, '-', 'color', c.water{show(j)} * a + c.panel * (1 - a), 'linewidth', 0.9);
    end
    plot([10 10], [-0.025 0.025], '-', 'color', c.white, 'linewidth', 6);
    xlim([0 10.5]);  ylim([-2 2]);
    xlabel('distance along the link (m)');  ylabel('sideways (m)');
    title({sprintf('%s', w.name), sprintf('c = %.3f /m, albedo %.2f, %.1f scatterings per 10 m', w.c, w.albedo, w.b * 10)});
    style_axes(ax, c);
end
save_figure(h, 'fig1_photon_paths');
r = struct();
end
