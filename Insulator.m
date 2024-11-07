% Define the insulator data table
insulator_data = table( ...
    {'U160BS', 'U160BSP', 'U160BL', 'U160BLP', 'S248130V3', 'S248130V5', 'S248142V6', 'S248142V7'}', ...
    [160, 160, 160, 160, 210, 210, 210, 210]', ... % Electrical-mechanical strength, unit: kN
    [280, 330, 280, 330, 3302, 3302, 3607, 3607]', ... % Insulator diameter D, unit: mm
    [146, 146, 170, 170, 2967, 2967, 3272, 3272]', ... % Single insulator length P, unit: mm
    [315, 440, 340, 525, 9060, 11293, 8491, 12969]', ... % Creepage distance, unit: mm
    'VariableNames', {'Designation', 'Strength_kN', 'Diameter_mm', 'Length_mm', 'Creepage_mm'});

% Select the insulator
selected_insulator = 'U160BS'; % Can be changed to 'U160BS', 'U160BSP', 'U160BL', 'U160BLP', 'S248130V3', 'S248130V5', 'S248142V6', 'S248142V7', etc.

% Extract parameters of the selected insulator
insulator = insulator_data(strcmp(insulator_data.Designation, selected_insulator), :);

% Define insulation requirements
required_creepage = 5.6 * 1000; % Required creepage distance, unit: mm
required_strength = 160; % Required electrical-mechanical strength, unit: kN
fitting_length = 0.45; % Fitting length, unit: m

% Calculate the required number of insulators
num_insulators = ceil(required_creepage / insulator.Creepage_mm); % Round up to meet creepage distance requirement

% Calculate total insulator length (including fitting length)
total_length = num_insulators * insulator.Length_mm / 1000 + fitting_length; % Total insulator length, unit: m

% Check if the tensile strength requirement is met
strength_sufficient = insulator.Strength_kN >= required_strength;

% Display results
fprintf('Selected insulator: %s\n', selected_insulator);
fprintf('Number of insulators: %d\n', num_insulators);
fprintf('Total insulator length (including fitting length): %.2f m\n', total_length);
fprintf('Total creepage distance: %.2f m\n', num_insulators * insulator.Creepage_mm / 1000);
fprintf('Tensile strength requirement met: %s\n', string(strength_sufficient));
