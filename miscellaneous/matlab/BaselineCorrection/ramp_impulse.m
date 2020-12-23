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
ramp = cat(1, 0:1:4, [0, 981.0, 0, -981.0, 0] * 34.1910905592076e-003);
time = 0:0.005:4;
accel = [];
for i = 1:length(time)
    accel = cat(2, accel, linearInterpolation(ramp(1,:), ramp(2,:), time(i)));
end

%// apply least squares baseline correction and output adjusted time histories
[adj_accel, adj_vel, adj_disp] = baselineCorrection(time, accel, 'AccelFitOrder', 1);

%// ideally, DR < 0.05 and |AR - 1| < 0.05
[DR, AR] = computeDriftRatio(time, accel, adj_disp);

%//
catseries = [adj_accel; adj_vel; adj_disp];
plot_titles = {'Adjusted Acceleration Time History';
               'Adjusted Velocity Time History';
               'Adjusted Displacement Time History'};

plotTimeSeries(time, catseries, 'Title', plot_titles)