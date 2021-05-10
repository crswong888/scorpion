%%% This function applies a baseline correction (BLC) to a discrete-time acceleration signal 'accel'
%%% specified at an array of time instants 'time'. It is based on the type-oriented algorithm (TOA)
%%% developed by Christopher J. Wong at the University of Utah.
%%%
%%% Baseline drift is a phenomena caused by double-integration of an acceleration time history with
%%% initial conditions that are inconsistent with a particle that vibrates in-place (i.e., about a
%%% constant baseline), especially when the homogenous initial value problem is assumed, which is
%%% the one assumed here. That is, assuming that the particle is initially at rest may not be an
%%% appropriate assumption for a given acceleration if the expectation is in-place vibration.
%%% However, this assumption can be maintained by applying a BLC to compensate for drifting.
%%%
%%% The traditional methodology for BLC involves subtracting a least squares polynomial from the
%%% nominal (uncorrected) time series', which is effective at removing drift while preserving the
%%% important properties of the nominal signal, such as frequency and relative amplitudes. The TOA
%%% employs this approach, but the corrections are based on permutations of the three kinematic
%%% variables (acceleration, velocity, and displacement) adjusted in sequence. Each adjustment can
%%% be of a different polynomial degree, and very high orders are achievable by preconditioning the
%%% least squares system of equations (normal equations) using lower-upper (LU) factorization.
%%%
%%% The TOA provides its user with basic "correction types," for which there are seven denoted by: 
%%% A, AV, AD, AVD, V, VD, and D. The characters A, V, and D represent the adjustments made to
%%% accelerations, velocities, and displacements, respectively. The user specifies which basic type
%%% to apply by providing inputs for the parameters 'AccelFitOrder', 'VelFitOrder', and
%%% 'DispFitOrder'. For example, if a user invokes this function with 'AccelFitOrder', 4,
%%% 'DispFitOrder', 2, this would be a type AD correction or, more specifically, a type A4D2. Some 
%%% of the most common types provided by popular commercial software are A3 or V3 corrections. For 
%%% most acceleration signals, the common ones will be an appropriate compensation for drift. 
%%% However, signals with poor frequency content, like a trigonometric polynomial, require stronger 
%%% corrections, e.g., type A13V13D11.
%%%
%%% When selecting a correction type, it is recommended that the order be less than the number of
%%% periods elapsed in the signal, and that the order be equal or decrease through the sequence,
%%% i.e., 'AccelFitOrder' >= 'VelFitOrder' >= 'DispFitOrder'. It is also recommended that the drift
%%% ratio 'DR' and amplitude ratio 'AR' satisfy certain constraints: After performing a BLC using
%%% this function, invoke the 'computeDriftRatio()' function included in this package and check that 
%%% 'DR < 0.05' and '|AR - 1| < 0.05' is satisfied. If not, then try a different correction type.
%%%
%%% By: Christopher Wong | crswong888@gmail.com

function varargout = baselineCorrection(time, accel, varargin)
    %// parse & validate function inputs
    params = validParams(time, accel, varargin{:});
    
    %// assert that a correction type be specified, i.e., at least one polynomial fit order
    n = [params.Results.AccelFitOrder, params.Results.VelFitOrder, params.Results.DispFitOrder];
    if (all(isnan(n)))
        error(['No value input for the parameter ''AccelFitOrder'', ''VelFitOrder'', nor ',...
               '''DispFitOrder''. Please specify a positive integer for at least one of these.'])
    end
    
    %// compute nominal velocity and displacements by integrating with Newmark's method
    varargout = {accel}; % initialize output cell array (varargout = {accel, vel, disp})
    [varargout{2:3}] = newmarkIntegrate(time, accel, params.Results.gamma, params.Results.beta);
    
    %// compute Jacobian and map time onto natural time $\tau \in [0, 1]$
    J = range(time);
    tau = (time - time(1)) / J;
    
    %// proceed through each specified adjustment to kinematic variables
    FIT = ["acceleration", "velocity", "displacement"];
    for p = 1:3
        if (~isnan(n(p))) % otherwise, this adjustment type is not being applied        
            %/ determine coefficients of best-fit polynomial of current time series in natural time
            c = fitTimeSeries(char(FIT(p)), tau, varargout{p}, J, n(p), params.Results.ResidualTol);
            
            %/ evaluate all three derivatives of polynomial and adjust corresponding kinematic vars
            for i = 1:length(time)
                for k = 1:length(c) % loop through monomials and subtract each one
                    varargout{1}(i) = varargout{1}(i) - (k * k + k) * c(k) * power(tau(i), k - 1);
                    varargout{2}(i) = varargout{2}(i) - J * (k + 1) * c(k) * power(tau(i), k);
                    varargout{3}(i) = varargout{3}(i) - J * J * c(k) * power(tau(i), k + 1);
                end
            end
        end
    end
end

%%% Helper function for parsing input parameters, setting defaults, and validating data types
function params = validParams(time, accel, varargin)
    %// validate required inputs
    validateattributes(time, {'numeric'}, {'vector', 'increasing'}, 1)
    validateattributes(accel, {'numeric'}, {'vector', 'numel', length(time), 'real'}, 2)
    
    %// create parser object for additional inputs controlling numerical procedure
    params = inputParser;
    
    %/ polynomial degrees to use when fitting kinematic time series - at least one must be specified
    valid_order = @(x) validateattributes(x, {'numeric'}, {'scalar', 'integer', 'nonnegative'});
    addParameter(params, 'AccelFitOrder', NaN, valid_order)
    addParameter(params, 'VelFitOrder', NaN, valid_order)
    addParameter(params, 'DispFitOrder', NaN, valid_order)
    
    %/ default Newmark params are those of constant average acceleration method (trapezoidal rule)
    valid_gamma = @(x) validateattributes(x, {'numeric'}, {'scalar', 'nonnegative', '<=', 1});
    addParameter(params, 'gamma', 0.5, valid_gamma)
    valid_beta = @(x) validateattributes(x, {'numeric'}, {'scalar', 'nonnegative', '<=', 0.5});
    addParameter(params, 'beta', 0.25, valid_beta)
        
    %/ tolerance to use when checking relative residual of solution to least squares equations
    valid_TOL = @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive', '<', 1});
    addParameter(params, 'ResidualTol', 1e-04, valid_TOL)
    
    %/ run parser
    parse(params, varargin{:})
end

%%% Helper function to solve the linear normal equations for the coefficients of the least squares 
%%% polynomial of a given kinematic variable 'u' of a specified order 'n' using LU decomposition.
function c = fitTimeSeries(series, tau, u, J, n, TOL)
    %// compute various constants necessary to assemble linear normal equations
    switch series
        case 'acceleration'
            nmin = 0;
            matfunc = @(k, j) (j * j + j) / (k + j - 1);
        case 'velocity'
            nmin = 1;
            matfunc = @(k, j) (j + 1) / (k + j + 1);
        case 'displacement'
            nmin = 2;
            matfunc = @(k, j) 1 / (k + j + 3);
    end
    
    %// message for asserting that polynomial degree is a natural number greater than true minimum    
    if ((n < nmin) || (floor(n) ~= n))
        error("The " + series + " fit order must be an integer >= " + string(nmin) + ".")
    end
    
    %// initialize and assemble system of normal equations
    num_coeffs = n - nmin + 1; % adjust to true order based on kh(k), add 1 for constant term
    M = zeros(num_coeffs, num_coeffs);
    a = zeros(num_coeffs, 1);
    for k = 1:num_coeffs
        %/ compute matrix on left-hand side using 'matfunc' given 'series'
        for j = 1:num_coeffs
            M(k,j) = matfunc(k, j);
        end
        
        %/ evaluate integrals in vector on right-hand side using trapezoidal rule
        p = k - 1 + nmin; % degree of exponent applied to natural time variable
        for i = 1:(length(tau) - 1)
            dtau = tau(i + 1) - tau(i); % time step size
            a(k) = a(k) + dtau * (power(tau(i), p) * u(i) + power(tau(i + 1), p) * u(i + 1));
        end
    end
    a = a / power(J, nmin) / 2; % apply Jacobian map & one-half factor from trapezoid quadratures
    
    %// precondition normal matrix using LU factorization with row permutation matrix and then solve
    warning('off', 'MATLAB:singularMatrix')
    warning('off', 'MATLAB:nearlySingularMatrix') % these warnings are handled in a different way
    [L, U, P] = lu(M);
    c = U \ (L \ (P * a));
    
    %// compute relative residual of solution for accuracy checks
    R = norm(M * c - a) / norm(a);
    
    %/ if LU failed, it is probably due to polynomial order being too high
    warning('on', 'MATLAB:singularMatrix')
    warning('on', 'MATLAB:nearlySingularMatrix') % we can turn these back on now
    if ((any(isnan(c))) || (R > TOL))
        warning(['LU decomposition unstable when solving for the coefficients of the least ',...
                 'squares ', series, '. This is most likely because the requested polynomial ',...
                 'order is too high.\n\nThe reciprocal condition number for the normal equation ',...
                 'matrix is %g and the relative residual is %g.\n'], rcond(M), R)
        fprintf('\n')
    end
    
    %/ report accuracy of solution
    fprintf(['Determined least squares ', series, ' with relative residual: %g.\n\n'], R)
end