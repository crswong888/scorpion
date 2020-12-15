%%% This function solves the linear normal equation for the polynomial coefficents of the least
%%% squares acceleration using LU decomposition. 'accel' must be transformed into natural time 'tau'
%%% and the Jacobian map 'J' of real time onto 'tau' must also be provided.
%%%
%%% By: Christopher Wong | crswong888@gmail.com

function C = getAccelerationFitCoeffs(order, tau, J, accel, gamma, varargin)
    %// parse additional input for enforcing relative normal tolerance on solution
    params = inputParser;
    addOptional(params, 'TOL', 1e-04, @(x) isnumeric(x) && (0 < x) && (x < 1));
    parse(params, varargin{:})

    %// assert that polynomial order is a natural number
    if ((order < 0) || (floor(order) ~= order))
        error('The polynomial order must be an integer greater than or equal to zero.')
    end
    
    %// compute matrix of linear normal equation
    num_coeffs = order + 1;
    K = zeros(num_coeffs, num_coeffs);
    for k = 1:num_coeffs
        for j = 1:num_coeffs
            K(k,j) = (j * j + j) / (k + j - 1);
        end
    end
    
    %// compute vector of integrals on right-hand side of linear normal equation
    I = zeros(num_coeffs, 1);
    for i = 1:(length(tau) - 1)
        for k = 1:num_coeffs
            d2u_old = tau(i)^(k - 1) * accel(i);
            d2u = tau(i + 1)^(k - 1) * accel(i + 1);
            
            I(k) = I(k) + newmarkGammaIntegrate(tau(i + 1) - tau(i), d2u_old, d2u, 0, gamma);
        end
    end
    I = J * J * I; % apply jacobian to map polynomials to natural coordinates ($\tau \in [0, 1]$)
    
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
        error(['LU decomposition was unsuccesful at solving for the coefficients of the least ',...
               'squares acceleration. This is most likely because the requested polynomial ',...
               'order is too high.\n\nThe reciprocal condition number for the normal equation ',...
               'matrix is %g and the relative residual is %g.'], rcond(K), R)
    end
    
    %/ report accuracy of solution
    fprintf('Determined least squares acceleration with relative residual: %g.\n\n', R)
end