function w = water_types()
%WATER_TYPES  Absorption a, scattering b and extinction c = a + b (1/m) near 530 nm.
%   The four classic types measured by Petzold (1972) and tabulated by Mobley
%   (1994), as used across the UWOC literature (e.g. Cochenour 2008, Tang 2014).
w = struct('name', {'pure sea', 'clear ocean', 'coastal', 'turbid harbor'}, ...
           'a', {0.053, 0.114, 0.179, 0.366}, ...
           'b', {0.003, 0.037, 0.219, 1.824});
for k = 1:numel(w)
    w(k).c = w(k).a + w(k).b;
    w(k).albedo = w(k).b / w(k).c;
end
end
