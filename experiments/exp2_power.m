function r = exp2_power()
%EXP2_POWER  Received power vs distance: Monte Carlo against Beer-Lambert.
c = palette();  [opt, W, planes] = sim_cfg();
rand('seed', 12);  randn('seed', 12);
h = new_figure(1600, 620);
ax1 = subplot(1, 2, 1);  hold on;  ax2 = subplot(1, 2, 2);  hold on;
r.E = cell(1, 4);  rows = [];
for k = 1:4
    o = opt;  o.N = [6e5 6e5 1.2e6 2.4e6];  o.N = o.N(k);   % more photons where scattering dominates
    tic;  E = mc_batches(W(k), planes{k}, o, 8);  tt = toc;
    r.E{k} = E;
    Pall = E.P(:, 90);  P20 = E.P(:, 20);
    bl = exp(-W(k).c * planes{k}).';
    blg = E.bal;
    axes(ax1);
    hl(k) = plot(planes{k}, 10*log10(Pall), 'o-', 'color', c.water{k}, 'markerfacecolor', c.water{k}, 'linewidth', 2.4);
    lo = 10*log10(max(Pall - 1.96*E.Pse, Pall * 1e-3));  hi = 10*log10(Pall + 1.96*E.Pse);
    for i = 1:numel(planes{k}), plot([planes{k}(i) planes{k}(i)], [lo(i) hi(i)], '-', 'color', c.water{k}, 'linewidth', 1.5); end
    plot(planes{k}, 10*log10(bl), ':', 'color', c.water{k}, 'linewidth', 1.4);
    axes(ax2);
    plot(W(k).c * planes{k}, 10*log10(Pall ./ blg), 'o-', 'color', c.water{k}, 'markerfacecolor', c.water{k}, 'linewidth', 2.4);
    rows = [rows; k * ones(numel(planes{k}), 1), planes{k}.', W(k).c * planes{k}.', 10*log10(Pall), 10*log10(P20), 10*log10(blg), 10*log10(bl), 10*log10(1 + 1.96*E.Pse ./ Pall)];
    printf('  %s: %.0f s\n', W(k).name, tt);
end
axes(ax1);  set(ax1, 'xscale', 'log');  xlim([1 420]);  ylim([-130 0]);
xlabel('link distance (m)');  ylabel('received / transmitted power (dB)');
title('Monte Carlo (o, 95 % CI) vs Beer-Lambert e^{-cL} (dotted); 5 cm lens');
style_axes(ax1, c);
lg = legend(hl, {W.name}, 'location', 'southwest');
set(lg, 'color', c.bg, 'textcolor', c.fg, 'edgecolor', c.grid);
axes(ax2);
xlabel('attenuation length cL');  ylabel('gain from scattered light (dB)');
title('Scattered light rescues long, murky links');
set(ax2, 'yscale', 'linear');
style_axes(ax2, c);
dark_legend(ax2, {W.name}, 'northwest');
save_figure(h, 'fig2_power_vs_distance');
write_csv('exp2_power', 'water,L_m,cL,P_fov90_dB,P_fov20_dB,ballistic_on_aperture_dB,beer_lambert_dB,ci95_upper_dB', rows);
r.rows = rows;
end
