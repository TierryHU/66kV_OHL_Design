clear;
% 定义导体数据表格
conductor_data = table( ...
    {'Oak', 'Poplar', 'Upas', 'Rubus', 'Gopher', 'Horse', 'Lynx', 'Moose'}', ...
    [14.0, 20.1, 24.7, 31.5, 7.08, 14.0, 19.5, 31.8]', ... % 导体直径，单位：mm
    [324.5, 659.4, 997.5, 1622, 106.2, 537.3, 834, 1997.3]', ... % 导体重量，单位：kg/km
    [35.07, 70.61, 106.82, 173.53, 9.58, 61.26, 79.97, 159.92]', ... % 额定强度，单位：kN
    [23.0e-6, 23.0e-6, 23.0e-6, 23.0e-6, 19.1e-6, 15.3e-6, 17.8e-6, 19.3e-6]', ... % 线性膨胀系数
    [0.2768, 0.1390, 0.0921, 0.0574, 1.300, 0.3230, 0.1532, 0.0560]', ... % 20°C时电阻，单位：Ω/km
    [0.3316, 0.1665, 0.1104, 0.0688, 1.6945, 0.5425, 0.1873, 0.0684]', ... % 75°C时电阻，单位：Ω/km
    'VariableNames', {'Name', 'Diameter_mm', 'Weight_kg_per_km', 'Rated_Strength_kN', ...
                      'Linear_Expansion_Coefficient', 'R20_Ohm_per_km', 'R75_Ohm_per_km'});

% 选择导体
selected_conductor = 'Horse';% 可以更改为 'Oak', 'Poplar', 'Upas', 'Rubus', 'Gopher', 'Horse', 'Lynx', 'Moose' 

% 提取所选导体的参数
conductor = conductor_data(strcmp(conductor_data.Name, selected_conductor), :);

% 定义其他常量
V_line = 66e3; % 线路电压，单位：伏 (66 kV)
T1 = 75; % 参考温度 T1，单位：摄氏度
T2 = 20; % 参考温度 T2，单位：摄氏度
Tc = 110; % 最大工作温度，单位：摄氏度
T_install = 5; % 安装温度，单位：摄氏度
line_length_km = 50; % 总跨度，单位：公里
line_length_m = line_length_km * 1000; % 将公里转换为米
R_s = 180; % 水平跨度，单位：米
wind_speed = 14.6; % 风速，单位：m/s

% 导线重量及张力相关数据
g = 9.81; % 重力加速度，单位：m/s^2
tension_ratio = 0.22; % 导体张力的比例，22%

% 热损失和增益数据
q_c = 36.30; % 对流热损失，单位：W/m
q_r = 15.40; % 辐射热损失，单位：W/m
q_s = 11.30; % 太阳辐射增益，单位：W/m

% 计算单位长度的重量（N/m）
W_per_m = conductor.Weight_kg_per_km / 1000; % 将 kg/km 转换为 kg/m
W = W_per_m * g; % 转换为每米的重量力（单位：N/m）

% 计算张力
T = tension_ratio * conductor.Rated_Strength_kN * 1e3; % 将kN转换为N

% 计算电阻 R_Tc 在 110°C 时
R_75 = conductor.R75_Ohm_per_km / 1000; % 将75°C时的电阻转换为每米单位（欧姆/米）
R_20 = conductor.R20_Ohm_per_km / 1000; % 将20°C时的电阻转换为每米单位（欧姆/米）
R_Tc = ((R_75 - R_20) / (T1 - T2)) * (Tc - T1) + R_75; % 110°C时的电阻（欧姆/米）

% 计算最大允许电流 I_max
I_max = sqrt((q_c + q_r - q_s) / R_Tc); % 最大允许电流，单位：安培 (A)

% 计算单回路的最大传输容量（单位：VA），并转换为 MVA
P_rated_single_VA = sqrt(3) * V_line * I_max; % 单回路最大传输容量，单位：伏安 (VA)
P_rated_single_MVA = P_rated_single_VA / 1e6; % 单回路最大传输容量，单位：MVA

% 计算双回路的最大传输容量
P_rated_double_MVA = 2 * P_rated_single_MVA; % 双回路最大传输容量，单位：MVA

% 计算线路总阻抗 R_total
R_total = R_Tc * line_length_m; % 线路总阻抗，单位：欧姆

% 使用总阻抗和最大电流计算总压降 ΔV
Delta_V = R_total * I_max; % 总压降，单位：伏

% 计算接收端的有效电压
V_effective = V_line - Delta_V; % 考虑总压降后的接收端电压

% 计算基于有效电压的最终传输容量
P_effective_single_VA = sqrt(3) * V_effective * I_max; % 单回路有效传输容量，单位：VA
P_effective_single_MVA = P_effective_single_VA / 1e6; % 转换为 MVA
P_effective_double_MVA = 2 * P_effective_single_MVA; % 双回路有效传输容量

% 计算风载荷 (F_c)
rho = 1.22; % 空气密度，单位：kg/m^3
diameter_m = conductor.Diameter_mm / 1000; % 导体直径，转换为米
F_c = 0.5 * rho * wind_speed^2 * diameter_m * R_s; % 作用在导体上的风载荷，单位：N

% 计算摆动角度 (phi)
W_c = W * R_s; % 导体的总重量，单位：N
phi = atan(F_c / W_c); % 摆动角度，单位：弧度
phi_deg = rad2deg(phi); % 转换为度数

% 计算常温下的弹性垂度 (S_Tc)
S_Tc = (W * R_s^2) / (8 * T); % 导体在常温下的垂度，单位：米

% 计算安装温度下的导线长度 (lambda_c)
lambda_c = R_s + (W^2 * R_s^3) / (24 * T^2); % 初始导线长度，单位：米

% 计算热膨胀引起的导线长度增加 (lambda_thermal) - 安装温度5°C
lambda_thermal = conductor.Linear_Expansion_Coefficient * (Tc - T_install) * lambda_c; % 热膨胀引起的导线长度变化，单位：米

% 计算最高温度下的总导线长度 (L_actual)
L_actual = lambda_c + lambda_thermal; % 最大温度下的导线总长度，单位：米

% 使用总导线长度计算最高温度下的垂度 (S_Tmax)
S_Tmax = sqrt((3 * R_s * L_actual - 3 * R_s^2) / 8); % 最高温度下的垂度，单位：米

% 显示结果
fprintf('所选导体: %s\n', selected_conductor);
fprintf('单位长度的重量 (W): %.3f N/m\n', W);
fprintf('张力 (T): %.2f N\n', T);
fprintf('110°C 时的电阻 (R_Tc): %.6f 欧姆/米\n', R_Tc);
fprintf('最大允许电流 (I_max): %.2f A\n', I_max);
fprintf('单回路最大传输容量 (P_rated_single, 未考虑压降): %.2f MVA\n', P_rated_single_MVA);
fprintf('双回路最大传输容量 (P_rated_double, 未考虑压降): %.2f MVA\n', P_rated_double_MVA);
fprintf('线路总阻抗 (R_total): %.2f 欧姆\n', R_total);
fprintf('总压降 (Delta_V): %.2f V\n', Delta_V);
fprintf('接收端有效电压 (V_effective): %.2f V\n', V_effective);
fprintf('单回路有效传输容量 (P_effective_single, 考虑压降): %.2f MVA\n', P_effective_single_MVA);
fprintf('双回路有效传输容量 (P_effective_double, 考虑压降): %.2f MVA\n', P_effective_double_MVA);
fprintf('摆动角度 (phi): %.2f 度\n', phi_deg);
fprintf('常温下的垂度 (S_Tc): %.2f m\n', S_Tc);
fprintf('最高温度下的垂度 (S_Tmax): %.2f m\n', S_Tmax);
%fprintf('安装温度下的导线长度 (lambda_c): %.2f m\n', lambda_c);
%fprintf('热膨胀引起的导线长度变化 (lambda_thermal): %.4f m\n', lambda_thermal);
%fprintf('最高温度下的总导线长度 (L_actual): %.2f m\n', L_actual);
