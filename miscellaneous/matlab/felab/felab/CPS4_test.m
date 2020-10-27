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


% %%% devel
% Lx = 0.2; Nx = 4; Ly = 2.47371; Ny = 50;
% 
% %// element properties
% E = 200e+06; % kPa, Young's modulus of steel
% nu = 0.3; % Poisson's Ratio of steel
% t = 0.1; % m, thickness of cross-section
% 
% %// generate a QUAD4 mesh
% [nodes, elements] = createRectilinearMesh('QUAD4', 'Lx', Lx, 'Nx', Nx, 'Ly', Ly, 'Ny', Ny);
% 
% %// input concentrated force data = dof magnitude and coordinates
% P = -100; % kN, the concentrated force to be distributed along the nodeset
% force_data = zeros(Nx+1,4);
% force_data(1,2) = P / Nx / 2; force_data(end,2) = force_data(1,2);
% force_data(2:end-1,2) = P / Nx;
% force_data(:,3) = Ly / 2;
% for i = 2:(Nx+1), force_data(i,4) = force_data(i-1,4) + Lx / Nx; end
% 
% %// input restrained dof data = logical and coordinates (release = 0, restrain = 1)
% support_data = zeros(2*Nx+2,4);
% support_data(:,1:2) = 1;
% support_data(Nx+2:end,3) = Ly;
% for i = 2:(Nx + 1), support_data(i,4) = support_data(i-1,4) + Lx / Nx; end
% support_data(Nx+2:end,4) = support_data(1:Nx+1,4);

             
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

%%% once all of the features are in the plot, e.g., colorbar, title, and axis labels, then we need
%%% to generate this test plot with all of those objects and finally get the axis resolution
figure('Visible', 'off', 'Units', 'normalize', 'Position', [0.125, 0.25, 0.75, 0.75])
ax = axes('Visible', 'off', 'Position', [0.05, 0.05, 0.9, 0.9]);
set(ax, 'Units', 'pixels');
resolution = [max(ax.Position(3:4)); min(ax.Position(3:4))];
close all

num_nodes = length(nodes{:,1});
num_dims = length(nodes{1,2:end});
num_blocks = 1;
num_local_nodes = 4; % length(ele_blk{b}{1,:}) / (num_dims + 1);
num_elems = length(mesh(:,1)); % length(ele_blk{b}{:,1});

ele_blk = {mesh};

% you can just put 0 here and get undisplaced mesh - default value will be 1
scale = 250;

displaced_nodes = zeros(num_nodes, num_dims);
disp_mag = zeros(num_nodes, 1);
for i = 1:num_nodes
    idx = num_dofs * (i - 1) + [1; 2];
    real_idx = idx - real_idx_diff(idx);
    displaced_nodes(i,:) = nodes{i,([1, 2] + 1)} + transpose(scale * Q(real_idx));
    disp_mag(i) = norm(Q(real_idx));
end

% % append dim ids to extents so if we swap x and y we know which is which
% extents = cat(1, transpose(1:2), transpose(range(displaced_nodes(:,1:2))));

%%% could've used range() here, but I need the min and max too for later calc, so keeping it
extents = zeros(num_dims, 4);
extents(:, 1) = 1:num_dims;
for s = 1:num_dims
    extents(s, 2) = min(displaced_nodes(:,s)); % min(nodes{:,(s + 1)});
    extents(s, 3) = max(displaced_nodes(:,s)); % max(nodes{:,(s + 1)});
end
extents(:,4) = extents(:,3) - extents(:,2);
extents = sortrows(extents, 4, 'descend');

%%% because of scaling, this whole fancy grid system concept is officially obsolete. Damn.
%%% what I can do is show "Real Displacements" in the contour plot and legend, and perhaps label the
%%% title appropriately. But the spatial coordinates will reflect values as if the displacements
%%% were actually those scaled values. Theres really no simple way around this.

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

%%% need to only do this max thing for y, otherwise, my assumptions here may be invalid. Plus, this
%%% is going to be a 2D plotter, so its fine
offset = max(dx, abs(((extents(1,4) + 2 * dx) .* resolution / resolution(1) - extents(:,4)) / 2));
limits(:,1) = extents(:,2) - offset;
limits(:,2) = extents(:,3) + offset;

grid = {(round(limits(1,1) / dx) * dx - 10 * dx):dx:(round(limits(1,2) / dx) * dx + 10 * dx);
        (round(limits(2,1) / dx) * dx - 10 * dx):dx:(round(limits(2,2) / dx) * dx + 10 * dx)};

%%% damn, this is why natural coordinate maps are dope. How do I select interpolation points in the
%%% deformed space of the element?? You hardly can. I mean, you could come up with some method, but
%%% I already have one implemented - lagrange spatial interpolations. The points can be selected as
%%% a uniform grid on xi \in [-1, 1], and then those points can be mapped into deformed space

%%% my linear interpolation function will be useful for interpolating the colorbar, with extrapolate
%%% as false, because I'm gonna set the color bar limits to max and min displacements of course.
%%% however, I still shall interpolate using my shape functions. actually maybe just let matlab
%%% plot object handle this job


%%% be sure to have parameter for number of sample points
    
%// get element connectivity lines on each block
connectivity = cell(1, num_blocks);
for b = 1:num_blocks
    connectivity{b} = zeros((num_local_nodes + 1), num_dims, num_elems);
    for e = 1:num_elems
        idx = mesh(e,1:3:end);
        connectivity{b}(:,:,e) = [displaced_nodes(idx,1:2); displaced_nodes(idx(1),1:2)];
    end
end

%/ creates a 3x3 array in 2D element (default shall be 10)
data_pts = 3;

%%% might even need a different function for beam plots specificially because the spatial
%%% interpolation is quite different

%%% line interpolation, quad interpolation, hex interpolation, ...

u = cell(1, num_blocks);
v = cell(1, num_blocks);
qnorm = cell(1, num_blocks);
x = cell(1, num_blocks);
y = cell(1, num_blocks);

dxi = 2 / (data_pts - 1);
xi = -1:dxi:1;
eta = -1:dxi:1;

for b = 1:num_blocks
    u{b} = zeros(data_pts, data_pts, num_elems); % num_elems{b}
    v{b} = zeros(data_pts, data_pts, num_elems);
    qnorm{b} = zeros(data_pts, data_pts, num_elems);
    x{b} = zeros(data_pts, data_pts, num_elems);
    y{b} = zeros(data_pts, data_pts, num_elems);
    
    q_idx = zeros(2 * num_local_nodes, 1);
    u_idx = 1:2:length(q_idx);
    v_idx = u_idx + 1;
    for e = 1:num_elems %num_elems{b}
        
        nodeIDs = transpose(mesh(e,1:3:end));
        coords = transpose([mesh(e,2:3:end); mesh(e,3:3:end)]);
        
        q_idx(u_idx) = num_dofs * (nodeIDs - 1) + 1;
        q_idx(v_idx) = q_idx(u_idx) + 1;
        q = Q(q_idx - real_idx_diff(q_idx));
    
        for i = 1:data_pts
            for j = 1:data_pts       
                N = evaluateCPS4ShapeFun(xi(i), eta(j));
                
                u{b}(i,j,e) = N * q(u_idx);
                v{b}(i,j,e) = N * q(v_idx);
                
                qnorm{b}(i,j,e) = norm([u{b}(i,j,e), v{b}(i,j,e)]);
                
                %%% without connecting lines to all these points I won't be able to do solid
                %%% coloring, so I'll have to figure that out too
                
                % get the original global coordinates and displace them
                x{b}(i,j,e) = N * coords(:,1) + scale * u{b}(i,j,e);
                y{b}(i,j,e) = N * coords(:,2) + scale * v{b}(i,j,e);                
            end
        end
        
    end

end

%%% perhaps all of the different plot object titles could be customized too, but def set defaults

%%% allow edge color interpolation object to handle coloring between sample points so it doesn't
%%% look patchy, assuming that it properly interpolates the jet scheme
%%% I suppose if it works in a nice general way, that the color scheme could be an input parameter,
%%% for example, the input could be 'jet(256)', but only if contours = true

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


%%% I wonder if theres a way to determine current number of figure objects, so that I don't have to
%%% close any plots and I can just say like figure(N) or something. Or maybe just use clf 'clf(1)'?

fprintf('Generating plot... ')

figure(1)
set(gcf, 'Units', 'normalize', 'Position', [0.125, 0.25, 0.75, 0.75])
ax = axes('Position', [0.05, 0.05, 0.9, 0.9]);

%/ plot nodes
plot(displaced_nodes(:,1), displaced_nodes(:,2), 'o', 'markerfacecolor', 'b', 'markersize', 3.5)
hold on

%%% DAMN ima have to come up with my own tic for the colorbar lmao
colormap jet(128)
c = colorbar;
ylabel(c, 'Real Displacement Magnitude') % or just displacement, depending on if scale is 1 or not
%caxis([min(disp_mag), max(disp_mag)])

xlim(limits(1,:))
xticks(grid{1})
ylim(limits(2,:))
yticks(grid{2})
set(gca,'Layer', 'top', 'CLim', [min(disp_mag), max(disp_mag)])

%/ loop through mesh blocks and plot each element
plot(connectivity{1}(1,:,1), connectivity{1}(2,:,1))
for b = 1:num_blocks
    for e = 1:num_elems
        
        %%% here's where I'll handle displacement colorings too
        
        %%% there's so much redundant data in this plot, which could potentially slow down the plot
        %%% interactivity.
        
        for i = 1:(data_pts - 1)
            for j = 1:(data_pts - 1)
%                 sample_x = [x{b}(i,j,e);
%                             x{b}((i + 1),j,e); 
%                             x{b}((i + 1),(j + 1),e); 
%                             x{b}(i,(j + 1),e);
%                             x{b}(i,j,e)];
% 
%                 sample_y = [y{b}(i,j,e);
%                             y{b}((i + 1),j,e); 
%                             y{b}((i + 1),(j + 1),e); 
%                             y{b}(i,(j + 1),e);
%                             y{b}(i,j,e)];
                        
                sample_x = [x{b}(i,j,e),...
                            x{b}((i + 1),j,e),...
                            x{b}((i + 1),(j + 1),e),...
                            x{b}(i,(j + 1),e)];

                sample_y = [y{b}(i,j,e),...
                            y{b}((i + 1),j,e),...
                            y{b}((i + 1),(j + 1),e),...
                            y{b}(i,(j + 1),e)];
                        
                sample_val = [qnorm{b}(i,j,e),...
                              qnorm{b}((i + 1),j,e),...
                              qnorm{b}((i + 1),(j + 1),e),...
                              qnorm{b}(i,(j + 1),e)];
                
                p = patch(sample_x, sample_y, 'k', 'Parent', ax);
                set(p, 'CData', sample_val, 'FaceColor', 'interp', 'CDataMapping', 'scaled', 'EdgeColor', 'none');
                
                        
                %plot(sample_x, sample_y, 'Color', 'r', 'Linewidth', 0.5)
            end
        end
        
        plot(connectivity{b}(:,1,e), connectivity{b}(:,2,e), 'Color', 'b')
    end
end

%// set gradient background - I call this one "Shallow Ocean" XD
bgx = [limits(1,1), limits(1,2), limits(1,2), limits(1,1)];
bgy = [limits(2,1), limits(2,1), limits(2,2), limits(2,2)];

%0.325, 0.545, 0.78 %0.40, 0.596, 0.804 (other nice monochrome colors)
cdata(1,1,:) = [0.196, 0.396, 0.608];
cdata(1,2,:) = [0.196, 0.396, 0.608];
cdata(1,3,:) = [0.475, 0.647, 0.827];
cdata(1,4,:) = [0.475, 0.647, 0.827];
p = patch(bgx, bgy, 'k', 'Parent', ax);
set(p, 'CData', cdata, 'FaceColor','interp', 'EdgeColor', 'none');
uistack(p, 'bottom') % Put gradient underneath everything else


% cdata(1,1) = min(disp_mag);
% cdata(1,2) = min(disp_mag);
% cdata(1,3) = max(disp_mag);
% cdata(1,4) = max(disp_mag);
% p = patch(bgx, bgy, 'k', 'Parent', ax);
% set(p, 'CData', cdata, 'FaceColor','interp', 'CDataMapping', 'scaled', 'EdgeColor', 'none');
% uistack(p, 'bottom') % Put gradient underneath everything else

fprintf('Done.\n\n')




