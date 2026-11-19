function r = exp3_cir(r2)
%EXP3_CIR  Channel impulse responses: how much scattering stretches a pulse.
c = palette();  [~, W, planes] = sim_cfg();
v = 299792458 / 1.34;                         % speed of light in sea water
pick = {3, [20 30 40]; 4, [4 8 12]};
h = new_figure(1600, 600);
rows = [];
for j = 1:2
    k = pick{j, 1};  E = r2.E{k};
    ax = subplot(1, 2, j);  hold on;
    sty = {'-', '--', ':'};
    for q = 1:3
        i = find(planes{k} == pick{j, 2}(q));
        e = E.xedges;  hh = E.H(i, :);
        t = [0 e(2:end)] / v * 1e9;            % ns
        dt = [diff(t) t(end) - t(end-1)];
        pdf = hh / sum(hh);
        tc = [0 0.5 * (t(2:end-1) + t(3:end)) t(end)];
        % RMS delay spread
        mu = sum(pdf .* tc);  rms = sqrt(sum(pdf .* (tc - mu).^2));
        ok = hh > 0 & tc > 0;
        stairs(tc(ok), hh(ok) ./ dt(ok) / sum(hh), sty{q}, 'color', c.water{k}, 'linewidth', 2.2);
        rows = [rows; k planes{k}(i) mu rms 100 * hh(1) / sum(hh)];
    end
    set(ax, 'xscale', 'log', 'yscale', 'log');
    xlim([1e-3 300]);
    xlabel('delay after the straight-line arrival (ns)');  ylabel('power density (1/ns)');
    title(sprintf('%s', W(k).name));
    style_axes(ax, c);
    labs = arrayfun(@(L) sprintf('%d m: rms %.2f ns, %.0f %% ballistic', L, rows(end-3+find(pick{j,2}==L), 4), rows(end-3+find(pick{j,2}==L), 5)), pick{j, 2}, 'uniformoutput', false);
    dark_legend(ax, labs, 'northeast');
end
save_figure(h, 'fig3_impulse_response');
write_csv('exp3_cir', 'water,L_m,mean_delay_ns,rms_delay_ns,ballistic_percent', rows);
r.rows = rows;
end
