%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The Type-oriented Algorithm for Baseline Correction %%%
%%%                By: Christopher Wong                 %%%
%%%                crswong888@gmail.com                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% This scripts demonstrates the correction of a three ramp impulses occuring in alternating
%%% directions. If the nominal acceleration signal were integrated with the homogenous initial value
%%% problem, a baseline drift would be apparent in the resulting displacement time history. Also,
%%% since only 1.5 cycles elapse, a type A1 correction (consisting of a first-order adjustment to 
%%% acceleration) provides an appropriate compensation for drift. Compare this to 'twenty_sines.m',
%%% where the signal is sine wave that runs for 20 cycles and uses a type A13-V13-D11 correction.

clear all %#ok<CLALL>
format longeng
fprintf('\n')

addpath('functions')


%%% COMPUTATIONS
%%% ------------------------------------------------------------------------------------------------

%// define vertices of three oscillating ramp impulses from 0 s to 4 s
tdom = 0:4; % s, time domain
scale_factor = 34.1910905592082e-003; % scales 1 g (981 cm/s/s) so that disp. amp is exactly 5 cm
ramp = [0, 981.0, 0, -981.0, 0] * scale_factor; % cm/s/s

%// discretize time domain and evaluate accelerations by interpolating between ramp vectices
time = generate1DGridPoints(tdom(1), tdom(end), 5e-3);
accel = arrayfun(@(t) linearInterpolation(tdom, ramp, t), time);

%// apply type A1 baseline correction - integrate using Newmark's linear acceleration method
[adj_accel, adj_vel, adj_disp] = baselineCorrection(time, accel, 'AccelFitOrder', 1, 'beta', 1 / 4);

%// compute drift ratio of corrected series'
DR = computeDriftRatio(time, adj_disp, 'ReferenceAccel', accel);


%%% POSTPROCESSING
%%% ------------------------------------------------------------------------------------------------

%// generate plots of corrected time histories
plot_titles = {'Corrected Acceleration Time History';
               'Corrected Velocity Time History';
               'Corrected Displacement Time History'};

plotTimeSeries(time, [adj_accel; adj_vel; adj_disp], 'Title', plot_titles, 'ClearFigures', true)