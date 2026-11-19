function mu = hg_sample(g, n)
%HG_SAMPLE  Cosines of scattering angles from the Henyey-Greenstein phase function.
u = rand(n, 1);
if abs(g) < 1e-6
    mu = 2*u - 1;
else
    mu = (1 + g^2 - ((1 - g^2) ./ (1 - g + 2*g*u)).^2) / (2*g);
end
mu = min(max(mu, -1), 1);
end
