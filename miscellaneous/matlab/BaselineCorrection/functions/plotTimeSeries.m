%%%
%%%
%%% By: Christopher Wong | crswong888@gmail.com


%%% multilayout plot only uses 1 title
%%%
%%% format 'separate' or 'layout', if layout - max number or series is 6 (3x3)
%%%
%%% if layout titles, don't render titles for individual plots, otherwise, render them
%%%
%%% possibly include an 'abscissa' and 'ordinates' parameter for using separate data sizes, in which
%%% case, the t and series params must be made optional, but then required if no abscissa-ordinates,
%%% also if abscissa-ordinates, make them mutually dependent
%%%
%%% at some point, if there really is time, it would be interesting to try getting superimposed
%%% plots into a tiled layout


function [] = plotTimeSeries(time, series, varargin)
    %// object for additional inputs which control plot behavior
    params = inputParser;
    
    %/ series must be a row vec equal in length to 'time' - provide multiple by concatenating rows
    N = length(time);
    num_series = length(series(:,1));
    valid_series = @(x) validateattributes(x, {'numeric'}, {'ncols', N});
    addRequired(params, 'Series', valid_series)
    
    %/
    valid_tiles = @(x) isnumeric(x) && (numel(x) == length(x)) && (1 < length(x))...
                       && (length(x) < 6) && (max(x) <= num_series);
    addParameter(params, 'TiledLayout', [], @(x) valid_tiles(x) || all(cellfun(valid_tiles, x)))
    
    %/ cell array of plot titles and axis labels for each 'series' - use 'none' to hide titles
    valid_title = @(x) ischar(x) || isstring(x);
    valid_titles = @(x) (valid_title(x) || (iscell(x) && all(cellfun(valid_title, x))))...
                        && (length(string(x)) == num_series);
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
    tiles = params.Results.TiledLayout;
    plot_titles(1:num_series) = string(params.Results.Title);
    x_label = string(params.Results.XLabel);
    y_labels(1:num_series) = string(params.Results.YLabel);
    ftname = params.Results.FontName;
    ftsize = params.Results.FontSize;
    
    %/ convert variables to cells if necessary
    if (~iscell(tiles)), tiles = {tiles}; end
    
    %/ convenience variables
    num_tiles = length(tiles);
    
    num_plots = num_series; % devel: eventually need to distinguish this based on plot styles
    
    %// generate alphanumeric array for tab indexing
    tab = string(transpose('A':'Z'));
    for i = 1:(ceil(num_plots / 26) - 1)
        letters(1:26,1) = tab(i);
        tab = cat(1, tab, join(cat(2, letters, tab(1:26)), ''));
    end
    
    %// get current matlab version for handling position constraint property (9.8 is 2020a)
    pos_arg = 'PositionConstraint';
    if (verLessThan('matlab', '9.8'))
        pos_arg = 'ActivePositionProperty';
    end
    
    %// clear plot objects, if desired
    if (params.Results.ClearFigures)
        close all
    end
    
    %// scale fig window bounds to screen width based on 'FontSize' and use a 20:9 aspect ratio
    
    %%% devel: if max(length(tiles)) > 2, use a certain aspect, else, ...
    
    res = get(0, 'ScreenSize');
    %aspect = (0.030225 * ftsize + 0.1537) * res(3) * [1, 9 / 20];
    
    aspect = (0.030225 * ftsize + 0.1537) * res(3) * [1, 5 / 8]; % devel
    
    pos = [res(1) + (res(3) - aspect(1)) / 2, res(2) + (res(4) - aspect(2)) / 2, aspect];
    figure('OuterPosition', pos);
    
    %// 
    count = 1;
    for t = 1:num_tiles
        %%% devel: using 'nexttile(span)' might be an interesting way to use a 3x3 grid here...
        %%% if so, always priortize the last plot added, i.e., it gets the most space
        
        %/ create new tab
        current = tiles{t};
        dims = min(length(current), 3);
        layout = tiledlayout(uitab('Title', tab(count)), dims, dims, 'Padding', 'none',...
                             'TileSpacing', 'none'); 
        
        %/
        for p = 1:length(current)
            span = 2;
            pos = 2 * p - span + 1
            ax = nexttile(layout, pos, [1, span]);
            plot(time, series(current(p),:))
            hold on
            set(ax, 'FontName', ftname, 'FontSize', ftsize)
            
            hold off
        end
        
        count = count + 1;
    end
    
    %// loop through all input series and plot each one against time
    m = [0.005, 0.02]; % minimum vertical and horizontal tight space margins
    indvl = 1:num_series;
    for p = indvl(~ismember(indvl, tiles{:})) 
        %%% devel: after geting the size of the fig right for layouts, come back here and try to 
        %%% finesse the same plot ratios (but only for the case of existing tile tabs!)
        %%%
        %%% honestly, probably could just used the dimensions of largest tile then center that bish
        %%% in accordance with its outerposition
        
        %/ create unique axes object in new tab, plot series, and set font style
        ax = axes(uitab('Title', tab(count))); %#ok<LAXES>
        plot(time, series(p,:), 'Color', [0, 0, 0],...
             'LineWidth', linearInterpolation([2, 10, 28], [1, 1, 2], ftsize))
        hold on
        set(ax, 'FontName', ftname, 'FontSize', ftsize)
        
        %/ set plot title - shift it up from top plot border by a smidge
        tset = zeros(1, 4);
        if (~strcmp(plot_titles(p), "none"))
            current = plot_titles(p);
            if (current == "")
                current = ['Time Series ', num2str(p)];
            end
            th = title(current, 'Units', 'normalized', 'FontUnits', 'normalized');
            tset = [th.Position + [0, m(2) * ftsize / 20, 0], th.FontSize];
            set(th, 'Position', tset(1:3), 'FontUnits', 'points'); % not resetting units on purpose
        end
        
        %/ set axis labels if there are ones
        if ((x_label ~= "") && (x_label ~= "none"))
            xlabel(x_label)
        end
        if ((y_labels(p) ~= "") && (y_labels(p) ~= "none"))
            ylabel(y_labels(p))
        end
        
        %/ 'TightInset' is a read-only prop - this attempts to modify it w/o knowing how it works
        axtight = get(ax, 'TightInset');
        shift = [max(axtight(1), m(1)) + m(1),...
                 max(axtight(2), m(2)) + m(2),...
                 1 - max(axtight(3), m(1)) - m(1),...
                 1 - max(axtight(4), m(2)) - m(2) - tset(4)];
        shift(3:4) = shift(3:4) - shift(1:2);
        set(ax, 'Position', shift, pos_arg, 'outerposition')
        
        %/ toggle gridlines
        grid on
        grid minor
        
        hold off
        count = count + 1;
    end
end