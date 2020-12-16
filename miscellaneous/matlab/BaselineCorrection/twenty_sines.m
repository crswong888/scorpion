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

%// apply least squares baseline correction and output adjusted time histories
[adj_accel, adj_vel, adj_disp] = baselineCorrection(time, accel, 'AccelFitOrder', 9,...
                                    'VelFitOrder', 9, 'DispFitOrder', 7, 'ResidualTol', 1e-06);