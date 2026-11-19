%MAIN  Runs every UWOC experiment and writes figures/ and results/.
%   Works in MATLAB (R2016b or newer, no toolboxes) and GNU Octave (6 or newer).
clear; close all;
here = fileparts(mfilename('fullpath'));
if isempty(here), here = pwd; end
addpath(fullfile(here, 'src'), fullfile(here, 'experiments'));
t0 = tic;
r1 = exp1_paths();
r2 = exp2_power();
r3 = exp3_cir(r2);
r4 = exp4_receiver(r2);
r5 = exp5_link(r2, r3);
r6 = exp6_divergence();
make_frames();
W = water_types();
fid = fopen(fullfile(here, 'results', 'summary.txt'), 'w');
fprintf(fid, 'Power [water L cL P90 P20 ballistic BeerLambert] dB:\n%s\n', mat2str(r2.rows, 4));
fprintf(fid, 'CIR [water L mean_ns rms_ns ballistic%%]:\n%s\n', mat2str(r3.rows, 3));
fprintf(fid, 'Aperture %s m -> coastal30 %s dB, harbor8 %s dB\n', mat2str(r4.Ds), mat2str(10*log10(r4.G(1,:)), 3), mat2str(10*log10(r4.G(2,:)), 3));
for x = 1:2
    fprintf(fid, 'Reach BER 1e-6 (%s) [10M 100M 1G] m:\n%s\n', ternary(x == 1, 'PIN', 'APD'), mat2str(r5.reach(:, :, x), 3));
end
fprintf(fid, 'Run time: %.0f s\n', toc(t0));
fclose(fid);
type(fullfile(here, 'results', 'summary.txt'));
