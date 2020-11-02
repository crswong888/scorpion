function [] = plot2DSurface(ax, plt, cmap, coords, field, connectivity, varargin)
    %// parse additional inputs which control plot behavior
    params = inputParser;
    addParameter(params, 'Contours', true, @(x) islogical(x))
    valid_style = @(x) validatestring(x, {'surface', 'surface with edges'});
    addParameter(params, 'Style', 'surface with edges', @(x) any(valid_style(x)))
    parse(params, varargin{:})
    
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
        uistack(plt, 'top')
    else
        set(plt, 'Visible', 'off')
    end
end