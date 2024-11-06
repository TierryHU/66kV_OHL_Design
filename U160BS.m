% 定义绝缘体数据表格
insulator_data = table( ...
    {'U160BS', 'U160BSP', 'U160BL', 'U160BLP', 'S248130V3', 'S248130V5', 'S248142V6', 'S248142V7'}', ...
    [160, 160, 160, 160, 210, 210, 210, 210]', ... % 电-机械强度，单位：kN
    [280, 330, 280, 330, 3302, 3302, 3607, 3607]', ... % 绝缘子直径 D，单位：mm
    [146, 146, 170, 170, 2967, 2967, 3272, 3272]', ... % 单个绝缘子长度 P，单位：mm
    [315, 440, 340, 525, 9060, 11293, 8491, 12969]', ... % 爬电距离，单位：mm
    'VariableNames', {'Designation', 'Strength_kN', 'Diameter_mm', 'Length_mm', 'Creepage_mm'});

% 选择绝缘体
selected_insulator = 'U160BS'; % 可以更改为 'U160BS', 'U160BSP', 'U160BL', 'U160BLP', 'S248130V3', 'S248130V5', 'S248142V6', 'S248142V7' 等

% 提取所选绝缘体的参数
insulator = insulator_data(strcmp(insulator_data.Designation, selected_insulator), :);

% 定义绝缘要求
required_creepage = 5.6 * 1000; % 所需爬电距离，单位：mm
required_strength = 160; % 所需电-机械强度，单位：kN
fitting_length = 0.45; % 配件长度，单位：米

% 计算所需的绝缘子数量
num_insulators = ceil(required_creepage / insulator.Creepage_mm); % 向上取整以满足爬电距离要求

% 计算绝缘子总长度（包括配件长度）
total_length = num_insulators * insulator.Length_mm / 1000 + fitting_length; % 绝缘子总长度，单位：米

% 判断是否满足抗拉强度要求
strength_sufficient = insulator.Strength_kN >= required_strength;

% 输出结果
fprintf('所选绝缘子: %s\n', selected_insulator);
fprintf('绝缘子数量: %d\n', num_insulators);
fprintf('绝缘子总长度（含配件长度）: %.2f 米\n', total_length);
fprintf('总爬电距离: %.2f 米\n', num_insulators * insulator.Creepage_mm / 1000);
fprintf('抗拉强度满足要求: %s\n', string(strength_sufficient));
