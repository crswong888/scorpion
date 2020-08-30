%%% TEST 1: Model of a Rigid Cantilever Beam

clear all
format longeng
fprintf('\n') % Command Window output formatting

addpath('../functions')
addpath('test1_files')


%%% INPUT PARAMETERS
%%% ------------------------------------------------------------------------------------------------

% NOTE: csv files with mesh discretization or BC information must (and should) have column headers
% but they need not match the ones shown here, leave first row blank if nothing else

%// input boolean of active degrees of freedom, dof = ux, uy, uz, rx, ry, rz
isActiveDof = logical([1, 1, 0, 0, 0, 1]);

%// node file headers: 'ID', 'x-coord', 'y-coord'
node_file = 'test1_nodes.csv';

%// element file headers: 'ID', 'node i', 'node j', 'E', 'A', 'I'
elem_file = 'test1_elements.csv';

%// force file headers: 'ID', 'node', 'Fz', 'Fy', 'Mz'
force_file = 'test1_forces.csv';

%// supports file headers: 'ID', 'node', 'ux', 'uy', 'rz' (0=release 1=restrain)
support_file = 'test1_supports.csv';

%// rigid beam constraint file headers: 'ID', 'master node', 'slave node'
constraint_file = 'test1_rigid_beams.csv';

%// input penalty coefficient to use for solving system of equations and enforcing constraints
penalty = 1e+08;


%%% SOURCE COMPUTATIONS
%%% ------------------------------------------------------------------------------------------------

%// read mesh and BC info from input files
file_varnames = { 'node_file', 'elem_file', 'force_file', 'support_file', 'constraint_file' }; 
[nodes, elements, forces, supports, constraints] = readInputs(file_varnames); clear file_varnames

%// convert element-node connectivity info and properties to numeric arrays
[mesh, props] = generateMesh(nodes, elements, 2, 2);

%// compute beam element local stiffness matrix
[k, k_idx] = computeB2D2Stiffness(mesh, props, isActiveDof);

%// compute rigid beam element local stiffness matrix
C = max(abs(k),[],'all') * penalty; % determine penalty stiffness as max Kij times coefficient
[kc, kc_idx] = computeRB2D2Stiffness(constraints, nodes, C, isActiveDof);

%// store the number of dofs per node for more concise syntax
num_dofs = length(isActiveDof(isActiveDof));

%// determine wether a global dof is truly active based on element stiffness contributions
[num_eqns, real_idx_diff] = checkActiveDofIndex(num_dofs, length(nodes{:,1}), {k_idx, kc_idx});

%// assemble the global stiffness matrix
K = assembleGlobalStiffness(num_eqns, real_idx_diff, {k, kc}, {k_idx, kc_idx});

%// compute global force vector
F = assembleGlobalForce(num_dofs, num_eqns, real_idx_diff, forces);

%// apply the boundary conditions and solve for the displacements and reactions
[q, R] = systemSolve(num_dofs, num_eqns, real_idx_diff, supports, K, F);