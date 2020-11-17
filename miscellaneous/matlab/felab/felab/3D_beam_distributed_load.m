%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FE Environment for Solid Mechanics %%%
%%%        By: Christopher Wong        %%%
%%%        crswong888@gmail.com        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% 

clear all %#ok<CLALL>
format longeng
fprintf('\n')

addpath(genpath('functions'))


%%% INPUT PARAMETERS
%%% ------------------------------------------------------------------------------------------------

%%% devel note: make this a rotated beam with a constant distributed force inducing strong-axis
%%% bending (unto the rotated y-axis)

%// input boolean of active degrees of freedom, dof = ux, uy, uz, rx, ry, rz
isActiveDof = logical([1, 1, 1, 1, 1, 1]);

%// node table (coordinates in centimeters)
ID = [1; 2; 3];
x = [75; 0; -75];
y = [100; 0; -100];
z = [-300; 0; 300];
nodes = table(ID, x, y, z);
clear ID x y z

%// element connectivity
ID = [1; 2];
n1 = [1; 2];
n2 = [2; 3];
elements = table(ID, n1, n2);
clear ID n1 n2

%// element properties
E = 20e+03; % kN/cm/cm, Young's modulus
nu = 0.3; % Poisson's ratio
A = 720; % cm^2, cross-sectional area
Iyy = 19.44e+03; %cm^4, moment of inertia about elastic neutral y-axis
Izz = 96e+03; % cm^4, moment of inertia about elastic neutral z-axis
J = 290.4e+03; % cm^4, polar moment of inertia
kappa = 10 * (1 + nu) / (12 + 11 * nu); % Timoshenko shear coefficient (rectangles)
local_y = -1 / 65 * [36, 48, 25]; % unit vector in global coordinates definining local y-axis

%// force data, Fx, Fy, Mz, x, y
force_data = distributeBeamForce(nodes, elements, 1, 10);