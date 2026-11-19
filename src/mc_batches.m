function E = mc_batches(w, planes, opt, B)
%MC_BATCHES  Run MC_LOCAL in B independent batches of opt.N/B photons and average.
%   Adds E.Pse: standard error of the received power (all FOVs) per plane,
%   from the spread between batches, so every curve can carry a 95 % CI.
o = opt;  o.N = round(opt.N / B);
for b = 1:B
    e = mc_local(w, planes, o);
    if b == 1
        E = e;  Ps = zeros(numel(planes), B);
    else
        E.P = E.P + e.P;  E.H = E.H + e.H;  E.scat = E.scat + e.scat;
    end
    Ps(:, b) = e.P(:, end);
end
E.P = E.P / B;  E.H = E.H / B;  E.scat = E.scat / B;
E.N = o.N * B;
E.Pse = std(Ps, 0, 2) / sqrt(B);
E.Pbatch = Ps;
end
