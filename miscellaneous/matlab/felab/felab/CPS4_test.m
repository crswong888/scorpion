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

addpath(genpath('functions'))


%%% INPUT PARAMETERS
%%% ------------------------------------------------------------------------------------------------

%// input boolean of active degrees of freedom, dof = ux, uy, uz, rx, ry, rz
isActiveDof = logical([1, 1, 0, 0, 0, 0]);

%// input mesh discretization parameters
Lx = 0.2; Nx = 8; Ly = 2.5; Ny = 100;

%%% devel
Lx = 0.2; Nx = 4; Ly = 2.47371; Ny = 50;

%// element properties
E = 200e+06; % kPa, Young's modulus of steel
nu = 0.3; % Poisson's Ratio of steel
t = 0.1; % m, thickness of cross-section

%// generate a QUAD4 mesh
[nodes, elements] = createRectilinearMesh('QUAD4', 'Lx', Lx, 'Nx', Nx, 'Ly', Ly, 'Ny', Ny);

%// input concentrated force data = dof magnitude and coordinates
P = 100; % kN, the concentrated force to be distributed along the nodeset
force_data = zeros(Nx + 1, 4);
force_data(1,1) = P / Nx / 2; 
force_data(end,1) = force_data(1,1);
force_data(2:(end - 1),1) = P / Nx;
force_data(:,4) = Ly / 2;
for i = 2:(Nx + 1) 
    force_data(i,3) = force_data((i - 1),3) + Lx / Nx; 
end

%// input restrained dof data = logical and coordinates (release = 0, restrain = 1)
support_data = zeros(2 * Nx + 2, 4);
support_data(:,1:2) = 1;
support_data((Nx + 2):end,4) = Ly;
for i = 2:(Nx + 1)
    support_data(i,3) = support_data((i - 1),3) + Lx / Nx; 
end
support_data((Nx + 2):end,3) = support_data(1:(Nx + 1),3);

             
%%% SOURCE COMPUTATIONS
%%% ------------------------------------------------------------------------------------------------

%// store number of dofs per node for more concise syntax
num_dofs = length(isActiveDof(isActiveDof));

%// convert element-node connectivity info and properties to numeric arrays
mesh = generateMesh(nodes, elements);

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
[Q, R] = systemSolve(num_dofs, num_eqns, real_idx_diff, supports, K, F);


%%% POSTPROCESSING
%%% ------------------------------------------------------------------------------------------------

%%% we would need some sort of of 3D equivalent for this with L, W, H - do 3D in separate function

%%% I might need to seriously increase the load for this problem so I don't have to apply such a
%%% huge scale factor. Or switch up the mat/geo props so its not so stiff, either or

%%% perhaps all of the different plot object titles could be customized too, but def set defaults

%%% if i get crazy and do a full 2 coloring and then like fill in colors with edge face colors and 
%%% shit (i.e., same way the gradient works), I could include a 'surface', and then other ones too
%%% like 'surface with edges', 'wireframe', and 'points'. I literrally already got the last 2.

%%% edges need to be colored too, but when the option is 'surface with edges', don't color them
%%% make sure uncolored edges render on top of the colored surface and that they dont blend
%%% for 'wireframe', don't show nodes for this option. Do show them, uncolored, for surface & edges
%%% 'wirframe' lines should be a bit thicker than in 'surface with edges' tho
%%% 'points' is only nodes, and they need to be colored, and they probably should be FAT fat
%%% one plot style could be 'undeformed', just dges and nodes uncolored in original positions

%%% contours = true/false could also be an option

%%% element_types will need to be an input parameter unfortunately. thats how I will determine the
%%% shape functions to use, among other things

%%% if the number of nodes is only 2, then 'wireframe', 'surface', and 'surface with edges' all
%%% produce the same result: a colored line with uncolored nodes. 'points' is the same

%%% if style = points, else if nodes == 2, else if style = 'wireframe', else if style == ...

%%% the default plot style shall be 'surface with edges', which won't have any affect on 2-pointers

%%% might even need a different function for beam plots specificially because the spatial
%%% interpolation is quite different

%%% line interpolation, quad interpolation, hex interpolation, ...



%%% temporary input params
ele_blk = {mesh};
nodes = nodes;
scale = 250; % you can just put 0 here and get undisplaced mesh - default value will be 1
data_pts = 3;
% Component
% element type
% object titles
% plot style
% contours


%// This process could potentially take more than a few moments, so let its user know its working.
fprintf('Generating plot... ')

%// convenience variables
num_nodes = length(nodes{:,1});
num_blocks = length(ele_blk);
num_elems = zeros(1, num_blocks);
for b = 1:num_blocks
    num_elems(b) = length(ele_blk{b}(:,1));
end

%// Retrieve nodal values and displace original mesh
displaced_nodes = zeros(num_nodes, 2);
field = zeros(num_nodes, 1);
for i = 1:num_nodes
    %/ Determine DOF positions in global displacement index
    idx = num_dofs * (i - 1) + [1; 2];
    real_idx = idx - real_idx_diff(idx);
    
    %/ apply scaled displacements to nodes and get their new positions
    displaced_nodes(i,:) = nodes{i,([1, 2] + 1)} + transpose(scale * Q(real_idx));
    
    %/ get desired nodal displacement value
    % if magnitude, else, field...
    field(i) = norm(Q(real_idx));
end

%// interpolate displacement field through elements and get their nodal connectivity
coords = cell(2, num_blocks);
subfield = cell(1, num_blocks);
connectivity = cell(1, num_blocks);

%/ set up element interpolation grid in natural coordinate system
dxi = 2 / (data_pts - 1);
xi = -1:dxi:1;
eta = -1:dxi:1;

%/ loop through all blocks domains
for b = 1:num_blocks
    %/ initialize element data
    coords{1,b} = zeros(data_pts, data_pts, num_elems(b));
    coords{2,b} = zeros(data_pts, data_pts, num_elems(b));
    subfield{b} = zeros(data_pts, data_pts, num_elems(b));
    
    %/ displacement index
    q_idx = zeros(2 * length(ele_blk{b}(1,:)) / 3, 1);
    u_idx = 1:2:length(q_idx);
    v_idx = u_idx + 1;
    
    %/ loop through all elements on block
    for e = 1:num_elems(b)
        %/ global node IDs and coordinates
        nodeIDs = transpose(mesh(e,1:3:end));
        
        % ---------
        % if contours
        xy = transpose([mesh(e,2:3:end); mesh(e,3:3:end)]);
        
        %/ retrieve the nodal displacements from global index
        q_idx(u_idx) = num_dofs * (nodeIDs - 1) + 1;
        q_idx(v_idx) = q_idx(u_idx) + 1;
        q = Q(q_idx - real_idx_diff(q_idx));
        
        %/ use shape functions to interpolate nodal displacements to specified grid points
        for i = 1:data_pts
            for j = 1:data_pts
                % evaluate shape functions and get displacement values
                N = evaluateCPS4ShapeFun(xi(i), eta(j));
                u = N * q(u_idx);
                v = N * q(v_idx);
                
                % apply scaled displacements to grid points and get their new positions
                coords{1,b}(i,j,e) = N * xy(:,1) + scale * u;
                coords{2,b}(i,j,e) = N * xy(:,2) + scale * v;
                
                %/ get desired nodal displacement value
                % if magnitude, else, subfield...
                subfield{b}(i,j,e) = norm([u, v]);
            end
        end
        
        %/ get element connectivity lines on each block for wireframe and edges plots
        connectivity{b}(:,:,e) = displaced_nodes([nodeIDs; nodeIDs(1)],:);
    end
end

%// Generate a figure window with a nominal plot axes
figure('Units', 'normalize', 'Position', [0.125, 0.25, 0.75, 0.75])
ax = axes('Position', [0.05, 0.05, 0.9, 0.9], 'Layer', 'top');

%/ plot nodes to at least intialize a plot space - show/hide them depending on plot style
plot(displaced_nodes(:,1), displaced_nodes(:,2), 'o', 'markerfacecolor', 'w', 'markersize', 3.5)
hold on

% if points, need to add color to connectivity

%/ loop through mesh blocks and plot each element
% ~points
for b = 1:num_blocks
    for e = 1:num_elems(b)
        
        % set contour colors for desired field component at each sample point
        % if contours
        for i = 1:(data_pts - 1)
            for j = 1:(data_pts - 1)
                % set up plot vertices in a closed polygon fashion so patch object can be used
                sample_x = [coords{1,b}(i,j,e),...
                            coords{1,b}((i + 1),j,e),...
                            coords{1,b}((i + 1),(j + 1),e),...
                            coords{1,b}(i,(j + 1),e)];
                        
                sample_y = [coords{2,b}(i,j,e),...
                            coords{2,b}((i + 1),j,e),...
                            coords{2,b}((i + 1),(j + 1),e),...
                            coords{2,b}(i,(j + 1),e)];
                        
                sample_val = [subfield{b}(i,j,e),...
                              subfield{b}((i + 1),j,e),...
                              subfield{b}((i + 1),(j + 1),e),...
                              subfield{b}(i,(j + 1),e)];
                
                % if a surface plot, color whole element, else, just edges
                p = patch(sample_x, sample_y, 'k', 'Parent', ax);
                set(p, 'CData', sample_val, 'FaceColor', 'interp', 'CDataMapping', 'scaled', 'EdgeColor', 'none');
            end
        end
        
        % if surface with edges or wireframe with no contours
        plot(connectivity{b}(:,1,e), connectivity{b}(:,2,e), 'Color', 'w')
    end
end

%// define color mapping system for plot contours
colormap jet(128)
c = colorbar;
ylabel(c, 'Real Displacement Magnitude')
set(ax, 'CLim', [min(field), max(field)])

%/ set up plot space with a 1:1 ratio for both dimensions
set(ax, 'Units', 'pixels');
resolution = [max(ax.Position(3:4)); min(ax.Position(3:4))]; % current resolution of axes window
set(ax, 'Units', 'normalize') % convert it back so window scaling continues to work

% determine spatial extents of displaced mesh
extents = zeros(2, 4);
extents(:, 1) = 1:2;
for s = 1:2
    extents(s, 2) = min(displaced_nodes(:,s));
    extents(s, 3) = max(displaced_nodes(:,s));
end
extents(:,4) = extents(:,3) - extents(:,2);
[~, smax] = max(extents(:,4));

% determine a grid tick spacing for long dimension that conforms well to extents of displaced domain
lowest = Inf;
for i = 10:20 % minum of 10 increments and a maximum of 20
    for m = [5, 2, 1] % some order of magnitude of a multiple 5 is best, 2 is okay, and 1 not best
        % test a grid spacing and see how close it gets to an integer division (nice and clean)
        commdom = m * 10^(sign(log10(extents(smax,4) / i)) * floor(abs(log10(extents(smax,4) / i)) + 2));
        remainder = abs(extents(smax,4) - round(extents(smax,4) / i / commdom) * commdom * i);
        
        % attempt to find a number of divisions that comes closest to covering entire extent
        if (remainder < lowest)
            lowest = remainder;
            dx = round(extents(smax,4) / i / commdom) * commdom;
            Nx = i;
        end
    end
end

% offset extents to have a uniform empty spacing around displaced mesh domain - this preserves scale
offset = max(dx, abs(((extents(smax,4) + 2 * dx) .* resolution / resolution(smax) - extents(:,4)) / 2));
lims(:,1) = extents(:,2) - offset;
lims(:,2) = extents(:,3) + offset;

% set up grid points in extended space and 10 more points in all directions beyond
grid = {(round(lims(1,1) / dx) * dx - 10 * dx):dx:(round(lims(1,2) / dx) * dx + 10 * dx);
        (round(lims(2,1) / dx) * dx - 10 * dx):dx:(round(lims(2,2) / dx) * dx + 10 * dx)};

% set properties for axis object
set(ax, 'XLim', lims(1,:), 'XTick', grid{1}, 'YLim', lims(2,:), 'YTick', grid{2}, 'Layer', 'top')

%/ set gradient background
bgx = [lims(1,1), lims(1,2), lims(1,2), lims(1,1)]; % coordinates of extended plot space vertices
bgy = [lims(2,1), lims(2,1), lims(2,2), lims(2,2)];

% I call this color scheme "Shallow Ocean" haha I'm silly XD
cdata(1,1,:) = [0.173, 0.349, 0.529]; % bottom RGB
cdata(1,2,:) = [0.173, 0.349, 0.529];
cdata(1,3,:) = [0.475, 0.647, 0.827]; % top RGB
cdata(1,4,:) = [0.475, 0.647, 0.827];

% create a patch object to render gradient
p = patch(bgx, bgy, 'k', 'Parent', ax);
set(p, 'CData', cdata, 'FaceColor','interp', 'EdgeColor', 'none');
uistack(p, 'bottom') % Put gradient underneath everything else

%// all done :)
fprintf('Done.\n\n')
