%%% Model of a Fixed-Fixed, Slender Beam with a point load at its center using CPS4 elements
%%% The beams cross-sectional dimension relative to its length are small and loading is transverse
%%% so a plane stress formulation is appropriate
%%%
%%% The max deflections in accordance with Euler-Bernoulli and Timoshenko Beam theories are 
%%% 0.6104e-03 m and 0.6582e-03 m, respectively. The max deflection computed here is 0.6510e-03 m
%%% and so the model lines up with the theory.

clear all %#ok<CLALL>
format longeng
fprintf('\n')

addpath('functions')


%%% INPUT PARAMETERS
%%% ------------------------------------------------------------------------------------------------

%// input boolean of active degrees of freedom, dof = ux, uy, uz, rx, ry, rz
isActiveDof = logical([1, 1, 0, 0, 0, 0]);

%// input mesh discretization parameters
Lx = 2.5; Nx = 100; Ly = 0.2; Ny = 8;

%%% devel
Lx = 2.47371; Nx = 50; Ly = 0.2; Ny = 4;

%// element properties
E = 200e+06; % kPa, Young's modulus of steel
nu = 0.3; % Poisson's Ratio of steel
t = 0.1; % m, thickness of cross-section

%// generate a QUAD4 mesh
[nodes, elements] = createRectilinearMesh('QUAD4', 'Lx', Lx, 'Nx', Nx, 'Ly', Ly, 'Ny', Ny);

%// input concentrated force data = dof magnitude and coordinates
P = -100; % kN, the concentrated force to be distributed along the nodeset
force_data = zeros(Ny+1,4);
force_data(1,2) = P / Ny / 2; force_data(end,2) = force_data(1,2);
force_data(2:end-1,2) = P / Ny;
force_data(:,3) = Lx / 2;
for i = 2:(Ny+1), force_data(i,4) = force_data(i-1,4) + Ly / Ny; end

%// input restrained dof data = logical and coordinates (release = 0, restrain = 1)
support_data = zeros(2*Ny+2,4);
support_data(:,1:2) = 1;
support_data(Ny+2:end,3) = Lx;
for i = 2:(Ny + 1), support_data(i,4) = support_data(i-1,4) + Ly / Ny; end
support_data(Ny+2:end,4) = support_data(1:Ny+1,4);

             
%%% SOURCE COMPUTATIONS
%%% ------------------------------------------------------------------------------------------------

%// store number of dofs per node for more concise syntax
num_dofs = length(isActiveDof(isActiveDof));

%// convert element-node connectivity info and properties to numeric arrays
mesh = generateMesh(nodes, elements, 4);

%// generate tables storing nodal forces and restraints
[forces, supports] = generateBCs(nodes, force_data, support_data, isActiveDof);

%// compute plane stress QUAD4 element local stiffness matrix
[k, k_idx] = computeCPS4Stiffness(mesh, isActiveDof, E, nu, t);

%// determine wether a global dof is truly active based on element stiffness contributions
[num_eqns, real_idx_diff] = checkActiveDofIndex(nodes, num_dofs, k_idx);

%// assemble the global stiffness matrix
K = assembleGlobalStiffness(num_eqns, real_idx_diff, k, k_idx);

%// compute global force vector
F = assembleGlobalForce(num_dofs, num_eqns, real_idx_diff, forces);

%// apply the boundary conditions and solve for the displacements and reactions
[q, R] = systemSolve(num_dofs, num_eqns, real_idx_diff, supports, K, F);


%%% POSTPROCESSING
%%% ------------------------------------------------------------------------------------------------

%// 'reset(groot)' breaks 'DefaultFigurePosition', so store current default and manually reset
defaultFP = get(groot, 'DefaultFigurePosition');
set(groot, 'DefaultAxesPosition', [0.05, 0.05, 0.9, 0.9], 'DefaultFigureUnits', 'normalize', 'DefaultFigurePosition', [0.125, 0.25, 0.75, 0.75]);

%%% we would need some sort of of 3D equivalent for this with L, W, H
figure('Visible', 'off')
set(axes, 'Visible', 'off', 'Units', 'pixels')
ax = axes('Visible', 'off');
set(ax, 'Units', 'pixels');
resolution = [max(ax.Position(3:4)); min(ax.Position(3:4))];
close all


nodes = table2array(nodes);
num_dims = length(nodes(1,2:end));
extents = zeros(num_dims, 4);
extents(:, 1) = 1:num_dims;
for s = 1:num_dims
    extents(s, 2) = min(nodes(:,(s + 1)));
    extents(s, 3) = max(nodes(:,(s + 1)));
end
extents(:,4) = extents(:,3) - extents(:,2);
sort(extents, 4);

%%% always round to some multiple of 2, 5 or 10
%%% this is simple, I'll have to just say that if the magnitude of x is N, then I have to try and
%%% subdivide it by the closes multiples of 1eN-2, 2eN-2, 5eN-2
%%%
%%% then check how close round(x / d / 1eN-2) * 1eN-2 * d is to x for all three multiples on all 10
%%% allowable number of subdivisions.
%%%
%%% if some increment at 11 subdivisions and one at 17 subdvisions are both equally nice, use 11
%%% subdivisions Less subdivisions are better.
%%%
%%% best number is 1eN, then 5eN, finally 2eN, if all 3 multiples work, take 1eN, if the last two
%%% both work, take 5eN
lowest = Inf;
for i = 10:20
    %/ some magnitude that is a multiple of 5 is best, 2 is okay, and 1 not best
    for m = [5, 2, 1]
        commdom = m * 10^(sign(log10(extents(1,4) / i)) * floor(abs(log10(extents(1,4) / i)) + 2));
        remainder = abs(extents(1,4) - round(extents(1,4) / i / commdom) * commdom * i);
        if (remainder < lowest)
            lowest = remainder;
            dx = round(extents(1,4) / i / commdom) * commdom;
            Nx = i;
        end
    end
end

%%% finally, the offset value at either end of x shall always be dx / 2, such that the maximum
%%% offset on either side is 5% of the mesh when 10 subdivisions are used, and the minimum offest is
%%% 2.5% of the mesh when 20 subdivisions are used. It's possible that I could also use an offset of
%%% dx, sucb that I could get up to 10% whitespace on either side, but I think this is too much loss
%%% in accuracy. However, I don't know what it's gonna look like yet, so I shall try this. Perhaps
%%% it looks fine, and this would actually be preferable, since the plots would always end neatly at
%%% an increment of dx.
    
    
    
limits = zeros(num_dims, 2);
limits(:,1) = extents(:,2) - 0.05 * extents(:,4);
limits(:,2) = extents(:,3) + 0.05 * extents(:,4);

% figure(1);
% plot(nodes(:,2), nodes(:,3), 'o', 'markerfacecolor', [0, 0, 0], 'markersize', 1) % probably won't even plot nodes
% hold on




%// reset root graphics properties
reset(groot)
set(groot, 'DefaultFigurePosition', defaultFP);



% %/ aspect
% extents = [max(nodes(:,2)) - min(nodes(:,2)), max(nodes(:,3)) - min(nodes(:,3))];
% 
% resolution = 480e+03;
% width = sqrt(extents(1) * resolution / extents(2));
% if (width > 800)
%     resolution = 476.432e+03;
%     width = min(sqrt(extents(1) * resolution / extents(2)), 1024);
% end
% height = width * extents(2) / extents(1);




