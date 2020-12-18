%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Baseline Correction of Acceleration Time Histories %%%
%%%                By: Christopher Wong                %%%
%%%                crswong888@gmail.com                %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% 

clear all %#ok<CLALL>
format longeng
fprintf('\n')

addpath('functions')


%// input acceleration time series
accel_func = @(t) -250 * pi * pi * sin(50 * pi * t);
[time, accel] = functionAcceleration(-0.4, 0.4, 1e-03, accel_func);

%// compute drifting ratio of nominal displacement for comparison to corrected one
[vel, disp] = newmarkIntegrate(time, accel, 0.5, 0.25);
[nom_DR, nom_AR] = computeDriftRatio(time, accel, disp);

%// apply least squares baseline correction and output adjusted time histories
[adj_accel, adj_vel, adj_disp] = baselineCorrection(time, accel, 'AccelFitOrder', 12,...
                                    'VelFitOrder', 11, 'DispFitOrder', 9);

%// ideally, DR < 0.05 and |AR - 1| < 0.05
[DR, AR] = computeDriftRatio(time, accel, adj_disp);

%//
plotTimeSeries(time, [adj_accel; adj_disp; adj_accel])