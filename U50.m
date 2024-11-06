% 清空环境变量
clear;

% 定义参数
Um = 72.5; % 最高设备电压，单位 kV (r.m.s. value)
k = 1.45; % 表3中对应的设计系数
rms_to_peak_factor = sqrt(2); % 有效值转峰值的因子

% 将 Um 转换为峰值电压
Um_peak = Um * rms_to_peak_factor; % 单位：kV

% 定义不同电压的计算公式
% 交流电压的介电强度 (AC voltage, peak)
U50_ac = @(d) (3740 * k) / (1 + 8 / d);

% 雷电冲击电压的介电强度 (Lightning impulse voltage)
U50_lightning = @(d) (380 + 150 * k) * d;

% 开关冲击电压的介电强度 (Switching impulse voltage)
U50_switching = @(d) (3400 * k) / (1 + 8 / d);

% 定义目标电压 (kV, peak)，需与 Um_peak 相等或略高
target_voltage_ac = Um_peak; % 对应的峰值电压
target_voltage_lightning = 325; % 雷电冲击电压
target_voltage_switching = 325; % 开关冲击电压

% 计算满足要求的最小间隙 d (单位：米)
options = optimset('Display','off'); % 关闭显示
d_ac = fsolve(@(d) U50_ac(d) - target_voltage_ac, 1, options);
d_lightning = fsolve(@(d) U50_lightning(d) - target_voltage_lightning, 1, options);
d_switching = fsolve(@(d) U50_switching(d) - target_voltage_switching, 1, options);

% 输出结果
fprintf('满足 %0.1f kV (r.m.s.) 的空气间隙计算结果：\n', Um);
fprintf('交流电压要求的最小间隙 d_ac: %.2f m\n', d_ac);
fprintf('雷电冲击电压要求的最小间隙 d_lightning: %.2f m\n', d_lightning);
fprintf('开关冲击电压要求的最小间隙 d_switching: %.2f m\n', d_switching);
