%%%
%%%
%%% By: Christopher Wong | crswong888@gmail.com


%%% multilayout plot only uses 1 title
%%%
%%% format 'separate' or 'layout', if layout - max number or series is 5
%%%
%%% possibly include an 'abscissa' and 'ordinates' parameter for using separate data sizes, in which
%%% case, the t and series params must be made optional, but then required if no abscissa-ordinates,
%%% also if abscissa-ordinates, make them mutually dependent


function [] = plotTimeSeries(t, series, varargin)
    %// object for additional inputs which control plot behavior
    params = inputParser;
    
    %/ series must be a row vector equal in length to 't' - provide multiple by concatenating rows
    N = length(t);
    num_plots = length(series(:,1));
    valid_series = @(x) validateattributes(x, {'numeric'}, {'ncols', N});
    addRequired(params, 'Series', valid_series)
    
    %/ cell array of plot titles and axis labels for each 'series' - use 'none' to hide titles
    valid_title = @(x) ischar(x) || isstring(x);
    valid_titles = @(x) (length(string(x)) == num_plots) && (valid_title(x)... 
                        || (iscell(x) && all(cellfun(valid_title, x))));
    addParameter(params, 'Title', "", valid_titles)
    addParameter(params, 'XLabel', "Time", valid_title);
    addParameter(params, 'YLabel', "", valid_titles);
    
    %/ font to use on plot axes and title test
    valid_font = @(x) ischar(x) || (isstring(x) && (length(x) == 1));
    addParameter(params, 'FontName', 'Helvetica', valid_font)
    addParameter(params, 'FontSize', 10, @(x) isnumeric(x) && (2 <= x) && (x <= 28));
    
    %/ wether or not to close all currently open plots before generating new ones
    addParameter(params, 'ClearFigures', false, @(x) islogical(x));
    
    %// parse provided inputs
    parse(params, series, varargin{:})
    
    %/ simplify pointer syntax
    plot_titles(1:num_plots) = string(params.Results.Title);
    x_label = string(params.Results.XLabel);
    y_labels(1:num_plots) = string(params.Results.YLabel);
    ftname = params.Results.FontName;
    ftsize = params.Results.FontSize;
    
    %// get current matlab version for handling position constraint property (9.8 is 2020a)
    pos_arg = 'PositionConstraint';
    if (verLessThan('matlab', '9.8'))
        pos_arg = 'ActivePositionProperty';
    end
    
    %// clear plot objects, if desired
    if (params.Results.ClearFigures)
        close all
    end
    
    %// scale fig window bounds to screen width based on 'FontSize' and use a 5:2 aspect ratio 
    res = get(0, 'ScreenSize');
    aspect = (0.030225 * ftsize + 0.1537) * res(3) * [1, 2 / 5];
    pos = [res(1) + (res(3) - aspect(1)) / 2, res(2) + (res(4) - aspect(2)) / 2, aspect];
    
    %//
    m = [0.005, 0.02]; % minimum vertical and horizontal tight space margins
    for p = 1:num_plots
        %/
        figure('OuterPosition', pos);      
        plot(t, series(p,:), 'Color', [0, 0, 0], 'LineWidth', 1)
        hold on
        
        %/
        set(gca, 'FontName', ftname, 'FontSize', ftsize);
        
        %/
        tset = zeros(1, 4);
        if (~strcmp(plot_titles(p), "none"))
            current = plot_titles(p);
            if (current == "")
                current = ['Time Series ', num2str(p)];
            end
            th = title(current, 'Units', 'normalized', 'FontUnits', 'normalized');
            tset = [th.Position + [0, m(2) * ftsize / 20, 0], th.FontSize];
            set(th, 'Position', tset(1:3), 'Units', 'data', 'FontUnits', 'points');
        end
        
        %/
        if ((x_label ~= "") && (x_label ~= "none"))
            xlabel(x_label)
        end
        if ((y_labels(p) ~= "") && (y_labels(p) ~= "none"))
            ylabel(y_labels(p))
        end
        
        %/ 'TightInset' is a read-only prop - this attempts to modify it w/o knowing how it works
        axtight = get(gca, 'TightInset');
        shift = [max(axtight(1), m(1)) + m(1),...
                 max(axtight(2), m(2)) + m(2),...
                 1 - max(axtight(3), m(1)) - m(1),...
                 1 - max(axtight(4), m(2)) - m(2) - tset(4)];
        shift(3:4) = shift(3:4) - shift(1:2);
        set(gca, 'Position', shift, pos_arg, 'outerposition')
        
        %/
        grid on
        grid minor
    end  
end