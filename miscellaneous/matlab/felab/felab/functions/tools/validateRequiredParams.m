%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FE Environment for Solid Mechanics %%%
%%%        By: Christopher Wong        %%%
%%%        crswong888@gmail.com        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% This function makes optional parameter objects of Matlab's inputParser class required. This
%%% is useful for the case where certain additional arguments are needed based on the input for
%%% an actually required inputParser object.

function [] = validateRequiredParams(p, varargin)
    %// write name of the matlab function or script for which to verify its inputs
    S = dbstack();
    funcstr = [S(2).file(1:end-2), '()']; % S(2) = one stack location back to the invoking function
    
    %// if only one parameter specified, it must be valid - else, all must be valid or all default
    params = intersect(p.UsingDefaults, varargin);
    if (~isempty(params))
        if ((length(varargin) == 1) || (length(params) ~= length(varargin)))
            %/ compile list of missing parameters
            missing = ['''', params{1}, ''''];
            for i = 2:length(params)
                missing = cat(2, missing, [', ''', params{i}, '''']);
            end

            %/ terminate program and print error message
            error(['Missing required parameter(s) in ', funcstr ': ' missing])
        end
    end
end