clear;
% Define the conductor data table
conductor_data = table( ...
    {'Oak', 'Poplar', 'Upas', 'Rubus', 'Gopher', 'Horse', 'Lynx', 'Moose'}', ...
    [14.0, 20.1, 24.7, 31.5, 7.08, 14.0, 19.5, 31.8]', ... % Conductor diameter, unit: mm
    [324.5, 659.4, 997.5, 1622, 106.2, 537.3, 834, 1997.3]', ... % Conductor weight, unit: kg/km
    [35.07, 70.61, 106.82, 173.53, 9.58, 61.26, 79.97, 159.92]', ... % Rated strength, unit: kN
    [23.0e-6, 23.0e-6, 23.0e-6, 23.0e-6, 19.1e-6, 15.3e-6, 17.8e-6, 19.3e-6]', ... % Linear expansion coefficient
    [0.2768, 0.1390, 0.0921, 0.0574, 1.300, 0.3230, 0.1532, 0.0560]', ... % Resistance at 20°C, unit: Ω/km
    [0.3316, 0.1665, 0.1104, 0.0688, 1.6945, 0.5425, 0.1873, 0.0684]', ... % Resistance at 75°C, unit: Ω/km
    'VariableNames', {'Name', 'Diameter_mm', 'Weight_kg_per_km', 'Rated_Strength_kN', ...
                      'Linear_Expansion_Coefficient', 'R20_Ohm_per_km', 'R75_Ohm_per_km'});

% Select the conductor
selected_conductor = 'Horse'; % Can be changed to 'Oak', 'Poplar', 'Upas', 'Rubus', 'Gopher', 'Horse', 'Lynx', 'Moose'

% Extract parameters of the selected conductor
conductor = conductor_data(strcmp(conductor_data.Name, selected_conductor), :);

% Define other constants
V_line = 66e3; % Line voltage, unit: V (66 kV)
T1 = 75; % Reference temperature T1, unit: °C
T2 = 20; % Reference temperature T2, unit: °C
Tc = 110; % Maximum operating temperature, unit: °C
T_install = 5; % Installation temperature, unit: °C
line_length_km = 50; % Total span, unit: km
line_length_m = line_length_km * 1000; % Convert km to m
R_s = 180; % Horizontal span, unit: m
wind_speed = 14.6; % Wind speed, unit: m/s

% Conductor weight and tension-related data
g = 9.81; % Gravitational acceleration, unit: m/s^2
tension_ratio = 0.22; % Tension ratio, 22%

% Heat loss and gain data
q_c = 36.30; % Convective heat loss, unit: W/m
q_r = 15.40; % Radiative heat loss, unit: W/m
q_s = 11.30; % Solar radiation gain, unit: W/m

% Calculate weight per unit length (N/m)
W_per_m = conductor.Weight_kg_per_km / 1000; % Convert kg/km to kg/m
W = W_per_m * g; % Convert to weight force per meter (unit: N/m)

% Calculate tension
T = tension_ratio * conductor.Rated_Strength_kN * 1e3; % Convert kN to N

% Calculate resistance R_Tc at 110°C
R_75 = conductor.R75_Ohm_per_km / 1000; % Convert resistance at 75°C to per meter unit (Ω/m)
R_20 = conductor.R20_Ohm_per_km / 1000; % Convert resistance at 20°C to per meter unit (Ω/m)
R_Tc = ((R_75 - R_20) / (T1 - T2)) * (Tc - T1) + R_75; % Resistance at 110°C (Ω/m)

% Calculate maximum allowable current I_max
I_max = sqrt((q_c + q_r - q_s) / R_Tc); % Maximum allowable current, unit: A

% Calculate maximum single-circuit transmission capacity (unit: VA) and convert to MVA
P_rated_single_VA = sqrt(3) * V_line * I_max; % Single-circuit maximum transmission capacity, unit: VA
P_rated_single_MVA = P_rated_single_VA / 1e6; % Single-circuit maximum transmission capacity, unit: MVA

% Calculate maximum double-circuit transmission capacity
P_rated_double_MVA = 2 * P_rated_single_MVA; % Double-circuit maximum transmission capacity, unit: MVA

% Calculate total impedance R_total of the line
R_total = R_Tc * line_length_m; % Total impedance of the line, unit: Ω

% Calculate total voltage drop ΔV using total impedance and maximum current
Delta_V = R_total * I_max; % Total voltage drop, unit: V

% Calculate effective voltage at the receiving end
V_effective = V_line - Delta_V; % Effective voltage at the receiving end considering total voltage drop

% Calculate final transmission capacity based on effective voltage
P_effective_single_VA = sqrt(3) * V_effective * I_max; % Effective single-circuit transmission capacity, unit: VA
P_effective_single_MVA = P_effective_single_VA / 1e6; % Convert to MVA
P_effective_double_MVA = 2 * P_effective_single_MVA; % Effective double-circuit transmission capacity

% Calculate wind load (F_c)
rho = 1.22; % Air density, unit: kg/m^3
diameter_m = conductor.Diameter_mm / 1000; % Convert conductor diameter to meters
F_c = 0.5 * rho * wind_speed^2 * diameter_m * R_s; % Wind load on the conductor, unit: N

% Calculate swing angle (phi)
W_c = W * R_s; % Total weight of the conductor, unit: N
phi = atan(F_c / W_c); % Swing angle, unit: radians
phi_deg = rad2deg(phi); % Convert to degrees

% Calculate elastic sag at normal temperature (S_Tc)
S_Tc = (W * R_s^2) / (8 * T); % Sag of the conductor at normal temperature, unit: m

% Calculate conductor length at installation temperature (lambda_c)
lambda_c = R_s + (W^2 * R_s^3) / (24 * T^2); % Initial conductor length, unit: m

% Calculate conductor length increase due to thermal expansion (lambda_thermal) - Installation temperature 5°C
lambda_thermal = conductor.Linear_Expansion_Coefficient * (Tc - T_install) * lambda_c; % Change in conductor length due to thermal expansion, unit: m

% Calculate total conductor length at maximum temperature (L_actual)
L_actual = lambda_c + lambda_thermal; % Total conductor length at maximum temperature, unit: m

% Calculate sag at maximum temperature (S_Tmax) using total conductor length
S_Tmax = sqrt((3 * R_s * L_actual - 3 * R_s^2) / 8); % Sag at maximum temperature, unit: m

% Display results
fprintf('Selected conductor: %s\n', selected_conductor);
fprintf('Weight per unit length (W): %.3f N/m\n', W);
fprintf('Tension (T): %.2f N\n', T);
fprintf('Resistance at 110°C (R_Tc): %.6f Ω/m\n', R_Tc);
fprintf('Maximum allowable current (I_max): %.2f A\n', I_max);
fprintf('Single-circuit maximum transmission capacity (P_rated_single, without voltage drop): %.2f MVA\n', P_rated_single_MVA);
fprintf('Double-circuit maximum transmission capacity (P_rated_double, without voltage drop): %.2f MVA\n', P_rated_double_MVA);
fprintf('Total line impedance (R_total): %.2f Ω\n', R_total);
fprintf('Total voltage drop (Delta_V): %.2f V\n', Delta_V);
fprintf('Effective voltage at the receiving end (V_effective): %.2f V\n', V_effective);
fprintf('Effective single-circuit transmission capacity (P_effective_single, with voltage drop): %.2f MVA\n', P_effective_single_MVA);
fprintf('Effective double-circuit transmission capacity (P_effective_double, with voltage drop): %.2f MVA\n', P_effective_double_MVA);
fprintf('Swing angle (phi): %.2f degrees\n', phi_deg);
fprintf('Sag at normal temperature (S_Tc): %.2f m\n', S_Tc);
fprintf('Sag at maximum temperature (S_Tmax): %.2f m\n
