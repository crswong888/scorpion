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



%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% scale factor

%%% devel
gamma = 1 / 2;
beta = 1 / 4;
accel_fit_order = 9;
vel_fit_order = 9;
disp_fit_order = 3;
TOL = 1e-06;

N = length(accel);

%// computed unadjusted (nominal) velocity displacement time histories
vel = zeros(1, N);
disp = zeros(1, N);
for i = 1:(N - 1)
    dt = time(i + 1) - time(i);
    vel(i + 1) = newmarkGammaIntegrate(dt, accel(i), accel(i + 1), vel(i), gamma);
    disp(i + 1) = newmarkBetaIntegrate(dt, accel(i), accel(i + 1), vel(i), disp(i), beta);
end

%// initialize adjusted time histories with nominal ones
adj_accel = accel;
adj_vel = vel;
adj_disp = disp;

%// compute Jacobian and map time onto natural time $\tau \in [0, 1]$
J = range(time);
tau = (time - time(1)) / J;

%// adjust time histories with acceleration fit, if desired
if (~isempty(accel_fit_order))
    coeffs = getAccelerationFitCoeffs(accel_fit_order, tau, J, adj_accel, gamma, TOL);
    
    for i = 1:N
        pfit = evaluatePolynomials(coeffs, tau(i), J);
        
        adj_accel(i) = adj_accel(i) - pfit(1);
        adj_vel(i) = adj_vel(i) - pfit(2);
        adj_disp(i) = adj_disp(i) - pfit(3);
    end
end

%// adjust with velocity fit
if (~isempty(vel_fit_order))
    coeffs = getVelocityFitCoeffs(vel_fit_order, tau, J, adj_accel, adj_vel, beta, TOL);
    
    for i = 1:N
        pfit = evaluatePolynomials(coeffs, tau(i), J);
        
        adj_accel(i) = adj_accel(i) - pfit(1);
        adj_vel(i) = adj_vel(i) - pfit(2);
        adj_disp(i) = adj_disp(i) - pfit(3);
    end
end