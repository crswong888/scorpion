%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FE Environment for Solid Mechanics %%%
%%%        By: Christopher Wong        %%%
%%%        crswong888@gmail.com        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Example 5.4 from McGuire, et al. (2014). "Matrix Structural Analysis." 2nd ed.
%%% This models a space truss structure in the shape of a rectangular pyramid subject to triaxial
%%% concentrated forces at the apex node. The four nodes at the base are all pinned. The results for
%%% the deflections and reactions match those given by McGuire, et al.

clear all %#ok<CLALL>
format longeng
fprintf('\n')

addpath(genpath('functions'))


%%% INPUT PARAMETERS
%%% ------------------------------------------------------------------------------------------------

%// input boolean of active degrees of freedom, dof = ux, uy, uz, rx, ry, rz
isActiveDof = logical([1, 1, 1, 0, 0, 0]);

%// node table (coordinates in millimeters)
ID = transpose(1:5);
x = [2; 0; 8; 8; 0] * 1000;
y = [4; 0; 0; 6; 6] * 1000;
z = [8; 0; 0; 0; 0] * 1000;
nodes = table(ID, x, y, z);
clear ID x y z

%// element connectivity and properties
E = 200; % kN/mm/mm

%/ block 1
elems{1} = table(1, 1, 2, 'VariableNames', {'ID', 'n1', 'n2'});
A(1) = 20e+03; % mm^2

%/ block 2
elems{2} = table([2; 4], [1; 1], [3; 5], 'VariableNames', {'ID', 'n1', 'n2'});
A(2) = 30e+03; % mm^2

%/ block 3
elems{3} = table(3, 1, 4, 'VariableNames', {'ID', 'n1', 'n2'});
A(3) = 40e+03; % mm^2

%// force data, Fx, Fy, Fz, x, y, z
force_data = [200, 600, -800, nodes{1,2:4}]; % kN

%// input restrained dof data = logical and coordinates (release = 0, restrain = 1)
support_data = [1, 1, 1, nodes{2,2:4};
                1, 1, 1, nodes{3,2:4};
                1, 1, 1, nodes{4,2:4};
                1, 1, 1, nodes{5,2:4}]; % pin nodes 2, 3, 4, 5


%%% SOURCE COMPUTATIONS
%%% ------------------------------------------------------------------------------------------------

%// store number of dofs per node for more concise syntax
num_dofs = length(isActiveDof(isActiveDof));

%// loop over blocks and store their mesh and element stiffness data in cells
mesh = cell(1, 3);
k = cell(1, 3);
k_idx = cell(1, 3);
for b = 1:3
    %/ convert element-node connectivity info and properties to numeric arrays
    mesh{b} = generateMesh(nodes, elems{b});
    
    %/ compute truss element local stiffness matrix
    [k{b}, k_idx{b}] = computeT3D2Stiffness(mesh{b}, isActiveDof, E, A(b));
end

%// generate tables storing nodal forces and restraints
[forces, supports] = generateBCs(nodes, force_data, support_data, isActiveDof);

%// determine size of global system of equations and index offsets for active DOFs
[num_eqns, real_idx_diff] = checkActiveDofIndex(nodes, num_dofs, k_idx);

%// assemble global stiffness matrix
K = assembleGlobalStiffness(num_eqns, real_idx_diff, k, k_idx);

%// assemble global force vector
F = assembleGlobalForce(num_dofs, num_eqns, real_idx_diff, forces);

%// apply boundary conditions and solve for displacements and reactions
[Q, R] = systemSolve(num_dofs, num_eqns, real_idx_diff, supports, K, F);