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


%// generate array of discrete time instances and evaluate acceleration function
time = generate1DGridPoints(-0.4, 0.4, 1e-03);
accel = -250 * pi * pi * sin(50 * pi * time);

%/ set a reference displacement corresponding to drift-free ICs to use when compute drift/amp ratios
ref_disp = -0.1 * sin(50 * pi * time);

%// compute drifting ratio of nominal displacement for comparison to corrected one
[vel, disp] = newmarkIntegrate(time, accel, 0.5, 0.25);
[nomDR, nomAR] = computeDriftRatio(time, disp, 'ReferenceDisp', ref_disp);

%// apply least squares baseline correction and output adjusted time histories
[adj_accel, adj_vel, adj_disp] = baselineCorrection(time, accel, 'AccelFitOrder', 12,...
                                                    'VelFitOrder', 11, 'DispFitOrder', 7);                            

%// ideally, DR < 0.05 and |AR - 1| < 0.05
[DR, AR] = computeDriftRatio(time, adj_disp, 'ReferenceDisp', ref_disp);

%//
g = 9.81; % m/s/s, gravitational acceleration
catseries = [accel / g; vel; disp; adj_accel / g; adj_vel; adj_disp];
%layouts = {1:4, 1:3, [2; 4]};
layouts = {1:3, [1, 4], [2; 4]};
%layouts = {[1, 3], 1:2, [2; 4]};
layout_titles = ["none", "none", ""];

% str = ' Time History';
% plot_titles = {['Nominal Acceleration', str];
%                ['Nominal Velocity', str];
%                ['Nominal Displacement', str, ' (DR = ', num2str(nomDR), ', AR = ' num2str(nomAR), ')'];
%                ['Adjusted Acceleration', str];
%                ['Adjusted Velocity', str];
%                ['Adjusted Displacement', str, ' (DR = ', num2str(DR), ', AR = ' num2str(AR), ')']};

plot_titles = {'Nominal Time History', 'none', 'none', 'none', 'none', 'none'};
           
y_labels = {'Acc. (g)';
            'Vel. (m/s)';
            'Disp. (m)';
            'Acc. (g)';
            'Velocity (m/s)';
            'Displacement (m)'};

plotTimeSeries(time, catseries, 'TiledLayout', layouts, 'LayoutTitle', layout_titles,...
               'Title', plot_titles, 'XLabel', 'Time (s)', 'YLabel', y_labels, ...
               'FontName', 'times new roman', 'SizeFactor', 2, 'ClearFigures', true)
           
% plotTimeSeries(time, catseries,...
%                'Title', plot_titles, 'XLabel', 'Time (s)', 'YLabel', y_labels, ...
%                'FontName', 'times new roman', 'SizeFactor', 1, 'ClearFigures', true)

%%% plot original acceleration by itself
%%% plot adjusted time histories in layout format
%%% plot adjusted vs displaced in superimposed format (maybe do this on chichi)