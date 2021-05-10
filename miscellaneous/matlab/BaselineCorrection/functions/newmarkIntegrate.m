%%% This function twice numerically integrates a discrete-time acceleration 'd2u' specified at an
%%% array of time instants 't' to obtain a velocity 'du', and displacement 'u', time series using
%%% the implicit Newmark-beta integration rule.	
%%%	
%%% By: Christopher Wong | crswong888@gmail.com

function [du, u] = newmarkIntegrate(t, d2u, varargin)
    %// parse & validate function inputs
    params = validParams(t, d2u, varargin{:});
    gamma = params.Results.gamma;
    beta = params.Results.beta;
    
    %// initialize discrete velocity and displacements
    du = zeros(size(d2u)); u = du; % store in arrays with same dimensions as 'd2u'
    du(1) = params.Results.InitialVel;
    u(1) = params.Results.InitialDisp;
    
    %/ evaluate quadratures at all time steps
    for i = 1:(length(t) - 1)
        % compute current time step size
        dt = t(i + 1) - t(i); 
        
        % update velocity
        du(i + 1) = du(i) + (1 - gamma) * dt * d2u(i) + gamma * dt * d2u(i + 1);
        
        % update displacement
        u(i + 1) = u(i) + dt * du(i) + (0.5 - beta) * dt * dt * d2u(i)...
                   + beta * dt * dt * d2u(i + 1);
    end
end

%%% Helper function for parsing input parameters, setting defaults, and validating data types
function params = validParams(t, d2u, varargin)
    %// validate required inputs
    validateattributes(t, {'numeric'}, {'vector', 'increasing'}, 1)
    validateattributes(d2u, {'numeric'}, {'vector', 'numel', length(t), 'real'}, 2)
    
    %// create parser object for inputs to control mean value coefficients and initial conditions
    params = inputParser;
    
    %/ default Newmark params are those of constant average acceleration method (trapezoidal rule)
    valid_gamma = @(x) validateattributes(x, {'numeric'}, {'scalar', 'nonnegative', '<=', 1});
    addOptional(params, 'gamma', 0.5, valid_gamma)
    valid_beta = @(x) validateattributes(x, {'numeric'}, {'scalar', 'nonnegative', '<=', 0.5});
    addOptional(params, 'beta', 0.25, valid_beta)
    
    %/ default ICs are zeros
    valid_ICs = @(x) validateattributes(x, {'numeric'}, {'scalar', 'real'});
    addParameter(params, 'InitialVel', 0, valid_ICs)
    addParameter(params, 'InitialDisp', 0, valid_ICs)
    
    %/ run parser
    parse(params, varargin{:})
end