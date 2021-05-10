clear all %#ok<CLALL>
format longeng
fprintf('\n')

addpath('functions')

%// generate array of discrete time instances and evaluate acceleration function
time = generate1DGridPoints(-5, 5, 0.01);
accel = 80 * pi * pi * sin(4 * pi * time);

%/ set a reference displacement corresponding to drift-free ICs to use when compute drift/amp ratios
ref_disp = -5 * sin(4 * pi * time);

%// compute nominal time series and their drift ratios to compare to corrected ones
[vel, disp] = newmarkIntegrate(time, accel);
[nomDR, nomAR] = computeDriftRatio(time, disp, 'ReferenceDisp', ref_disp);

%// apply various baseline correction types to compare them to each other
[accel_A3, vel_A3, disp_A3] = baselineCorrection(time, accel, 'AccelFitOrder', 3);
[accel_V3, vel_V3, disp_V3] = baselineCorrection(time, accel, 'VelFitOrder', 3);
[accel_A13V13D11, vel_A13V13D11, disp_A13V13D11] = baselineCorrection(time, accel,...
                                                                      'AccelFitOrder', 13,...
                                                                      'VelFitOrder', 13,...
                                                                      'DispFitOrder', 11);   
                                                               
%// compute drift and amplitude ratios (ideally, DR < 0.05 and |AR - 1| < 0.05)
[A3DR, A3AR] = computeDriftRatio(time, disp_A3, 'ReferenceDisp', ref_disp);
[V3DR, V3AR] = computeDriftRatio(time, disp_V3, 'ReferenceDisp', ref_disp);
[A12V12D9DR, A12V12D9AR] = computeDriftRatio(time, disp_A13V13D11, 'ReferenceDisp', ref_disp);

%//
g = 981; % cm/s/s, gravitational acceleration
catseries = [accel / g; vel; disp; disp_A3; disp_V3; disp_A13V13D11];
plot_titles = ["Nominal Acceleration";
               "Nominal Velocity";
               "Nominal Displacement (DR = " + num2str(nomDR, 4) + ", AR = " + num2str(nomAR, 4)...
               + ")";
               "Type A3 (DR = " + num2str(A3DR, 4) + ", AR = " + num2str(A3AR, 4) + ")";
               "Type V3 (DR = " + num2str(V3DR, 4) + ", AR = " + num2str(V3AR, 4) + ")";
               "Type A13-V13-D11 (DR = " + num2str(A12V12D9DR, 4) + ", AR = "...
               + num2str(A12V12D9AR, 4) + ")"];
%%% NOTE: next time, use cambria math font when listing DR and AR on plots

y_labels = ["Acc. (g)", "Vel. (cm/s)", "Disp. (cm)"];
y_labels(end:(end + 3)) = y_labels(3);
           
layouts = 1:6;
layout_titles(1:length(layouts)) = "none";

plotTimeSeries(time, catseries, 'Title', plot_titles, 'Xlabel', 'Time (s)', 'YLabel', y_labels,...
               'TiledLayout', 1:6, 'LayoutTitle', 'none', 'FontName', 'times new roman',...
               'SaveImage', true, 'SizeFactor', 1)

%// Additional Plotting for Adobe Illustrator sketch
filebase = "../media/"; % have to run 'mkdir' on this if not already

%/ nominal ground displacement (line styling can be handled in illustrator)
filename(1) = "ground_nominal";
ax{1} = axes(figure('Visible', false));
plot(ax{1}, time, disp, 'Color', [0, 0, 0]);

%/ corrected ground displacement
filename(2) = "ground_corrected";
ax{2} = axes(figure('Visible', false));
plot(ax{2}, time, disp_A13V13D11, 'Color', '#7A7777');

%/ nominal roof displacement from MOOSE
disp_roof = readmatrix('records/3story_frame_nominal_out.csv');
filename(3) = "roof_nominal";
ax{3} = axes(figure('Visible', false));
plot(ax{3}, disp_roof(:,1), disp_roof(:,4), 'Color', [0, 0, 0],...
     'Marker', 'o', 'MarkerIndices', [264, 790], 'MarkerSize', 16);

%/ corrected roof displacement from MOOSE
disp_A13V13D11_roof = readmatrix('records/3story_frame_corrected_out.csv');
filename(4) = "roof_corrected";
ax{4} = axes(figure('Visible', false));
plot(ax{4}, disp_A13V13D11_roof(:,1), disp_A13V13D11_roof(:,4), 'Color', '#7A7777',...
     'Marker', 'o', 'MarkerIndices', [264, 790], 'MarkerSize', 16);


%/ export vectors to be manipulated in Ai
for f = 1:length(filename)
    if (ispc)
        exportgraphics(ax{f}, filebase + filename(f) + ".emf", 'ContentType', 'vector')
    else
        exportgraphics(ax{f}, filebase + filename(f) + ".eps", 'ContentType', 'vector')
    end
end

close all % need to close the invisible figures

%// compute half-beat period between ground motion and fundamental frequency
f1 = 2.19552124112517; % fundamental frequency of frame corresponding to floor lateral translation
f2 = 2; % Hz, frequency of ground motion
Tb_predicted = 1 / abs(f1 - f2);

%/ compare to observed half-beat period (apparent peak-to-peak time difference)
Tb_observed = disp_A13V13D11_roof(790) - disp_A13V13D11_roof(288);
% Tb_observed = disp_A13V13D11_roof(572) - disp_A13V13D11_roof(47);
%%% NOTE: I'm not actually exactly sure how to deduce this from a plot...

%// compute and plot a FFT of nominal and corrected roof DTHs
fdom = [0, 4]; % frequency domain
[f, uo_roof] = discreteFourierTransform(time, disp_roof(:,4), 'Domain', fdom);
[~, uo_A13V13D11_roof] = discreteFourierTransform(time, disp_A13V13D11_roof(:,4), 'Domain', fdom);

% transforms = transpose([uo_roof, uo_A13V13D11_roof]);
% plot_titles = ["Nominal Model", "Type A13-V13-D11 Corrected Model"];
% y_labels = ["Peak Disp. (cm)", "Peak Disp. (cm)"];
% 
% plotTimeSeries(f, transforms, 'Title', plot_titles, 'Xlabel', 'Frequency (Hz)', 'YLabel', y_labels,...
%                'TiledLayout', 1:2, 'LayoutTitle', 'none', 'FontName', 'times new roman',...
%                'SaveImage', true, 'SizeFactor', 1)

%/ notice that total amplitude equals that at excitation frequency plus that at fundamental freq.,
idx = [find(f == 2), find(f == 2.2)]; % indices of two freqs. (Hz)
A_observed = sum(uo_A13V13D11_roof(idx)); % should be about 53-54 cm, and so it is...

%/ yeah so nominal amplitudes give you same number, but individual amplitudes are different...
A_observed_nominal = sum(uo_roof(idx));