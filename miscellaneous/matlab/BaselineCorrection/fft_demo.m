%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Baseline Correction of Acceleration Time Histories %%%
%%%                By: Christopher Wong                %%%
%%%                crswong888@gmail.com                %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% This is a demonstration of how the 'discreteFourierTransform()' function can be invoked in
%%% different ways for different types of signals. This script does not have a regression test
%%% because of the randomness introduced to some of the variables.

clear all %#ok<CLALL>
format longeng
fprintf('\n')

addpath('functions')


%// define a time domain and a uniform timestep size
T = [-5, 5];
dt = 0.005; % appropriate time step size for 20 Hz that should be able to accomodate corruptions

%// define an anonymous ATH handle composed of a sine and cosine wave
ATH = @(t) 5 * sin(4 * pi * t) - 3 * cos(40 * pi * t);

%// CASE 1A: uniformly discretized ATH 
t = generate1DGridPoints(T(1), T(2), dt);
u = arrayfun(ATH, t);

%// CASE 1B: uniformly discretized corrupted ATH
nu = u + norm(u, 'inf') * randn(size(u));

%// CASE 2A: semi-uniformly discretized ATH
sut = sort(t + 10 * dt * dt * randn(size(t))); % sort to ensure time is strictly increasing
while (length(unique(sut)) ~= length(t)) % also ensure every value instant is unique
    sut = sort(t + 10 * dt * dt * randn(size(t)));
end
suu = arrayfun(ATH, sut);

%// CASE 2B: semi-uniformly discretized corrupted ATH
nsuu = suu + norm(suu, 'inf') * randn(size(suu));

%// CASE 3A: nonuniformly discretized ATH
nut = [generate1DGridPoints(T(1), 0, dt / 10), generate1DGridPoints(dt, T(2), dt)];
nuu = arrayfun(ATH, nut);

%// CASE 3B: nonuniformly discretized corrupted ATH
nnuu = nuu + norm(nuu, 'inf') * randn(size(nuu));

%// invoke the DFT function on each case (and try different combinations w/ other various params):
%/ CASE 1
[f, uo] = discreteFourierTransform(t, u);
[T, nuo] = discreteFourierTransform(t, nu, 'FrequencyType', 'periodic');

%/ CASE 2
[suf, suuo] = discreteFourierTransform(sut, suu, 'Distribution', 'semiuniform', 'Domain', [0, 50]);
[suomega, nsuuo] = discreteFourierTransform(sut, nsuu, 'Distribution', 'semiuniform',...
                                            'FrequencyType', 'angular');
                                             
%/ CASE 3
[nuT, nuuo] = discreteFourierTransform(nut, nuu, 'Distribution', 'nonuniform',... 
                                       'FrequencyType', 'periodic', 'Domain', [0.04, 10]);
[nuomega, nnuuo] = discreteFourierTransform(nut, nnuu, 'Distribution', 'nonuniform',... 
                                            'FrequencyType', 'angular', 'Domain', [0; 50 * pi]);