function [k, idx] = computeR2D2Stiffness(mesh, isActiveDof, varargin)
    %%% Note: the penalty stiffness should be much larger in magnitude than the largest applied
    %%% forces and the largest member stiffness (e.g., EA/L, EI/L^3, or some D-matrix)
    %%%
    %%% Note: The effects of stiffness loss due to large member lengths are ignored.
    
    %// Parse additional argument for penalty stiffness. If not provided - default is to use "The
    %// Square Root Rule," described in C. Fellipa (2004), "Introduction to Finite Element Methods."
    %// University of Colorado, Boulder, CO., with max(K(i,j)) = 0.
    p = inputParser;
    RealPositiveArray = @(x) isnumeric(x) && all(x > 0); % valid input type for penalty
    default_penalty = sqrt(10^digits) * ones(length(mesh(:,1)),1);
    addParameter(p, 'penalty', default_penalty, RealPositiveArray);
    parse(p, varargin{:});

    %// This function simply invokes computeT2D2Stiffness() using the rigid formulation
    [k, idx] = computeT2D2Stiffness(mesh, p.Results.penalty, isActiveDof, 'rigid', true);
end