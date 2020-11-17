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

%// node table (coordinates in inches)
ID = [1; 2; 3; 4];
x = [0; 12; 0; 12] * 12;
y = [8; 8; 0; 0] * 12;
nodes = table(ID, x, y);
clear ID x y

%// element connectivity
ID = transpose(1:3);
n1 = [1; 3; 4];
n2 = [2; 1; 2];
elements = table(ID, n1, n2);
clear ID n1 n2

%// element properties
E = 30e6; % psi, Young's modulus
A = 6.8; % in^2, cross-sectional area
I = 65; % in^4, second moment of area

%// force data, Fx, Fy, Mz, x, y
W = -500 / 12; % lb/in, uniformly distributed load
P = 3000;
force_data = [P, 0, 0, nodes{1,2:3};
              distributeBeamForce(nodes, elements, 1, W)];

%// input the restrained dof data = logical and coordinates (release = 0, restrain = 1)
support_data = [1, 1, 1, nodes{3,2:3};
                1, 1, 1, nodes{4,2:3}];


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

render2DSolution(nodes, mesh, 'B2D2', num_dofs, real_idx_diff, Q, 'Style', 'wireframe',...
                 'ScaleFactor', 50, 'SamplesPerEdge', 15, 'Ghost', true)