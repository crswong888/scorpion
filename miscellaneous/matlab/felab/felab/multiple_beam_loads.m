%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FE Environment for Solid Mechanics %%%
%%%        By: Christopher Wong        %%%
%%%        crswong888@gmail.com        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Example 8.2 from Chandrupatla, "Introduction to Finite Elements in Engineering, 2nd edition"
%%% This solves a fixed portal frame structure subject to a lateral concentrated force and a
%%% transverse uniformly distributed force at the second level. The results for the deflections
%%% and rotations match those given by Chandrupatla

clear all %#ok<CLALL>
format longeng
fprintf('\n')

addpath(genpath('functions'))


%%% INPUT PARAMETERS
%%% ------------------------------------------------------------------------------------------------

%// input boolean of active degrees of freedom, dof = ux, uy, uz, rx, ry, rz
isActiveDof = logical([1, 1, 0, 0, 0, 1]);

%// node table (coordinates in centimeters)
ID = [1; 2; 3];
x = [-325; 0; 325];
y = [0; 0; 0];
nodes = table(ID, x, y);
clear ID x y

%// element connectivity
ID = [1; 2];
n1 = [1; 2];
n2 = [2; 3];
elements = table(ID, n1, n2);
clear ID n1 n2

%// element properties
E = 20e+03; % kN/cm/cm, Young's modulus
A = 720; % cm^2, cross-sectional area
I = 96e+03; % cm^4, second moment of area

%// force data, Fx, Fy, Mz, x, y
P = -175; % kN, concentrated load
W = -0.25; % kN/cm, uniformly distributed load
force_data = [0, P, 0, nodes{2,2:3};
              distributeBeamForce(nodes, elements, 1, W);
              distributeBeamForce(nodes, elements, 2, W)];

%// input the restrained dof data = logical and coordinates (release = 0, restrain = 1)
support_data = [1, 1, 0, nodes{1,2:3};
                1, 1, 0, nodes{3,2:3}];


%%% SOURCE COMPUTATIONS
%%% ------------------------------------------------------------------------------------------------

%// store number of dofs per node for more concise syntax
num_dofs = length(isActiveDof(isActiveDof));

%// convert element-node connectivity info and properties to numeric arrays
mesh = generateMesh(nodes, elements);

%// generate tables storing nodal forces and restraints
[forces, supports] = generateBCs(nodes, force_data, support_data, isActiveDof);

%// compute beam local stiffness matrix
[k, k_idx] = computeB2D2Stiffness(mesh, isActiveDof, E, A, I);

%// determine wether a global dof is truly active based on element stiffness contributions
[num_eqns, real_idx_diff] = checkActiveDofIndex(nodes, num_dofs, k_idx);

%// assemble the global stiffness matrix
K = assembleGlobalStiffness(num_eqns, real_idx_diff, k, k_idx);

%// compute global force vector
F = assembleGlobalForce(num_dofs, num_eqns, real_idx_diff, forces);

%// apply the boundary conditions and solve for the displacements and reactions
[Q, R] = systemSolve(num_dofs, num_eqns, real_idx_diff, supports, K, F);


%%% POSTPROCESSING
%%% ------------------------------------------------------------------------------------------------

render2DSolution(nodes, mesh, 'B2D2', num_dofs, real_idx_diff, Q, 'ScaleFactor', 25,...
                 'SamplesPerEdge', 3, 'BeamForceElementID', [1, 2], 'BeamForce', [W, W])