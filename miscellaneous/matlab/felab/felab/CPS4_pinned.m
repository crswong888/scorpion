%%% Similar CPS4_test.m, but models a simply supported beam by constraining the boundaries to remain
%%% plane using RB2D2 elements, while only pinning the central node. Thus, this is also a
%%% demonstration of how to use multiple element types in a single model.
%%%
%%% The max deflections in accordance with Euler-Bernoulli and Timoshenko Beam theories are 
%%% 1.6200e-03 m and 1.6544e-03 m, respectively. The max deflection computed here is 1.64720e-03 m
%%% and so the model lines up with the theory. Also, the vertical reactions at each pin are P / 2, 
%%% and the horizontal reactions are zero, as expected.

clear all %#ok<CLALL>
format longeng
fprintf('\n')

addpath('functions')


%%% INPUT PARAMETERS
%%% ------------------------------------------------------------------------------------------------

%// input boolean of active degrees of freedom, dof = ux, uy, uz, rx, ry, rz
isActiveDof = logical([1, 1, 0, 0, 0, 1]);

%// input CPS4 mesh discretization parameters
Lx = 3.0; Nx = 120; Ly = 0.25; Ny = 10;

%// input CPS4 material properties
E = 200e+06; % kPa, Young's modulus of steel
nu = 0.3; % Poisson's Ratio of steel
t = 0.1; % m, thickness of cross-section

%// generate a QUAD4 mesh for a simple, rectangular domain
[nodes1, elems1] = createRectilinearMesh('QUAD4',...
    'Lx', Lx, 'Nx', Nx, 'Ly', Ly, 'Ny', Ny, 'E', E, 'nu', nu, 't', t);

%// generate RB2D2 nodes
nodes2 = zeros(2 * (Ny + 1), 3);
nodes2(:,1) = transpose(1:length(nodes2));
nodes2((Ny + 2):end,2) = Lx;
for i = 2:(Ny + 1)
    nodes2(i,3) = (i - 1) * (Ly / Ny);
end
nodes2((Ny + 2):end,3) = nodes2(1:(Ny + 1),3);
nodes2 = array2table(nodes2, 'VariableNames', {'ID', 'x', 'y'});

%// generate RB2D2 element connectivity
elems2 = zeros(2 * Ny, 4);
elems2(:,1) = transpose(1:length(elems2));
for i = 1:Ny
    elems2(i,2) = i;
    elems2(i,3) = i + 1;
end
elems2((Ny + 1):end,2:3) = elems2(1:Ny,2:3) + 11;

%/ append penalty stiffness to elements and convert to table array
elems2(:,4) = 1e+08;
elems2 = array2table(elems2, 'VariableNames', {'ID', 'n1', 'n2', 'penalty'});

%// consolidate coincident nodes between meshes
[nodes, blocks] = stitchBlocks({nodes1, nodes2}, {elems1, elems2}, [4, 2]);

%// input the distributed point force data = dof magnitude and coordinates
P = -75; % kN, the concentrated force to be distributed along the nodeset
force_data = zeros(Ny+1,5);
force_data(1,2) = P / Ny / 2; force_data(end,2) = force_data(1,2);
force_data(2:end-1,2) = P / Ny;
force_data(:,4) = Lx / 2;
for i = 2:(Ny+1), force_data(i,5) = force_data(i-1,5) + Ly / Ny; end

%// input the restrained dof data = logical and coordinates (release = 0, restrain = 1)
support_data = [1, 1, 0, 0.0, Ly / 2;
                1, 1, 0, Lx, Ly / 2];


%%% SOURCE COMPUTATIONS
%%% ------------------------------------------------------------------------------------------------

%// store number of dofs per node for more concise syntax
num_dofs = length(isActiveDof(isActiveDof));

%// convert element-node connectivity info and properties to numeric arrays on all blocks
[mesh1, props1] = generateMesh(nodes, blocks{1}, 4);
[mesh2, props2] = generateMesh(nodes, blocks{2}, 2);

%// generate tables storing nodal forces and restraints
[forces, supports] = generateBCs(nodes, force_data, support_data, isActiveDof);

%// compute stiffness matrices of all elements on each block
[k1, k1_idx] = computeCPS4Stiffness(mesh1, props1, isActiveDof);
[k2, k2_idx] = computeRB2D2Stiffness(mesh2, isActiveDof, 'penalty', props2);

%// determine wether a global dof is truly active based on element stiffness contributions
[num_eqns, real_idx_diff] = checkActiveDofIndex(nodes, num_dofs, {k1_idx, k2_idx});

%// assemble the global stiffness matrix
K = assembleGlobalStiffness(num_eqns, real_idx_diff, {k1, k2}, {k1_idx, k2_idx});

%// compute global force vector
F = assembleGlobalForce(num_dofs, num_eqns, real_idx_diff, forces);

%// apply the boundary conditions and solve for the displacements and reactions
[q, R] = systemSolve(num_dofs, num_eqns, real_idx_diff, supports, K, F, 1e-08);


%%% POSTPROCESSING
%%% ------------------------------------------------------------------------------------------------

%// deflection along length of beam
plot(q((2:3:3*Nx+3)-transpose(real_idx_diff(2:3:3*Nx+3))))