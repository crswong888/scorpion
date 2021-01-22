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
time = data(1,:);
accel = data(2,:);

%// compute drifting ratio of nominal displacement for comparison to corrected one
[vel, disp] = newmarkIntegrate(time, accel, 0.5, 0.25);
[nomDR, nomAR] = computeDriftRatio(time, accel, disp);

%// baseline correction using A3, A4 and V2 type adjustments
[accel_A3, vel_A3, disp_A3] = baselineCorrection(time, accel, 'AccelFitOrder', 3);
[accel_A4, vel_A4, disp_A4] = baselineCorrection(time, accel, 'AccelFitOrder', 4);
[accel_V2, vel_V2, disp_V2] = baselineCorrection(time, accel, 'VelFitOrder', 2);

%// ideally, DR < 0.05 and |AR - 1| < 0.05
[A3DR, A3AR] = computeDriftRatio(time, accel, disp_A3);
[A4DR, A4AR] = computeDriftRatio(time, accel, disp_A4);
[V2DR, V2AR] = computeDriftRatio(time, accel, disp_V2);


%// 
catseries = [accel_V2; vel_V2; disp_V2];
plot_titles = {'Adjusted Acceleration Time History';
               'Adjusted Velocity Time History';
               'Adjusted Displacement Time History'};

plotTimeSeries(time, catseries, 'Title', plot_titles)
