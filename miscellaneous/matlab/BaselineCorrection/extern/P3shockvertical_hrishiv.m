clear all %#ok<CLALL>
format longeng
fprintf('\n')

addpath('../functions')

%// read in data from file
data = readmatrix('records/P3shockvertical.xls');
time = data(:,1);
nom_accel = data(:,2);

%// compute nominal time series and its drift ratio to compare to corrected ones
[nom_vel, nom_disp] = newmarkIntegrate(time, nom_accel);
[nomDR, nomAR] = computeDriftRatio(time, nom_disp, 'ReferenceAccel', nom_accel);

%// apply baseline correction and check drift indicators
[accel, vel, disp] = baselineCorrection(time, nom_accel, 'AccelFitOrder', 6, 'VelFitOrder', 5);
[DR, AR] = computeDriftRatio(time, disp, 'ReferenceAccel', nom_accel);

%// write file with corrected acceleration
writetable(table(time, accel, 'VariableNames', ["time (s)", "acceleration (g)"]),...
           'P3shockvertical_corrected_out.csv');