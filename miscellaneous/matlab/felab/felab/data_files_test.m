%%% This test demonstrates how to read inputs from a data delimited file. The problem being solved
%%% is a cantileverd beam subject to a concentrated force at its free end.

clear all %#ok<CLALL>
format longeng
fprintf('\n')

addpath('functions')
addpath('data_files')


%%% INPUT PARAMETERS
%%% ------------------------------------------------------------------------------------------------

%// input boolean of active degrees of freedom, dof = ux, uy, uz, rx, ry, rz
isActiveDof = logical([1, 1, 0, 0, 0, 1]);

%// node file headers: 'ID', 'x-coord', 'y-coord'
node_file = 'nodes.csv';

%// element file headers: 'ID', 'node i', 'node j', 'E', 'A', 'I'
elem_file = 'elements.csv';

%// element properties
E = 200e+09; % N/m/m, Young's modulus
A = 0.01761; % m^2, cross-sectional area
I = 0.8616e-04; % m^4, second moment of area

%// force file headers: 'ID', 'node', 'Fz', 'Fy', 'Mz'
force_file = 'forces.csv';

%// supports file headers: 'ID', 'node', 'ux', 'uy', 'rz' (0=release 1=restrain)
support_file = 'supports.csv';

%// read mesh and BC info from input files
file_varnames = { 'node_file', 'elem_file', 'force_file', 'support_file' }; 
[nodes, elements, forces, supports] = readInputs(file_varnames); 
clear file_varnames


%%% SOURCE COMPUTATIONS
%%% ------------------------------------------------------------------------------------------------

%// store number of dofs per node for more concise syntax
num_dofs = length(isActiveDof(isActiveDof));

%// convert element-node connectivity info and properties to numeric arrays
mesh = generateMesh(nodes, elements);

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