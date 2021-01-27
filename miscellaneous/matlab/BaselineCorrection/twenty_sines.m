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
[nomDR, nomAR] = computeDriftRatio(time, accel, disp);

%// apply least squares baseline correction and output adjusted time histories
[adj_accel, adj_vel, adj_disp] = baselineCorrection(time, accel, 'AccelFitOrder', 12,...
                                                    'VelFitOrder', 11, 'DispFitOrder', 7);                            

%// ideally, DR < 0.05 and |AR - 1| < 0.05
[DR, AR] = computeDriftRatio(time, accel, adj_disp);

%//
catseries = [accel; vel; disp; adj_accel; adj_vel; adj_disp];
tiles = 1:6;

str = ' Time History';
plot_titles = {['Acceleration', str];
               ['Velocity', str];
               ['Displacement', str, ' (DR = ', num2str(nomDR), ', AR = ' num2str(nomAR), ')'];
               ['Acceleration', str];
               ['Velocity', str];
               ['Displacement', str, ' (DR = ', num2str(DR), ', AR = ' num2str(AR), ')']};
           
y_labels = {'Nominal Acceleration (m/s^{2})';
            'Nominal Velocity (m/s)';
            'Nominal Displacement (m)';
            'Adjusted Acceleration (m/s^{2})';
            'Adjusted Velocity (m/s)';
            'Adjusted Displacement (m)'};

plotTimeSeries(time, catseries, 'TiledLayout', tiles, 'LayoutTitle', "",...
               'Title', plot_titles, 'XLabel', 'Time (s)', 'YLabel', y_labels, ...
               'FontName', 'times new roman', 'FontSize', 12, 'ClearFigures', true)

%%% plot original acceleration by itself
%%% plot adjusted time histories in layout format
%%% plot adjusted vs displaced in superimposed format (maybe do this on chichi)