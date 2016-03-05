function bmp280(filename)
TBL = readtable(filename);
feet_per_meter = 3.28084;
fl_per_meter = feet_per_meter / 100;
% Type conversions
TBL.TIMESTAMP = isodatenum(TBL.TIMESTAMP);
% Extract values
t = TBL.TIMESTAMP - TBL.TIMESTAMP(1);
P = TBL.PRES;
X = TBL.gxpr_bridge_barometric_pressure_raw;
FL = pressure_to_altitude(P * 1E3) * fl_per_meter;
T = TBL.gxpr_bridge_barometer_temperature;
U = TBL.UNCERT;
% Utility functions
Ax = [ -1 0 0.5 1 1.5 2 3 4 6 8 10 12 14 16 18 20 22 25 30 35 40 45 50]' * 10;
Px = altitude_to_pressure(Ax / fl_per_meter) / 1E3;
EAx = [ 20 20 20 20 25 30 30 35 40 60 80 90 100 110 120 130 140 155 180 205 230 255 280]' / 100;
EUPx = altitude_to_pressure((Ax - EAx) / fl_per_meter) / 1E3 - Px;
ELPx = altitude_to_pressure((Ax + EAx) / fl_per_meter) / 1E3 - Px;
% Recenter raw ADC values
MX = mean(X);
SX = std(X);
X1 = (X - MX) / SX;
% Perform fits
%   Custom Calibration
X4 = [ones(size(P)) X1 X1.^2 X1.^3 T T.^2 X1.*T];
FIT4 = X4 \ (1E3 * P);
P4 = single(X4) * single(FIT4) / 1E3;
FL4 = pressure_to_altitude(P4 * 1E3) * fl_per_meter;
% Display results
rows = 3;
cols = 2;
subplot(rows, cols, 1);
    semilogy(24*t, P);
    xlabel('Time Since Start (Hours)');
    ylabel('Pressure (kPa)');
subplot(rows, cols, 3);
    plot(24 * t, T);
    xlabel('Time Since Start (Hours)');
    ylabel('Temperature (K)'); 
subplot(rows, cols, [2 4]);
    semilogx(P, P4-P, ...
        [P;NaN;P], [U;NaN;-U], ...
        [Px;NaN;Px], [EUPx;NaN;ELPx]);
    axis([10 100 -0.3 0.3]);
    xlabel('Pressure (kPa)');
    ylabel('Error (kPa)');
    legend('Custom Fit', ...
        'PPC4 Uncertainty', 'Tolerable Limits', ...
        'Location', 'SouthWest');
subplot(rows, cols, [5 6]);
    plot(FL, FL4-FL, ...
        [Ax;NaN;Ax], [+EAx;NaN;-EAx]);
    axis([0 500 -3 +3]);
    xlabel('Flight Level');
    ylabel('Error (FL)');
    legend('Custom Fit', ...
        'Tolerable Limits', 'Location', 'SouthWest');

fprintf(1, 'test altcoeffs_set 0 %0.8e\n', MX);
fprintf(1, 'test altcoeffs_set 1 %0.8e\n', SX);
for i = 1:numel(FIT4),
    fprintf(1, 'test altcoeffs_set %d %0.8e\n', i + 1, FIT4(i));
end
fprintf(1, 'test altcoeffs_store\n');
end
