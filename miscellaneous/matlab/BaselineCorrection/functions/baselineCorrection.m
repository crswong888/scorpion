%%%


function [accel, vel, disp] = baselineCorrection(t, accel, varargin)
    %// object for additional inputs which control correction procedure
    params = inputParser;
    
    %/ 
    addParameter(params, 'Gamma', 0.5, @(x) isnumeric(x) && (0 <= x) && (x <= 1))
    addParameter(params, 'Beta', 0.25, @(x) isnumeric(x) && (0 <= x) && (x <= 0.5))
    
    %/
    addParameter(params, 'AccelFitOrder', [], @(x) isempty(x) || ((x >= 0) && (floor(x) == x)))
    addParameter(params, 'VelFitOrder', [], @(x) isempty(x) || ((x >= 0) && (floor(x) == x)))
    addParameter(params, 'DispFitOrder', [], @(x) isempty(x) || ((x >= 0) && (floor(x) == x)))
    
    %/
    addParameter(params, 'ResidualTol', 1e-04, @(x) isnumeric(x) && (0 < x) && (x < 1))

    %// parse provided inputs
    parse(params, varargin{:})
    
    %/ simplify pointer syntax
    accel_fit_order = params.Results.AccelFitOrder;
    vel_fit_order = params.Results.VelFitOrder;
    disp_fit_order = params.Results.DispFitOrder;
    TOL = params.Results.ResidualTol;

    %// assert that time and accel arrays are of equal length
    N = length(t);
    if (N ~= length(accel))
        error('The length of time and acceleration data must be equal.')
    end
    
    %// assert that at least squares correction will be applied
    if (isempty([accel_fit_order, vel_fit_order, disp_fit_order]))
        error(['No values were input for parameters ''AccelFitOrder'', ''VelFitOrder'', nor ',...
               '''DispFitOrder''. Please specify an integer values greater than or equal to ',...
               'for at least one of these parameters.'])
    end

    %// compute unadjusted (nominal) velocity and displacement
    [vel, disp] = newmarkIntegrate(t, accel, params.Results.Gamma, params.Results.Beta);

    %// compute Jacobian and map time onto natural time $\tau \in [0, 1]$
    J = range(t);
    tau = (t - t(1)) / J;

    %// adjust time histories with acceleration fit, if desired
    if (~isempty(accel_fit_order))
        coeffs = getAccelerationFitCoeffs(accel_fit_order, tau, J, accel, TOL);

        for i = 1:N
            pfit = evaluatePolynomials(coeffs, tau(i), J);

            accel(i) = accel(i) - pfit(1);
            vel(i) = vel(i) - pfit(2);
            disp(i) = disp(i) - pfit(3);
        end
    end

    %// adjust with velocity fit
    if (~isempty(vel_fit_order))
        coeffs = getVelocityFitCoeffs(vel_fit_order, tau, J, vel, TOL);

        for i = 1:N
            pfit = evaluatePolynomials(coeffs, tau(i), J);

            accel(i) = accel(i) - pfit(1);
            vel(i) = vel(i) - pfit(2);
            disp(i) = disp(i) - pfit(3);
        end
    end

    %// adjust with displacement fit
    if (~isempty(disp_fit_order))
        coeffs = getDisplacementFitCoeffs(disp_fit_order, tau, disp, TOL);

        for i = 1:N
            pfit = evaluatePolynomials(coeffs, tau(i), J);

            accel(i) = accel(i) - pfit(1);
            vel(i) = vel(i) - pfit(2);
            disp(i) = disp(i) - pfit(3);
        end
    end
end