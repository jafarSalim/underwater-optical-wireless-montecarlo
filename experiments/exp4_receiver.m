function r = exp4_receiver(r2)
%EXP4_RECEIVER  Field of view and aperture: how much scattered light a receiver can catch.
c = palette();  [opt, W, planes] = sim_cfg();
rand('seed', 14);  randn('seed', 14);
cases = {3, 30; 4, 8};
Ds = [0.01 0.025 0.05 0.1 0.2];
h = new_figure(1600, 600);
ax1 = subplot(1, 2, 1);  hold on;
for j = 1:2
    k = cases{j, 1};  i = find(planes{k} == cases{j, 2});
    E = r2.E{k};
    plot(E.fov, 10*log10(E.P(i, :)), '-', 'color', c.water{k}, 'linewidth', 3);
end
xlabel('receiver field of view (half angle, deg)');  ylabel('received power (dB)');
title('5 cm aperture: wider FOV catches scattered light');
style_axes(ax1, c);
dark_legend(ax1, {sprintf('coastal, %d m', cases{1, 2}), sprintf('turbid harbor, %d m', cases{2, 2})}, 'southeast');
G = zeros(2, numel(Ds));
for j = 1:2
    k = cases{j, 1};
    for q = 1:numel(Ds)
        o = opt;  o.D = Ds(q);  o.N = [0 0 4e5 8e5];  o.N = o.N(k);
        E = mc_batches(W(k), cases{j, 2}, o, 4);
        G(j, q) = E.P(1, 90);
    end
end
ax2 = subplot(1, 2, 2);  hold on;
for j = 1:2
    k = cases{j, 1};
    plot(100 * Ds, 10*log10(G(j, :)), 'o-', 'color', c.water{k}, 'markerfacecolor', c.water{k}, 'linewidth', 2.4);
end
plot(100 * Ds, 10*log10(G(2, 3)) + 20*log10(Ds / 0.05), ':', 'color', c.muted, 'linewidth', 1.5);
set(ax2, 'xscale', 'log');
xlabel('aperture diameter (cm)');  ylabel('received power (dB), FOV 90 deg');
title('Bigger lens: +6 dB per doubling once the light is diffuse');
style_axes(ax2, c);
dark_legend(ax2, {'coastal, 30 m', 'turbid harbor, 8 m', 'area law (D^2)'}, 'southeast');
save_figure(h, 'fig4_receiver');
write_csv('exp4_aperture', 'D_m,coastal30_dB,harbor8_dB', [Ds.' 10*log10(G.')]);
r.G = G;  r.Ds = Ds;
end
