%%% Similar CPS4_test.m, but models a simply supported beam by constraining the boundaries to remain
%%% plane using RB2D2 elements, while only pinning the central node. Thus, this is also a
%%% demonstration of how to use multiple element types in a single model.
%%%
%%% 

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
[cps4_nodes, cps4_elements] = createRectilinearMesh('QUAD4',...
    'Lx', Lx, 'Nx', Nx, 'Ly', Ly, 'Ny', Ny, 'E', E, 'nu', nu, 't', t);

%// generate RB2D2 nodes
rb2d2_nodes = zeros(2 * (Ny + 1), 3);
rb2d2_nodes(:,1) = transpose(1:length(rb2d2_nodes));
rb2d2_nodes((Ny + 2):end,2) = Lx;
for i = 2:(Ny + 1)
    rb2d2_nodes(i,3) = (i - 1) * Ly;
end
rb2d2_nodes((Ny + 2):end,3) = rb2d2_nodes(1:(Ny + 1),3);
rb2d2_nodes = array2table(rb2d2_nodes, 'VariableNames', {'ID', 'x', 'y'});

%// generate RB2D2 element connectivity
rb2d2_elements = zeros(2 * Ny, 4);
rb2d2_elements(:,1) = transpose(1:length(rb2d2_elements));
for i = 1:Ny
    rb2d2_elements(i,2) = i;
    rb2d2_elements(i,3) = i + 1;
end
rb2d2_elements((Ny + 1):end,2:3) = rb2d2_elements(1:Ny,2:3) + 11;

%/ append penalty stiffness to elements and convert to table array
rb2d2_elements(:,4) = 1e+09;
rb2d2_elements = array2table(rb2d2_elements, 'VariableNames', {'ID', 'n1', 'n2', 'penalty'});

%// consolidate coincident nodes between meshes
[nodes, cps4_elements, rb2d2_elements] = stitchMesh({cps4_nodes, rb2d2_nodes},...
                                                    {cps4_elements, rb2d2_elements}, [4, 2]);
    
error(' ')

% NOTE: to plot the displacement, transverse displacement, run something like:
% plot(q((2:3:3*Nx+3)-transpose(real_idx_diff(2:3:3*Nx+3))))

%%% SOURCE COMPUTATIONS
%%% ------------------------------------------------------------------------------------------------

%// generate tables storing nodal forces and restraints
[forces, supports] = generateBCs(cps4_nodes, force_data, support_data);
constraints = generateConstraints(cps4_nodes, rb2d2_nodes);
clear force_data support_data constraint_data

%// convert element-node connectivity info and properties to numeric arrays
[mesh, props] = generateMesh(cps4_nodes, cps4_elements, 2, 4);

%// compute plane stress QUAD4 element local stiffness matrix
[k, k_idx] = computeCPS4Stiffness(mesh, props, isActiveDof);

%// compute rigid beam element local stiffness matrix
% TODO: this actually isn't the max we want, we want the max from the
% global matrix that is assembled from only the QUAD4 part of the mesh
C = max(abs(k),[],'all') * penalty; % determine penalty stiffness as max Kij times coefficient
[kc, kc_idx] = computeRB2D2Stiffness(constraints, cps4_nodes, C, isActiveDof);

%// store the number of dofs per node for more concise syntax
num_dofs = length(isActiveDof(isActiveDof));

%// determine wether a global dof is truly active based on element stiffness contributions
[num_eqns, real_idx_diff] = checkActiveDofIndex(num_dofs, length(cps4_nodes{:,1}), {k_idx, kc_idx});

%// assemble the global stiffness matrix
K = assembleGlobalStiffness(num_eqns, real_idx_diff, {k, kc}, {k_idx, kc_idx});

%// compute global force vector
F = assembleGlobalForce(num_dofs, num_eqns, real_idx_diff, forces);

%// apply the boundary conditions and solve for the displacements and reactions
[q, R] = systemSolve(num_dofs, num_eqns, real_idx_diff, supports, K, F);