function A = pressure_to_altitude(P)
% System Constants
stdtemp = 15 + 273.15;
stdpres = 101325.0;
g = 9.80665;
R = 287.053;

% ISA Standard Atmosphere
heights = [0 11E3 20E3 32E3 47E3 51E3 71E3 84.852E3];
lapses = [-6.5E-3 0 1E-3 2.8E-3 0 -2.8E-3 -2.0E-3 0];
isotherms = [false true false false true false false true];

% Compute base temperature and pressures
dh = diff(heights);
dT = lapses(1:end-1) .* dh;
basetemps = cumsum([stdtemp dT]);
basepress = zeros(size(heights));
basepress(1) = stdpres;
for i = 1:length(heights)-1,
    if isotherms(i),
        basepress(i+1) = basepress(i) * exp(-dh(i) * g / basetemps(i) / R);
    else
        basepress(i+1) = basepress(i) * (basetemps(i+1)/basetemps(i)) ^ (-g/R/lapses(i));
    end
end

% Perform the conversion
A = P;
for i = 1:numel(A),
    for j = 1:length(heights),
        P0 = basepress(j);
        T0 = basetemps(j);
        if (j == 1) || (P(i) < P0),
            if isotherms(j),
                A(i) = R * T0 / g * log(P0 / P(i)) + heights(j);
            else
                A(i) = T0 / lapses(j) * ((P(i) / P0) ^ (-lapses(j) * R / g) - 1) + heights(j);
            end
        end
    end
end
