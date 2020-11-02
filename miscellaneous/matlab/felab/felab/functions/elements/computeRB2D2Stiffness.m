function [k, idx] = computeRB2D2Stiffness(mesh, isActiveDof, varargin)  
    %// Parse additional argument for penalty stiffness. If not provided - default is to use "The
    %// Square Root Rule," described in C. Fellipa (2004), "Introduction to Finite Element Methods."
    %// University of Colorado, Boulder, CO., with max(K(i,j)) = 0.
    params = inputParser;
    addParameter(params, 'Penalty', sqrt(10^digits), @(x) (isnumeric(x) && (x > 0)));
    parse(params, varargin{:});

    %// This function simply invokes computeB2D2Stiffness() using a rigid formulation
    [k, idx] = computeB2D2Stiffness(mesh, isActiveDof, 'Rigid', true,...
                                    'Penalty', params.Results.Penalty);
end