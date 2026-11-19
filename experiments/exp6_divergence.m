function r = exp6_divergence()
%EXP6_DIVERGENCE  Laser or LED: beam divergence vs received power (5 cm lens, FOV 90 deg).
c = palette();  [opt, W] = sim_cfg();
rand('seed', 16);  randn('seed', 16);
divs = [1e-3 1e-2 0.1 0.35];                       % rad: tight laser ... wide LED (20 deg)
labs = {'laser, 1 mrad', 'laser, 10 mrad', 'diffused, 6 deg', 'LED, 20 deg'};
set1 = {2, [10 20 30 40 50 60 80 100]; 3, [5 10 15 20 25 30 40 50]};
h = new_figure(1600, 600);
P = cell(2, 1);
for j = 1:2
    k = set1{j, 1};  L = set1{j, 2};
    ax = subplot(1, 2, j);  hold on;
    P{j} = zeros(numel(divs), numel(L));
    cols = {c.laser, c.water{2}, c.water{3}, c.pink};
    for q = 1:numel(divs)
        o = opt;  o.div = divs(q);  o.N = 8e5;
        E = mc_batches(W(k), L, o, 4);
        P{j}(q, :) = E.P(:, 90).';
        plot(L, 10*log10(P{j}(q, :)), 'o-', 'color', cols{q}, 'markerfacecolor', cols{q}, 'linewidth', 2.2);
    end
    xlabel('link distance (m)');  ylabel('received power (dB)');
    title(sprintf('%s', W(k).name));
    style_axes(ax, c);
    dark_legend(ax, labs, 'northeast');
end
save_figure(h, 'fig6_divergence');
write_csv('exp6_divergence_clear', ['div_rad,' sprintf('L%d_dB,', set1{1, 2})], [divs.' 10*log10(P{1})]);
write_csv('exp6_divergence_coastal', ['div_rad,' sprintf('L%d_dB,', set1{2, 2})], [divs.' 10*log10(P{2})]);
r.P = P;
end
