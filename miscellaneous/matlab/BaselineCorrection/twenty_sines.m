%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The Type-oriented Algorithm for Baseline Correction %%%
%%%                By: Christopher Wong                 %%%
%%%                crswong888@gmail.com                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% No summary yet...

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


%%% POSTPROCESSING 1: GENERATE PLOTS OF NOMINAL THs AND CORRECTED DISPLACEMENT THs
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
               'SaveImage', true, 'SizeFactor', 1, 'ClearFigures', true)


%%% POSTPROCESSING 2: PLOT FOURIER TRANSFORMS OF NOMINAL & CORRECTED 3-STORY FRAME ROOF DISPLACEMENT
%%% ------------------------------------------------------------------------------------------------           
           
%// read in roof displacement THs from MOOSE 3-story frame models subject to nominal and type 
%// A13-V13-D11 ground accelerations, data is: [time, ground disp., relative disp., roof disp.]
disp_frame = readmatrix('records/3story_frame_nominal_out.csv');
disp_A13V13D11_frame = readmatrix('records/3story_frame_corrected_out.csv');

%/ evaluate their discrete fourier transforms to demonstrate effect of BL drift in frequency domain
fdom = [0, 4]; % Hz, cyclic frequency domain of intesrest
[freq, peak_roof_disp] = discreteFourierTransform(time, disp_frame(:,4), 'Domain', fdom);
[~, peak_roof_disp_A13V13D11] = discreteFourierTransform(time, disp_A13V13D11_frame(:,4),...
                                                         'Domain', fdom);

%// concate frequency series' to be read by plot generator
transforms = transpose([peak_roof_disp, peak_roof_disp_A13V13D11]);

%/ set corresponding plot titles and y-axis labels
fplot_titles = ["Nominal Model", "Type A13-V13-D11 Corrected Model"];
amp_labels = repmat("Peak Disp. (cm)", size(fplot_titles));

%// run plot generator
plotTimeSeries(freq, transforms, 'Title', fplot_titles, 'Xlabel', 'Frequency (Hz)',...
               'YLabel', amp_labels, 'TiledLayout', 1:2, 'LayoutTitle', 'none',...
               'FontName', 'times new roman', 'SaveImage', true, 'SizeFactor', 1,...
               'FileBase', '3story_frame_freqs')
           
%// NOTE: The fundamental frequency represents translation of all floors in a purely-lateral common
%//       direction at a rate of 2.2 Hz. Amplitude spikes at this natural frequency and the
%//       frequency of the ground acceleration (2.0 Hz) can be observed in both the nominal and 
%//       corrected FFT plots, but the nominal transform also has a severe spike at 0 Hz, as the
%//       baseline drift is a quasistatic component of the motion with a relatively large amplitude