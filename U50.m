% Clear environment variables
clear;

% Define parameters
Um = 72.5; % Maximum equipment voltage, unit: kV (r.m.s. value)
k = 1.45; % Design coefficient from Table 3
rms_to_peak_factor = sqrt(2); % Factor to convert rms value to peak

% Convert Um to peak voltage
Um_peak = Um * rms_to_peak_factor; % Unit: kV

% Define calculation formulas for different voltages
% Dielectric strength of AC voltage (peak)
U50_ac = @(d) (3740 * k) / (1 + 8 / d);

% Dielectric strength of lightning impulse voltage
U50_lightning = @(d) (380 + 150 * k) * d;

% Dielectric strength of switching impulse voltage
U50_switching = @(d) (3400 * k) / (1 + 8 / d);

% Define target voltage (kV, peak), should match or slightly exceed Um_peak
target_voltage_ac = Um_peak; % Corresponding peak voltage
target_voltage_lightning = 325; % Lightning impulse voltage
target_voltage_switching = 325; % Switching impulse voltage

% Calculate the minimum gap d that meets the requirements (unit: meters)
options = optimset('Display','off'); % Turn off display
d_ac = fsolve(@(d) U50_ac(d) - target_voltage_ac, 1, options);
d_lightning = fsolve(@(d) U50_lightning(d) - target_voltage_lightning, 1, options);
d_switching = fsolve(@(d) U50_switching(d) - target_voltage_switching, 1, options);

% Display results
fprintf('Air gap calculation results for %0.1f kV (r.m.s.):\n', Um);
fprintf('Minimum gap required for AC voltage d_ac: %.2f m\n', d_ac);
fprintf('Minimum gap required for lightning impulse voltage d_lightning: %.2f m\n', d_lightning);
fprintf('Minimum gap required for switching impulse voltage d_switching: %.2f m\n', d_switching);
