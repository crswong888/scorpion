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

%%% devel note: make this a simple beam with a distributed load and a concentrated load at its
%%% center

% %// force data, Fx, Fy, Mz, x, y
% %/ initialize force_data with a distributed load on element 1
% %W = -2;
% force_data = [0, P, 0, coords;
%               distributeBeamForce(nodes, elements, 1, W);
%               distributeBeamForce(nodes, elements, 2, W)];