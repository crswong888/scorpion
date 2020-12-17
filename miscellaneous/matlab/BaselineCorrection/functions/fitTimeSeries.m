%%% This function solves the linear normal equation for the polynomial coefficents of a specified
%%% kinematic variable using LU decomposition. Real time must be transformed into natural time 'tau'
%%% and the Jacobian map 'J' of real time onto 'tau' must also be provided.
%%%
%%% The coefficients 'C' should be passed to 'evaluatePolynomials()' to obtain ordinates.
%%%
%%% By: Christopher Wong | crswong888@gmail.com

function C = fitTimeSeries(order, series, tau, J, vals, varargin)
    %// parse additional inputs for controlling correction behavior and relative normal tolerance
    params = inputParser;
    valid_series = @(x) validatestring(x, {'acceleration', 'velocity', 'displacement'});
    addRequired(params, 'Series', @(x) any(valid_series(x)))
    addOptional(params, 'TOL', 1e-04, @(x) isnumeric(x) && (0 < x) && (x < 1));
    parse(params, series, varargin{:})

    %// assert that polynomial order is a natural number
    if ((order < 0) || (floor(order) ~= order))
        error('The polynomial order must be an integer greater than or equal to zero.')
    end
    
    %//
    series = valid_series(params.Results.Series);
    switch series
        case 'acceleration'
            matfunc = @(k, j) (j * j + j) / (k + j - 1);
            n = @(k) k - 1;
        case 'velocity'
            matfunc = @(k, j) (j + 1) / (k + j + 1);
            n = @(k) k;
        case 'displacement'
            matfunc = @(k, j) 1 / (k + j + 3);
            n = @(k) k + 1;
    end
    
    %// compute matrix of linear normal equation
    num_coeffs = order + 1;
    K = zeros(num_coeffs, num_coeffs);
    for k = 1:num_coeffs
        for j = 1:num_coeffs
            K(k,j) = matfunc(k, j);
        end
    end
    
    %// compute vector of integrals on right-hand side of normal equation using trapezoidal rule
    I = zeros(num_coeffs, 1);
    for i = 1:(length(tau) - 1)
        for k = 1:num_coeffs
            I(k) = I(k) + (tau(i + 1) - tau(i)) * (tau(i + 1)^(n(k)) * vals(i + 1)...
                   + tau(i)^(n(k)) * vals(i));
        end
    end
    I = J * 0.5 * I; % apply jacobian to map polynomials to natural time
    
    %// solve $\mathbf{K} \cdot C = I$ using LU factorization with row-reordering permutation matrix
    warning('off', 'MATLAB:singularMatrix')
    warning('off', 'MATLAB:nearlySingularMatrix') % these warnings are handled below
    [L, U, P] = lu(K);
    C = U \ (L \ (P * I));
    
    %/ compute relative residual of solution for accuracy checks
    R = norm(K * C - I) / norm(I);
    
    %/ if LU failed, it is probably due to polynomial order being too high
    warning('on', 'MATLAB:singularMatrix')
    warning('on', 'MATLAB:nearlySingularMatrix')
    if ((any(isnan(C))) || (R > params.Results.TOL))
        warning(['LU decomposition unstable when solving for the coefficients of the least ',...
                 'squares ', series, '. This is most likely because the requested polynomial ',...
                 'order is too high.\n\nThe reciprocal condition number for the normal equation ',...
                 'matrix is %g and the relative residual is %g.'], rcond(K), R)
        fprintf('\n')
    end
    
    %/ report accuracy of solution
    fprintf(['Determined least squares ', series, ' with relative residual: %g.\n\n'], R)
end