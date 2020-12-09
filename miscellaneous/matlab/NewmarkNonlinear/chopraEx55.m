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
xi = 0.05;

%// restoring force backbone curve fs(u) = df/du * u - data must be input as abscissa-ordinate pairs
fs = [ 2,  5;  % cm
      36, 36]; % kN

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
beta = 1 / 4;

%// residual tolerance and max allowable Newton iterations - R_tol is also used for other tolerances
R_tol = 1e-03;
max_it = 20;

%// string of parameter units = {time, distance, force} (used for data reports - not conversions)
units = {'s', 'cm', 'kN'};


%%% SOURCE COMPUTATIONS
%%% ------------------------------------------------------------------------------------------------

%// assert that backbone curve does not begin at (0, 0)
if (all(fs(:,1) == [0; 0]))
    error(['The first abscissa-oridnate pair of the supplied backbone curve data is ',...
           '''[0; 0]''. Please provide some other point in the upper positive quadrant.'])
end

%// compute elastic stiffness
ke = fs(2,1) / fs(1,1);

%// compute natural frequency of elastic system
omega_n = sqrt(ke / m);

%// compute damping constant (assumed to be constant even if plastic)
c = 2 * xi * m * omega_n;

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