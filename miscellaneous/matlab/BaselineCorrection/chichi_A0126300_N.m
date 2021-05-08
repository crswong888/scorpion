%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Baseline Correction for Acceleration Time Series %%%
%%%               By: Christopher Wong               %%%
%%%               crswong888@gmail.com               %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% 

clear all %#ok<CLALL>
format longeng
fprintf('\n')

addpath('functions')


%// input acceleration time series
data = transpose(readmatrix('records/chichi_A0126300_N.csv'));
time = [0, data(1,:)];
accel = [0, data(2,:)];

%// compute drifting ratio of nominal displacement for comparison to corrected one
[vel, disp] = newmarkIntegrate(time, accel, 0.5, 0.25);
[nomDR, nomAR] = computeDriftRatio(time, disp, 'ReferenceAccel', accel);

%// baseline correction using A3, A4 and V2 type adjustments
[accel_A3, vel_A3, disp_A3] = baselineCorrection(time, accel, 'AccelFitOrder', 3);
[accel_A4, vel_A4, disp_A4] = baselineCorrection(time, accel, 'AccelFitOrder', 4);
[accel_V3, vel_V3, disp_V3] = baselineCorrection(time, accel, 'VelFitOrder', 3);

%// ideally, DR < 0.05 and |AR - 1| < 0.05
[A3DR, A3AR] = computeDriftRatio(time, disp_A3, 'ReferenceAccel', accel);
[A4DR, A4AR] = computeDriftRatio(time, disp_A4, 'ReferenceAccel', accel);
[V2DR, V2AR] = computeDriftRatio(time, disp_V3, 'ReferenceAccel', accel);


%//
disp_ss = transpose(readmatrix('records/chichi_A0126300_N_ss.csv'));
disp_ss = [0, disp_ss(4,:), 0];
disp_aba = transpose(readmatrix('records/chichi_A0126300_N_aba.txt'));
disp_aba = disp_aba(2,:);

%// 
g = 981; % cm/s/s, gravitational acceleration
catseries = [accel / g; vel; disp; 
             accel_A3 / g; vel_A3; disp_A3; 
             accel_V3 / g; vel_V3; disp_V3;
             disp_ss; disp_aba];
plot_titles = ["Nominal Time History";
               "none";
               "none";
               "Corrected (A3) Time History"
               "none"
               "none";
               "Corrected (V3) Time History";
               "none";
               "none";
               "Corrected (SeismoSignal) Time History";
               "Corrected (Abaqus) Time History"];
           
y_labels = ["Acc. (g)", "Vel. (cm/s)", "Disp. (cm)"];
y_labels = [y_labels, y_labels, y_labels, y_labels(3), y_labels(3)];

superimps = {[6, 10], [9, 11]};
superimp_titles = ["none", "none"];
superimp_labels = [y_labels(3), y_labels(3)];
legends = {["Type-Oriented", "SeismoSignal"], ["Type-Oriented", "Abaqus"]};

layouts = {1:3, 4:6, 7:9, 12:13};
layout_titles(1:length(layouts)) = "none";

plotTimeSeries(time, catseries, 'Title', plot_titles, 'Xlabel', 'Time (s)', 'YLabel', y_labels,...
               'Superimpose', superimps, 'SuperimposeTitle', superimp_titles,...
               'SuperimposeYLabel', superimp_labels, 'Legend', legends,...
               'LegendLocation', 'northeast', 'TiledLayout', layouts,...
               'LayoutTitle', layout_titles, 'SizeFactor', 2)
