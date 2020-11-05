%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FE Environment for Solid Mechanics %%%
%%%        By: Christopher Wong        %%%
%%%        crswong888@gmail.com        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Test for the R2D2 rigid link element
%%% The truss structure forms a 10'x10' equilateral triangle that is pin-supported at 2 of its
%%% points and a very large load is applied to the apex point. Despite the load being very large (1
%%% million pounds), the 2 truss members should not deform.

clear all %#ok<CLALL>
format longeng
fprintf('\n')

addpath(genpath('functions'))


%%% INPUT PARAMETERS
%%% ------------------------------------------------------------------------------------------------

%// input boolean of active degrees of freedom, dof = ux, uy, uz, rx, ry, rz
isActiveDof = logical([1, 1, 0, 0, 0, 0]);

%// node table (coordinates in inches)
ID = [1; 2; 3];
x = [0; 120; 60];
y = [0; 0; 120];
nodes = table(ID, x, y);
clear ID x y

%// element connectivity
ID = [1; 2];
n1 = [1; 3];
n2 = [3; 2];
elements = table(ID, n1, n2);
clear ID n1 n2

%// force data, Fx, Fy, x, y
force_data = [0, -1e+06, nodes{3,2:3}]; % forces in lb

%// input the restrained dof data = logical and coordinates (release = 0, restrain = 1)
support_data = [1, 1, nodes{1,2:3};
                1, 1, nodes{2,2:3}];


%%% SOURCE COMPUTATIONS
%%% ------------------------------------------------------------------------------------------------

%// store number of dofs per node for more concise syntax
num_dofs = length(isActiveDof(isActiveDof));

%// convert element-node connectivity info and properties to numeric arrays
mesh = generateMesh(nodes, elements);

%// generate tables storing nodal forces and restraints
[forces, supports] = generateBCs(nodes, force_data, support_data, isActiveDof);

%// compute link element local stiffness matrix (if penalty not provided - default value assumed)
[k, k_idx] = computeR2D2Stiffness(mesh, isActiveDof);

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

render2DSolution(nodes, mesh, 'R2D2', num_dofs, real_idx_diff, Q, 'style', 'wireframe')