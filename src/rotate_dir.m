function [ux, uy, uz] = rotate_dir(ux, uy, uz, mu, phi)
%ROTATE_DIR  New direction after scattering by polar cosine mu and azimuth phi
%   (standard MCML update, vectorised).
st = sqrt(max(1 - mu.^2, 0));
cp = cos(phi);  sp = sin(phi);
den = sqrt(max(1 - uz.^2, 0));
small = den < 1e-6;
nx = st .* (ux .* uz .* cp - uy .* sp) ./ max(den, 1e-12) + ux .* mu;
ny = st .* (uy .* uz .* cp + ux .* sp) ./ max(den, 1e-12) + uy .* mu;
nz = -st .* cp .* den + uz .* mu;
nx(small) = st(small) .* cp(small);
ny(small) = st(small) .* sp(small);
nz(small) = sign(uz(small)) .* mu(small);
n = sqrt(nx.^2 + ny.^2 + nz.^2);
ux = nx ./ n;  uy = ny ./ n;  uz = nz ./ n;
end
