function [] = plot2DSurface(ax, plt, cmap, coords, field, connectivity, varargin)
    %// parse additional inputs which control plot behavior
    params = inputParser;
    addParameter(params, 'Ghost', false, @(x) islogical(x))
    valid_gp = @(x) validateattributes(x, {'cell'}, {'numel', 2});
    addParameter(params, 'GhostPlot', [], valid_gp)
    addParameter(params, 'Contours', true, @(x) islogical(x))
    valid_style = @(x) validatestring(x, {'surface', 'surface with edges'});
    addParameter(params, 'Style', 'surface with edges', @(x) any(valid_style(x)))
    parse(params, varargin{:})
    
    %// if desired, plot undeformed mesh to be superimposed by deformed mesh
    if (params.Results.Ghost)
        validateRequiredParams(params, 'GhostPlot')
        ghstplt = params.Results.GhostPlot;
        
        %/ fill ghost element surfaces (note: HEX color is #7A7777)
        for e = 1:length(ghstplt{2})
            fill(ghstplt{2}(e).XData, ghstplt{2}(e).YData, [0.478, 0.467, 0.467],...
                 'EdgeColor', 'none');
        end
        
        %/ enable ghost mesh for edge plots
        if (strcmp(params.Results.Style, 'surface with edges'))
            set(ghstplt{1}, 'Visible', 'on')
            set(ghstplt{2}, 'Visible', 'on')
            
            % bring ghost mesh to front of surface with nodes on top
            uistack(ghstplt{2}, 'top')
            uistack(ghstplt{1}, 'top')
        end
    end
    
    %// get dimensions of sample point array
    Nx = length(field(:,1,1));
    Ny = length(field(1,:,1));
    
    %// plot surface of mesh domain with field contours or a solid color
    if (params.Results.Contours)
        for e = 1:length(connectivity(1,1,:))
            for i = 1:(Nx - 1)
                for j = 1:(Ny - 1)
                    %/ set up plot vertices in a closed polygon fashion
                    sample_x = [coords{1}(i,j,e),...
                                coords{1}((i + 1),j,e),...
                                coords{1}((i + 1),(j + 1),e),...
                                coords{1}(i,(j + 1),e)];

                    sample_y = [coords{2}(i,j,e),...
                                coords{2}((i + 1),j,e),...
                                coords{2}((i + 1),(j + 1),e),...
                                coords{2}(i,(j + 1),e)];

                    sample_val = [field(i,j,e),...
                                  field((i + 1),j,e),...
                                  field((i + 1),(j + 1),e),...
                                  field(i,(j + 1),e)];

                    %/ create patch object to fill surface with field contour colors
                    p = patch(sample_x, sample_y, 'k', 'Parent', ax);
                    set(p, 'CData', sample_val, 'FaceColor', 'interp', 'EdgeColor', 'none',...
                        'CDataMapping', 'scaled');
                end
            end
        end
    else
        %/ fill displaced mesh domain with zero-valued colormap index
        for e = 1:length(connectivity(1,1,:))
            fill(connectivity(:,1,e), connectivity(:,2,e), cmap(1,:), 'EdgeColor', 'none')
        end
    end
    
    %// superimpose mesh to surface with edges plot or hide for surface only
    if (strcmp(valid_style(params.Results.Style), 'surface with edges'))
        %/ plot element edges on top of surface
        for e = 1:length(connectivity(1,1,:))
            plot([connectivity(:,1,e); connectivity(1,1,e)],... 
                 [connectivity(:,2,e); connectivity(1,2,e)], 'Color', 'w')
        end

        %/ bring nodes plot to front of edges
        set(plt, 'Visible', 'on')
        uistack(plt, 'top')
    end
end