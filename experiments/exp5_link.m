function r = exp5_link(r2, r3)
%EXP5_LINK  Bit error rate and reach of an OOK link: 1 W laser at 520 nm, PIN or APD.
%   Received power from the Monte Carlo curves (FOV 90 deg, 5 cm lens),
%   interpolated in dB over distance. Pulse spreading is counted as a power
%   penalty: only the energy arriving within one bit is useful.
c = palette();  [~, W, planes] = sim_cfg();
Pt = 1.0;
rxs = struct('name', {'PIN', 'APD'}, 'R', {0.3, 0.3}, 'M', {1, 30}, 'F', {1, 5.5}, 'in', {2e-12, 2e-12});
rates = [10e6 100e6 1e9];
v = 299792458 / 1.34;
reach = zeros(4, numel(rates), 2);
h = new_figure(1600, 620);
ax1 = subplot(1, 2, 1);  hold on;
Lfine = cell(1, 4);
for k = 1:4
    L = planes{k};
    E = r2.E{k};
    Lf = linspace(L(1), L(end), 400);
    Pf = 10.^(interp1(L, 10*log10(E.P(:, 90)).', Lf, 'pchip') / 10) * Pt;
    Lfine{k} = Lf;
    for q = 1:numel(rates)
        % share of the impulse response inside one bit, per simulated distance
        Tb = 1 / rates(q);  frac = zeros(size(L));
        for i = 1:numel(L)
            t = E.xedges / v;  frac(i) = sum(E.H(i, t <= Tb)) / sum(E.H(i, :));
        end
        fr = interp1(L, frac, Lf, 'pchip');
        for x = 1:2
            ber = ber_ook(Pf .* fr, rates(q), rxs(x));
            j = find(ber > 1e-6, 1);
            if isempty(j), reach(k, q, x) = Lf(end); elseif j == 1, reach(k, q, x) = 0; else, reach(k, q, x) = Lf(j - 1); end
            if q == 2
                if x == 1, ls = '--'; else, ls = '-'; end
                semilogy(Lf, max(ber, 1e-12), ls, 'color', c.water{k}, 'linewidth', 2.2);
            end
        end
    end
end
set(ax1, 'xscale', 'log');  ylim([1e-12 1]);  xlim([1 420]);
plot([1 420], [1e-6 1e-6], ':', 'color', c.muted);
xlabel('link distance (m)');  ylabel('bit error rate');
title('100 Mb/s OOK, 1 W: APD (solid) vs PIN (dashed)');
style_axes(ax1, c);
ax2 = subplot(1, 2, 2);
Y = [reach(:, 1, 2) reach(:, 2, 2) reach(:, 3, 2)];
b = bar(ax2, Y);
cols = {[0.35 0.85 1.00], [0.10 0.95 0.75], [1.00 0.40 0.80]};
for q = 1:3, set(b(q), 'facecolor', cols{q}); end
set(ax2, 'xticklabel', {W.name}, 'yscale', 'log');
ylabel('reach for BER 10^{-6} (m), APD');
title('How far, how fast');
style_axes(ax2, c);
dark_legend(ax2, {'10 Mb/s', '100 Mb/s', '1 Gb/s'}, 'northeast');
for k = 1:4
    for q = 1:3
        text(k + (q - 2) * 0.27 - 0.12, Y(k, q) * 1.25, sprintf('%.0f', Y(k, q)), 'color', c.fg, 'fontsize', 9);
    end
end
save_figure(h, 'fig5_ber_reach');
write_csv('exp5_reach_apd', 'water,reach_10Mbps_m,reach_100Mbps_m,reach_1Gbps_m', [(1:4).' squeeze(reach(:, :, 2))]);
write_csv('exp5_reach_pin', 'water,reach_10Mbps_m,reach_100Mbps_m,reach_1Gbps_m', [(1:4).' squeeze(reach(:, :, 1))]);
r.reach = reach;
end
