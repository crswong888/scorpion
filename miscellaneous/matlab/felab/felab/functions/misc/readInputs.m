%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FE Environment for Solid Mechanics %%%
%%%        By: Christopher Wong        %%%
%%%        crswong888@gmail.com        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [varargout] = readInputs(file_varnames)
    %%% specify names of variables with handles to file names in a cell array
    %%% - request table output in that order

    varargout = cell(1,nargout); clear_files = []; idx = 1;
    while (idx <= nargout)
        %// read and store node, element, support, and force information tables
        file = evalin('caller', file_varnames{1,idx});
        varargout{idx} = readtable(file, 'ReadVariableNames', true, 'PreserveVariableNames', true);
        
        %// clear the file variables in the main workspace
        clear_files = cat(2, clear_files, 'clear ', file_varnames{1,idx}, ', '); idx = idx + 1;
    end, evalin('caller', clear_files)
end