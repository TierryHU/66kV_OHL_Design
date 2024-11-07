clear;
% Define conductor data table
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

% Select conductor
selected_conductor = 'Horse'; % Can change to 'Oak', 'Poplar', 'Upas', 'Rubus', 'Gopher', 'Horse', 'Lynx', 'Moose'

% Extract selected conductor parameters
conductor = conductor_data(strcmp(conductor_data.Name, selected_conductor), :);

% Define other constants
V_line = 66e3; % Line voltage, unit: volts (66 kV)
T1 = 75; % Reference temperature T1, unit: Celsius
T2 = 20; % Reference temperature T2, unit: Celsius
Tc = 110; % Maximum operating temperature, unit: Celsius
T_install = 5; % Installation temperature, unit: Celsius
line_length_km = 50; % Total span, unit: km
R_s = 180; % Horizontal span, unit: m
wind_speed = 14.6; % Wind speed, unit: m/s

% Conductor weight and tension-related data
g = 9.81; % Gravitational acceleration, unit: m/s^2
tension_ratio = 0.22; % Tension ratio, 22%

% Fixed heat loss and gain data
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
I_max = sqrt((q_c + q_r - q_s) / R_Tc); % Maximum allowable current, unit: Amps (A)

% Calculate maximum single-circuit transmission capacity (unit: VA), convert to MVA
P_rated_single_VA = sqrt(3) * V_line * I_max; % Single-circuit maximum transmission capacity, unit: VA
P_rated_single_MVA = P_rated_single_VA / 1e6; % Single-circuit maximum transmission capacity, unit: MVA

% Calculate double-circuit maximum transmission capacity
P_rated_double_MVA = 2 * P_rated_single_MVA; % Double-circuit maximum transmission capacity, unit: MVA

% Calculate elastic sag at normal temperature (S_Tc)
S_Tc = (W * R_s^2) / (8 * T); % Sag of the conductor at normal temperature, unit: m

% Calculate conductor length at installation temperature (lambda_c)
lambda_c = R_s + (W^2 * R_s^3) / (24 * T^2); % Initial conductor length, unit: m

% Calculate length increase due to thermal expansion (lambda_thermal) - Installation temperature 5°C
lambda_thermal = conductor.Linear_Expansion_Coefficient * (Tc - T_install) * lambda_c; % Change in length due to thermal expansion, unit: m

% Calculate total conductor length at maximum temperature (L_actual)
L_actual = lambda_c + lambda_thermal; % Total conductor length at maximum temperature, unit: m

% Calculate sag at maximum temperature (S_Tmax)
S_Tmax = sqrt((3 * R_s * L_actual - 3 * R_s^2) / 8); % Sag at maximum temperature, unit: m

% Calculate wind load (F_c)
rho = 1.22; % Air density, unit: kg/m^3
diameter_m = conductor.Diameter_mm / 1000; % Convert conductor diameter to meters
F_c = 0.5 * rho * wind_speed^2 * diameter_m * R_s; % Wind load on the conductor, unit: N

% Calculate swing angle (phi)
W_c = W * R_s; % Total weight of the conductor, unit: N
phi = atan(F_c / W_c); % Swing angle, unit: radians
phi_deg = rad2deg(phi); % Convert to degrees

% Display results
fprintf('Selected conductor: %s\n', selected_conductor);
fprintf('Weight per unit length (W): %.3f N/m\n', W);
fprintf('Tension (T): %.2f N\n', T);
fprintf('Sag at normal temperature (S_Tc): %.2f m\n', S_Tc);
fprintf('Sag at maximum temperature (S_Tmax): %.2f m\n', S_Tmax);
fprintf('Conductor length at installation temperature (lambda_c): %.2f m\n', lambda_c);
fprintf('Change in length due to thermal expansion (lambda_thermal): %.4f m\n', lambda_thermal);
fprintf('Total conductor length at maximum temperature (L_actual): %.2f m\n', L_actual);
fprintf('Resistance at 110°C (R_Tc): %.6f Ω/m\n', R_Tc);
fprintf('Maximum allowable current (I_max): %.2f A\n', I_max);
fprintf('Single-circuit maximum transmission capacity (P_rated_single): %.2f MVA\n', P_rated_single_MVA);
fprintf('Double-circuit maximum transmission capacity (P_rated_double): %.2f MVA\n', P_rated_double_MVA);
fprintf('Swing angle (phi): %.2f degrees\n', phi_deg);
