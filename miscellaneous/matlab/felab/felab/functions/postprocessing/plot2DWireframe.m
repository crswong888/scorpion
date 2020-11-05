%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FE Environment for Solid Mechanics %%%
%%%        By: Christopher Wong        %%%
%%%        crswong888@gmail.com        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = plot2DWireframe(ax, plt, field, connectivity, varargin)
    %// parse additional inputs which control plot behavior
    params = inputParser;
    addParameter(params, 'Ghost', false, @(x) islogical(x))
    valid_gp = @(x) validateattributes(x, {'matlab.graphics.chart.primitive.Line'}, {});
    addParameter(params, 'GhostPlot', [], valid_gp)
    addParameter(params, 'Contours', true, @(x) islogical(x))
    parse(params, varargin{:})
    
    %// if desired, plot undeformed mesh to be superimposed by deformed mesh
    if (params.Results.Ghost)
        validateRequiredParams(params, 'GhostPlot')
        set(params.Results.GhostPlot, 'Visible', 'on')
    end
    
    %// draw field contours on element connectivity lines or simply color them white for no contours
    if (params.Results.Contours)
        for e = 1:length(connectivity(1,1,:))
            %/ set up plot vertices in a closed polygon fashion
            sample_val = [field(1:end,1,e);
                          transpose(field(end,2:end,e)); 
                          flip(field(1:(end - 1),end,e));
                          flip(transpose(field(1,2:(end - 1),e)))];
            
            %/ create patch object to color element edges with field contours
            p = patch(connectivity(:,1,e), connectivity(:,2,e), 'k', 'Parent', ax);
            set(p, 'CData', sample_val, 'FaceColor', 'none', 'CDataMapping', 'scaled',...
                'EdgeColor', 'interp');
        end
    else
        for e = 1:length(connectivity(1,1,:))
            %/ plot element connectivity lines as white
            plot([connectivity(:,1,e); connectivity(1,1,e)],... 
                 [connectivity(:,2,e); connectivity(1,2,e)], 'Color', 'w')
        end
    end
end