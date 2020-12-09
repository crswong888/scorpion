%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Newmark-beta Method for Nonlinear SDOF Systems %%%
%%%              By: Christopher Wong              %%%
%%%              crswong888@gmail.com              %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% This script reproduces Example 5.4 from Chopra, AK. (2014). "Dynamics of Structures." 4th ed.
%%% The model is the elastic version of Example 5.5 (see 'chopraEx55.m'). This demonstrates how the
%%% numerical formulation of this code is capable of degenerating to the linear elastic case.

clear all %#ok<CLALL>
format longeng
fprintf('\n')

addpath('functions')


%%% INPUT PARAMETERS
%%% ------------------------------------------------------------------------------------------------

%// mass
m = 0.45594; % kN*s*s/cm

%// acceleration of gravity
g = 0;

%// critical damping ratio
xi = 0.05;

%// restoring force backbone curve fs(u) = df/du * u - data must be input as abscissa-ordinate pairs
fs = [ 1;  % cm
      18]; % kN
%%% Note: Since Chopra specifies that spring stiffness is 18 kN/cm, and since this is a linear
%%% elastic problem, the only abscissa ordinate-pair that need be provided is (u, fs) = (1, 18).

%// time domain [t_initial, t_end]
t = [0, 1]; % s

%// timestep size - if zero (reccomended), one will be automatically selected
dt = 0.1; % s

%// velocity and displacement initial conditions du(t_initial) u(t_initial)
du_initial = 0;
u_initial = 0;

%// forcing function p(t) (use anonymous function format - can be made piecewise using .* syntax)
p = @(t) (t < 0.6).*(50 * sin(pi * t / 0.6)) + (0.6 <= t).*(0); % kN

%// angular frequency of p(t) - if zero, it is assumed that p(t) is not a harmonic function
omegaBar = pi / 0.6; % rad/s

%// Newmark-beta method parameters (reccomended: gamma = 1/2 and beta = 1/4 or beta = 1/6)
gamma = 1 / 2;
beta = 1 / 6;

%// residual tolerance and max allowable Newton iterations - R_tol is also used for other tolerances
R_tol = 1e-03;
max_it = 20;

%// string of parameter units = {time, distance, force} (used for data reports - not conversions)
units = {'s', 'cm', 'kN'};


%%% SOURCE COMPUTATIONS
%%% ------------------------------------------------------------------------------------------------

%// compute natural angular frequency, damping coefficient, and elastic stiffness
[omega_n, c, ke] = computeDynamicConstants(m, xi, fs);

%// determine a suitable time step size if not specified by user
if (dt == 0)
    dt = computeTimeStepSize(omega_n, omegaBar, 'Nonlinear', true);
end

%// add a static initialization to displacement initial condition
u_initial = u_initial + m * g / ke;

%// numerically solve nonlinear equation of motion using Newmark-beta and Newton-Raphson methods
[t, d2u, du, u, fs_history] = solveEquationOfMotion(m, c, fs, ke, t, dt, du_initial, u_initial,...
                                                    p, gamma, beta, R_tol, max_it);


%%% POSTPROCESSING
%%% ------------------------------------------------------------------------------------------------

%// create plots of particular solution results
plotEquationOfMotion(t, d2u, du, u, fs_history, p, units)