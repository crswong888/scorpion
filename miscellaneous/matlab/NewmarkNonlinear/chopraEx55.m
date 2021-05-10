%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Newmark-beta Method for Nonlinear SDOF Systems %%%
%%%              By: Christopher Wong              %%%
%%%              crswong888@gmail.com              %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% This script reproduces Example 5.5 from Chopra, AK. (2014). "Dynamics of Structures." 4th ed.
%%% The model is a damped mass-spring with an elastic-perfectly plastic force-displacement
%%% relationship that yields at 36 kN (2 cm)

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
zeta = 0.05;

%// restoring force backbone 'fs(u) = df/du * u' - data must be input as abscissa-ordinate pairs
fs = [ 2,  5;  % cm
      36, 36]; % kN

%// time domain [t_initial, t_end]
t = [0, 1]; % s

%// timestep size - if zero or empty (reccomended), one will be automatically selected
dt = 0.1; % s

%// velocity and displacement initial conditions du(t_initial) u(t_initial)
du_initial = 0;
u_initial = 0;

%// forcing function p(t) (use an anonymous function format that can be sampled at any time instant)
p = @(t) (t < 0.6) .* (50 * sin(pi * t / 0.6)) + (0.6 <= t) .* 0; % kN

%// residual tolerance used for Newton solver and certain other tasks
R_tol = 1e-03; % should be nearly zero, but large enough to allow small errors

%// string of parameter units = {time, distance, force} (used for data reports - not conversions)
units = {'s', 'cm', 'kN'};


%%% SOURCE COMPUTATIONS
%%% ------------------------------------------------------------------------------------------------

%// compute natural angular frequency, damping coefficient, and elastic stiffness
[omega_n, c, ke] = computeDynamicConstants(m, zeta, fs);

%// determine a suitable time step size based on natural frequency and frequencies of forcing func
if (isempty(dt) || (dt == 0)) % but only if not already specified by user
    dt = computeTimeStepSize(t, omega_n, p, 'Nonlinear', (length(fs(1,:)) > 1));
end

%// add a static initialization to displacement initial condition
u_initial = u_initial + m * g / ke;

%// numerically solve nonlinear equation of motion using Newmark-beta and Newton-Raphson methods
[t, d2u, du, u, fs_history] = solveEquationOfMotion(m, c, fs, ke, t, dt, du_initial, u_initial,...
                                                    p, 'ResidualTol', R_tol);


%%% POSTPROCESSING
%%% ------------------------------------------------------------------------------------------------

%// create plots of particular solution results
plotEquationOfMotion(t, d2u, du, u, fs_history, p, units)