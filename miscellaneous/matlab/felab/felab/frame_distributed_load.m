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

%// input boolean of active degrees of freedom, dof = ux, uy, uz, rx, ry, rz
isActiveDof = logical([1, 1, 0, 0, 0, 1]);

%%% devel note: a single-span simply supported beam with a constant distributed load
%%% devel note: eventually make this a frame (use example from text)

%// node table (coordinates in centimeters)
ID = [1; 2];
x = [0; 650];
y = [0; 0];
nodes = table(ID, x, y);
clear ID x y

%// element connectivity
elements = table(1, 1, 2);

%// element properties
E = 20e+03; % kN/cm/cm, Young's modulus
A = 720; % cm^2, cross-sectional area
I = 96e+03; % cm^4, second moment of area

%// force data, Fx, Fy, Mz, x, y
%/ initialize force_data with a distributed load on element 1
W = @(x) -sin(x); % kN/cm
%W = -2;
force_data = distributeBeamForce(nodes, elements, 1, W);