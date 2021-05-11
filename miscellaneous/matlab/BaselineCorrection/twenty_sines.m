%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The Type-oriented Algorithm for Baseline Correction %%%
%%%                By: Christopher Wong                 %%%
%%%                crswong888@gmail.com                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% 

clear all %#ok<CLALL>
format longeng
fprintf('\n')

addpath('functions')


%%% COMPUTATIONS
%%% ------------------------------------------------------------------------------------------------

%// generate array of discrete time instances and evaluate a harmonic acceleration function
time = generate1DGridPoints(-5, 5, 0.01); % time mesh = [-5, 5] s @ 0.01 s
accel = 80 * pi * pi * sin(4 * pi * time); % amplitude = 80 * pi^2 cm/s/s, frequency = 2 Hz

%/ set a reference displacement corresponding to drift-free ICs for evaluating drift/amp ratios
%/
%/ NOTE: This expression can be obtained by double-integrating 'accel' and assuming that the initial
%/       velocity is '-80 pi * pi / 4 / pi * cos(4 * pi * -5)', and that the initial displacement
%/       is: '-80 * pi * pi / 4 / pi / 4 / pi * sin(4 * pi * -5)'.
ref_disp = -5 * sin(4 * pi * time);

%// compute nominal time series and its drift ratio to compare to corrected ones
[vel, disp] = newmarkIntegrate(time, accel);
[nomDR, nomAR] = computeDriftRatio(time, disp, 'ReferenceDisp', ref_disp);

%// apply various baseline correction types to demonstrate their differences
[accel_A3, vel_A3, disp_A3] = baselineCorrection(time, accel, 'AccelFitOrder', 3);
[accel_V3, vel_V3, disp_V3] = baselineCorrection(time, accel, 'VelFitOrder', 3);
[accel_A13V13D11, vel_A13V13D11, disp_A13V13D11] = baselineCorrection(time, accel,...
                                                                      'AccelFitOrder', 13,...
                                                                      'VelFitOrder', 13,...
                                                                      'DispFitOrder', 11);

%// compute drift and amplitude ratios of corrected series' (ideally, DR < 0.05 and |AR - 1| < 0.05)
[A3DR, A3AR] = computeDriftRatio(time, disp_A3, 'ReferenceDisp', ref_disp);
[V3DR, V3AR] = computeDriftRatio(time, disp_V3, 'ReferenceDisp', ref_disp);
[A13V13D11DR, A13V13D11AR] = computeDriftRatio(time, disp_A13V13D11, 'ReferenceDisp', ref_disp);


%%% POSTPROCESSING
%%% ------------------------------------------------------------------------------------------------

%// concate time histories to be read by plot generator
g = 981; % cm/s/s, gravitational acceleration
catseries = [accel / g; vel; disp; disp_A3; disp_V3; disp_A13V13D11];

%/ set corresponding plot titles
plot_titles = ["Nominal Acceleration";
               "Nominal Velocity";
               "Nominal Displacement (DR = " + num2str(nomDR, 4) + ", AR = " + num2str(nomAR, 4)...
               + ")";
               "Type A3 (DR = " + num2str(A3DR, 4) + ", AR = " + num2str(A3AR, 4) + ")";
               "Type V3 (DR = " + num2str(V3DR, 4) + ", AR = " + num2str(V3AR, 4) + ")";
               "Type A13-V13-D11 (DR = " + num2str(A13V13D11DR, 4) + ", AR = "...
               + num2str(A13V13D11AR, 4) + ")"];

%/ set corresponding y-axis labels
y_labels = ["Acc. (g)", "Vel. (cm/s)", "Disp. (cm)"];
y_labels(end:(end + 3)) = y_labels(3);

%// identify plot sets to appear in individual tiled layouts
layouts = 1:length(plot_titles); % all plots in one layout

%// run plot generator
plotTimeSeries(time, catseries, 'Title', plot_titles, 'Xlabel', 'Time (s)', 'YLabel', y_labels,...
               'TiledLayout', 1:6, 'LayoutTitle', 'none', 'FontName', 'times new roman',...
               'SaveImage', true, 'SizeFactor', 1)