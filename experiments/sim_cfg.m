function [opt, W, planes] = sim_cfg()
%SIM_CFG  Common Monte Carlo settings and the distances simulated per water type.
opt = struct('N', 2e5, 'div', 1e-3, 'g', 0.924, 'wmin', 1e-4, 'maxr', 60, 'D', 0.05, 'dmin', 0.5);
W = water_types();
planes = {[25 50 100 150 200 250 300 400], [10 25 50 75 100 125 150 200], ...
          [5 10 20 30 40 50 60 70], [1 2 4 6 8 10 12 14 16]};
end
