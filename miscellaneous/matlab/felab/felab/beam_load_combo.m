%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FE Environment for Solid Mechanics %%%
%%%        By: Christopher Wong        %%%
%%%        crswong888@gmail.com        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% This is a model of simple Timoshenko beam similar to 'SB2D2_test.m', but, in addition to the
%%% concentrated force, there is a uniformly distributed load along the entire span. The result 
%%% produced here matches the analytical solution for the maximumum deflection of 0.8330 cm exactly.
%%% The displacement interpolations used for plotting are analytically exact at every real point in 
%%% the mesh space, since the deflection due to a continuous transverse force is superposed onto the
%%% standard IIE shape functions between nodes

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
nu = 0.3; % Poisson's ratio
A = 720; % cm^2, cross-sectional area
I = 96e+03; % cm^4, second moment of area
kappa = 10 * (1 + nu) / (12 + 11 * nu); % Timoshenko shear coefficient (rectangles)

%// force data, Fx, Fy, Mz, x, y
P = -175; % kN, concentrated load
W = -0.25; % kN/cm, uniformly distributed load
force_data = [0, P, 0, nodes{2,2:3};
              distributeBeamForce(nodes, elements, 1, W);
              distributeBeamForce(nodes, elements, 2, W)];

%// input restrained dof data = logical and coordinates (release = 0, restrain = 1)
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

%// compute Timoshenko beam local stiffness matrix
[k, k_idx] = computeSB2D2Stiffness(mesh, isActiveDof, E, nu, A, I, kappa);

%// determine size of global system of equations and index offsets for active DOFs
[num_eqns, real_idx_diff] = checkActiveDofIndex(nodes, num_dofs, k_idx);

%// assemble global stiffness matrix
K = assembleGlobalStiffness(num_eqns, real_idx_diff, k, k_idx);

%// assemble global force vector
F = assembleGlobalForce(num_dofs, num_eqns, real_idx_diff, forces);

%// apply boundary conditions and solve for displacements and reactions
[Q, R] = systemSolve(num_dofs, num_eqns, real_idx_diff, supports, K, F);


%%% POSTPROCESSING
%%% ------------------------------------------------------------------------------------------------

render2DSolution(nodes, mesh, 'SB2D2', num_dofs, real_idx_diff, Q, 'ScaleFactor', 25,... 
                 'SamplesPerEdge', 6, 'BeamForceElementID', [1, 2], 'BeamForce', [W, W],... 
                 'FlexRigidity', E * I, 'ShearRigidity', kappa * E / (2 + 2 * nu) * A)