function [k, idx] = computeR2D2Stiffness(mesh, isActiveDof, varargin)
    %%% Note: the penalty stiffness should be much larger in magnitude than the largest applied
    %%% forces and the largest member stiffness (e.g., EA/L, EI/L^3, or some D-matrix)
    %%%
    %%% Note: The effects of stiffness loss due to large member lengths are ignored.
    
    %// Parse additional argument for penalty stiffness. If not provided - default is to use "The
    %// Square Root Rule," described in C. Fellipa (2004), "Introduction to Finite Element Methods."
    %// University of Colorado, Boulder, CO., with max(K(i,j)) = 0.
    params = inputParser;
    addParameter(params, 'penalty', sqrt(10^digits), @(x) (isnumeric(x) && (x > 0)));
    parse(params, varargin{:});

    %// This function simply invokes computeT2D2Stiffness() using the rigid formulation
    [k, idx] = computeT2D2Stiffness(mesh, isActiveDof, 'rigid', true,...
                                    'penalty', params.Results.penalty);
end