function [] = render2DSolution(nodes, eleblk, eletype, num_dofs, real_idx_diff, Q, varargin)
    %%% edges need to be colored too, but when the option is 'surface with edges', don't color them
    %%% make sure uncolored edges render on top of the colored surface and that they dont blend
    %%% for 'wireframe', don't show nodes for this option. Do show them, uncolored, for surface & edges
    %%% 'wirframe' lines should be a bit thicker than in 'surface with edges' tho
    %%% 'points' is only nodes, and they need to be colored, and they probably should be FAT fat
    %%% one plot style could be 'undeformed', just dges and nodes uncolored in original positions

    %%% if the number of nodes is only 2, then 'wireframe', 'surface', and 'surface with edges' all
    %%% produce the same result: a colored line with uncolored nodes. 'points' is the same
    
    %// this assumes that input is a cell array of element blocks - convert to cell if not
    if (~iscell(eleblk)), eleblk = {eleblk}; end
    if (~iscell(eletype)), eletype = {eletype}; end
    
    %// valid additional inputs
    valid_element = @(x) all(ismember(x, {'B2D2', 'CPS4', 'R2D2', 'RB2D2' 'SB2D2', 'T2D2'}));
    valid_component = @(x) any(validatestring(x, {'x', 'y', 'magnitude'}));
    valid_style = @(x) any(validatestring(x, {'points', 'surface', 'surface with edges',...
                                              'wireframe'}));
                                          
    %// parse additional inputs which control plot behavior
    params = inputParser;
    addRequired(params, 'eletype', valid_element)
    addParameter(params, 'Component', 'magnitude', valid_component)
    addParameter(params, 'Style', 'surface with edges', valid_style)
    addParameter(params, 'Contours', true, @(x) islogical(x))
    addParameter(params, 'ScaleFactor', 1, @(x) isnumeric(x))
    addParameter(params, 'SamplesPerElement', 10, @(x) ((isnumeric(x)) && (x > 1)))
    addParameter(params, 'Omega', 0, @(x) ((isnumeric(x)) && (x >= 0))) % for SB2D2 elements only
    parse(params, eletype, varargin{:})
    
    %/ simplify some parser syntax
    eletype = params.Results.eletype;
    component = params.Results.Component;
    style = params.Results.Style;
    contours = params.Results.Contours;
    scale_factor = params.Results.ScaleFactor;
    data_pts = params.Results.SamplesPerElement;
    
    %/ if displacement scale factor is 0, turn off contours.
    if (scale_factor == 0)
        contours = false;
    end
    
    %// convenience variables
    num_nodes = length(nodes{:,1});
    num_blocks = length(eleblk);
    num_elems = zeros(1, num_blocks);
    for b = 1:num_blocks
        num_elems(b) = length(eleblk{b}(:,1));
    end
    
    %// this process could potentially take more than a few moments, so let user know its working
    fprintf('Generating plot... ')

    %// retrieve nodal values and displace original mesh
    displaced = zeros(num_nodes, 2);
    fld = zeros(num_nodes, 1);
    for i = 1:num_nodes
        %/ determine DOF positions in global displacement index
        idx = num_dofs * (i - 1) + [1; 2];
        real_idx = idx - real_idx_diff(idx);

        %/ apply scaled displacements to nodes and get their new positions
        displaced(i,:) = nodes{i,([1, 2] + 1)} + transpose(scale_factor * Q(real_idx));

        %/ get desired nodal displacement value
        % if magnitude, else, field...
        fld(i) = norm(Q(real_idx));
    end

    %// interpolate displacement field through elements and get their nodal connectivity
    if (~strcmp(style, 'points'))
        coords = cell(2, num_blocks);
        subfld = cell(1, num_blocks);
        connectivity = cell(1, num_blocks);
        for b = 1:num_blocks
            %/ use element shape functions to interpolate nodal displacements through specified grid
            if (strcmp(eletype{b}, 'B2D2'))
            elseif (strcmp(eletype{b}, 'CPS4'))
                [coords{:,b}, subfld{b}] = fieldCPS4(eleblk{b}, num_dofs, real_idx_diff, Q,...
                                                     'SamplesPerElement', data_pts,...
                                                     'ScaleFactor', scale_factor,...
                                                     'Component', component);
            elseif (strcmp(eletype{b}, 'SB2D2'))
                validateRequiredParams(params, 'Omega')
            elseif (strcmp(eletype{b}, 'T2D2'))

            elseif (strcmp(eletype{b}, 'R2D2') || strcmp(eletype{b}, 'RB2D2'))
                contours = false;
            end

            %/ get element connectivity lines on each block for wireframe and edges plots
            for e = 1:num_elems(b)
                nodeIDs = transpose(eleblk{b}(e,1:3:end));
                connectivity{b}(:,:,e) = displaced([nodeIDs; nodeIDs(1)],:);
            end
        end
    end

    %// Generate a figure window with a nominal plot axes
    figure('Units', 'normalize', 'Position', [0.125, 0.25, 0.75, 0.75])
    ax = axes('Position', [0.05, 0.05, 0.9, 0.9], 'Layer', 'top');

    %/ plot nodes to initialize a plot space
    plt = plot(displaced(:,1), displaced(:,2), 'o', 'MarkerFaceColor', 'w', 'MarkerSize', 2.5,...
                         'MarkerEdgeColor', 'none');
    hold on
    
    % define color mapping system for plot contours
    cmap = colormap(jet(128)); % might be helpful to know the colormap even if its not used
    if (contours)
        c = colorbar;
        ylabel(c, 'Real Displacement Magnitude')
        clim = [min(fld), max(fld)];
        set(ax, 'CLim', clim)
    end

    %/ loop through mesh blocks and plot each element
    if ((strcmp(style, 'surface with edges')) || (strcmp(style, 'surface')))
        for b = 1:num_blocks
            if (contours)
                for e = 1:num_elems(b)
                    for i = 1:(data_pts - 1)
                        for j = 1:(data_pts - 1)
                            % set up plot vertices in a closed polygon fashion
                            sample_x = [coords{1,b}(i,j,e),...
                                        coords{1,b}((i + 1),j,e),...
                                        coords{1,b}((i + 1),(j + 1),e),...
                                        coords{1,b}(i,(j + 1),e)];

                            sample_y = [coords{2,b}(i,j,e),...
                                        coords{2,b}((i + 1),j,e),...
                                        coords{2,b}((i + 1),(j + 1),e),...
                                        coords{2,b}(i,(j + 1),e)];

                            sample_val = [subfld{b}(i,j,e),...
                                          subfld{b}((i + 1),j,e),...
                                          subfld{b}((i + 1),(j + 1),e),...
                                          subfld{b}(i,(j + 1),e)];

                            % create patch object to fill surface with field contour colors
                            p = patch(sample_x, sample_y, 'k', 'Parent', ax);
                            set(p, 'CData', sample_val, 'FaceColor', 'interp',...
                                'CDataMapping', 'scaled', 'EdgeColor', 'none');
                        end
                    end
                end
            else
                % fill displaced mesh domain with zero-valued colormap index
                for e = 1:num_elems(b)
                    fill(connectivity{b}(:,1,e), connectivity{b}(:,2,e), cmap(1,:),...
                         'EdgeColor', 'none')
                end
            end

            % superimpose mesh to surface with edges plot or hide for surface only
            if (strcmp(style, 'surface with edges'))
                % plot element edges on top of surface
                for e = 1:num_elems(b)
                    plot(connectivity{b}(:,1,e), connectivity{b}(:,2,e), 'Color', 'w')
                end

                % bring nodes plot to front of edges
                uistack(plt, 'top')
            else
                set(plt, 'Visible', 'off')
            end
        end
    elseif (strcmp(style, 'wireframe'))
        set(plt, 'Visible', 'off')
        for b = 1:num_blocks
            if (contours)
                for e = 1:num_elems(b)
                    nodeIDs = transpose(eleblk{b}(e,1:3:end));
                    p = patch(connectivity{b}(:,1,e), connectivity{b}(:,2,e), 'k', 'Parent', ax);
                    set(p, 'CData', [fld(nodeIDs); fld(nodeIDs(1))], 'FaceColor', 'none',...
                        'CDataMapping', 'scaled', 'EdgeColor', 'interp');
                end
            else
                for e = 1:num_elems(b)
                    plot(connectivity{b}(:,1,e), connectivity{b}(:,2,e), 'Color', 'w')
                end
            end
        end
    else % points plot
        if (contours)
            % if points and contours, interpolate colormap to indicate nodal field values
            set(plt, 'Visible', 'off')
            for i = 1:num_nodes
                rgb = cmap(round(1 + (fld(i) - clim(1)) * (128 - 1) / (clim(2) - clim(1))),:);
                plot(displaced(i,1), displaced(i,2), 'o', 'MarkerFaceColor', rgb,...
                     'MarkerEdgeColor', 'none', 'MarkerSize', 4.5);
            end
        else
            % make node plot points bigger
            set(plt, 'MarkerSize', 4.5)
        end
    end
    
    %/ set up plot space with a 1:1 ratio for both dimensions
    set(ax, 'Units', 'pixels');
    resolution = [max(ax.Position(3:4)); min(ax.Position(3:4))]; % current resolution of axes window
    set(ax, 'Units', 'normalize') % convert it back so window scaling continues to work

    % determine spatial extents of displaced mesh
    extents = zeros(2, 4);
    extents(:, 1) = 1:2;
    for s = 1:2
        extents(s, 2) = min(displaced(:,s));
        extents(s, 3) = max(displaced(:,s));
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

    % I call this color scheme "Shallow Ocean" lol
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
    
    %%% devel checks
%     resolution(1) / resolution(2)
%     range(lims(1,:)) / range(lims(2,:))
%     lims(1,2) - extents(1,3)
%     lims(1,1) - extents(1,2)
%     lims(2,2) - extents(2,3)
%     lims(2,1) - extents(2,2)
end