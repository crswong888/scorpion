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

%// read in strong motion data from file
data = transpose(readmatrix('records/chichi_A0126300_N.csv'));
time = [0, data(1,:)];
accel = [0, data(2,:)];

%// compute nominal time series and its drift ratio to compare to corrected ones
[vel, disp] = newmarkIntegrate(time, accel, 0.5, 0.25);
[nomDR, nomAR] = computeDriftRatio(time, disp, 'ReferenceAccel', accel);

%// apply type A3 and V3 corrections to compare them to SeismoSignal and Abaqus output, respectively
[accel_A3, vel_A3, disp_A3] = baselineCorrection(time, accel, 'AccelFitOrder', 3);
[accel_V3, vel_V3, disp_V3] = baselineCorrection(time, accel, 'VelFitOrder', 3);

%// compute drift and amplitude ratios of corrected series' (ideally, DR < 0.05 and |AR - 1| < 0.05)
[A3DR, A3AR] = computeDriftRatio(time, disp_A3, 'ReferenceAccel', accel);
[V3DR, V3AR] = computeDriftRatio(time, disp_V3, 'ReferenceAccel', accel);


%%% POSTPROCESSING
%%% ------------------------------------------------------------------------------------------------

%// read in corrected displacement data obtained from SeismoSignal and Abaqus
disp_ss = transpose(readmatrix('records/chichi_A0126300_N_ss.csv'));
disp_ss = [0, disp_ss(4,:), 0];
disp_aba = transpose(readmatrix('records/chichi_A0126300_N_aba.txt'));
disp_aba = disp_aba(2,:);

%// concate time histories to be read by plot generator
g = 981; % cm/s/s, gravitational acceleration
catseries = [accel / g; vel; disp; 
             accel_A3 / g; vel_A3; disp_A3; 
             accel_V3 / g; vel_V3; disp_V3;
             disp_ss; disp_aba];

%/ set corresponding plot titles
plot_titles = ["Nominal Time History"; "none"; "none";
               "Corrected (A3) Time History"; "none"; "none";
               "Corrected (V3) Time History"; "none"; "none";
               "Corrected (SeismoSignal) Time History"; "Corrected (Abaqus) Time History"];

%/ set corresponding y-axis labels
y_labels = ["Acc. (g)", "Vel. (cm/s)", "Disp. (cm)"];
y_labels = [repmat(y_labels, [1, 3]), repmat(y_labels(3), [1, 2])]; % first nine plots and last two

%// identify plot sets to be superimposed and their corresponding titles, labels, and legends
superimps = {[6, 10], [9, 11]};
superimp_titles = repmat("none", size(superimps));
superimp_labels = repmat("Disp. (cm)", size(superimps));
legends = {["Type A3", "SeismoSignal"], ["Type V3", "Abaqus"]};

%// identify plot sets (including superimposed ones) to appear in individual tiled layouts
layouts = {1:3, 4:6, 7:9, 12:13};
layout_titles(1:length(layouts)) = "none";

%// run plot generator
plotTimeSeries(time, catseries, 'Title', plot_titles, 'Xlabel', 'Time (s)', 'YLabel', y_labels,...
               'Superimpose', superimps, 'SuperimposeTitle', superimp_titles,...
               'SuperimposeYLabel', superimp_labels, 'Legend', legends,...
               'LegendLocation', 'northeast', 'TiledLayout', layouts,...
               'LayoutTitle', layout_titles, 'FontName', 'times new roman', 'SaveImage', true,...
               'SizeFactor', 1)