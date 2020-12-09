%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Newmark-beta Method for Nonlinear SDOF Systems %%%
%%%              By: Christopher Wong              %%%
%%%              crswong888@gmail.com              %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% This is a model of a non-slender steel bar that deforms under uniaxial compression and tension
%%% and supports a, relatively, very large mass. The backbone curve data is provided in the
%%% 'a992bar_backbone.csv' file and represents ASTM A992 steel.

clear all %#ok<CLALL>
format longeng
fprintf('\n')

addpath('functions')


%%% INPUT PARAMETERS
%%% ------------------------------------------------------------------------------------------------

%// mass
m = 0.1583; % kN*s*s/cm

%// acceleration of gravity
g = 0;

%// critical damping ratio
xi = 0.03;

%// restoring force backbone curve fs(u) = df/du * u - data must be input as abscissa-ordinate pairs
fs = readmatrix('a992bar_backbone.csv');

%// time domain [t_initial, t_end]
t = [0, 0.6]; % s

%// timestep size - if zero (reccomended), one will be automatically selected
dt = 0;

%// velocity and displacement initial conditions du(t_initial) u(t_initial)
du_initial = 0;
u_initial = 0;

%// forcing function p(t) (use anonymous function format - can be made piecewise using .* syntax)
p = @(t) (t < 0.2).*(250 * sin(40 * pi * t)) + (0.2 <= t).*(0); % kN

%// angular frequency of p(t) - if zero, it is assumed that p(t) is not a harmonic function
omegaBar = 40 * pi; % rad/s

%// Newmark-beta method parameters (reccomended: gamma = 1/2 and beta = 1/4 or beta = 1/6)
gamma = 1 / 2;
beta = 1 / 4;

%// residual tolerance and max allowable Newton iterations - R_tol is also used for other tolerances
R_tol = 1e-08;
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