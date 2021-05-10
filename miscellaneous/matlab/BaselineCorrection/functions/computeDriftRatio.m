%%% Compute the drift ratio 'DR' and amplitude ratio 'AR' of a displacement time history 'disp' by
%%% comparison to a reference displacement 'd' determined by either:
%%%     1) Numerical integration of a specified reference acceleration 'ReferenceAccel' with
%%%        estimates for initial velocity and displacement consistent with a drift-free signal, or
%%%     2) a specified drift-free displacement 'ReferenceDisp'.
%%% The first option is for general purposes while the second is most useful when the time series'
%%% take on an analytical form, e.g., a trigonometric polynomial. In either case, it is recommended
%%% that 'DR < 0.05' and '|AR - 1| < 0.05' be satisfied when selecting a baseline correction type.
%%% 
%%% By: Christopher Wong | crswong888@gmail.com

function [DR, AR] = computeDriftRatio(time, disp, varargin)
    %// parse & validate function inputs
    params = validParams(time, disp, varargin{:});
    
    %// assert that either 'ReferenceAccel' or 'ReferenceDisp' are specified, but not both
    isdefault = ismember({'ReferenceAccel', 'ReferenceDisp'}, params.UsingDefaults);
    if (all(isdefault) || all(~isdefault))
        error(['Please specify an input time series for either ''ReferenceAccel'' or '...
               '''ReferenceDisp'', but not both.'])
    end
    
    %// determine whether to estimate a drift-free displacement or take it as user-provided input
    if (isempty(params.Results.ReferenceDisp))
        %/ integrate acceleration to get nominal velocity and displacement
        gamma = params.Results.gamma;
        beta = params.Results.beta;
        accel = params.Results.ReferenceAccel;
        [du, u] = newmarkIntegrate(time, accel, gamma, beta);
        
        %/ compute initial conditions consistent with drift-free displacement'
        vo = du(1) - 1 / length(time) * sum(du);
        do = vo * time(1) + u(1) + 1 / length(time) * ((u(1) - vo) * sum(time) - sum(u));
        
        %/ integrate again to get "consistent" displacement signal
        [~, d] = newmarkIntegrate(time, accel, gamma, beta, 'InitialVel', vo, 'InitialDisp', do);
    else
        d = params.Results.ReferenceDisp;
    end
    
    %// compute drift indicators
    d_rms = rms(d); % store root mean square of 'd' - no need to compute it twice
    DR = abs(mean(disp) / d_rms); % drift ratio
    AR = abs(rms(disp) / d_rms); % amplitude ratio
end

%%% Helper function for parsing input parameters, setting defaults, and validating data types
function params = validParams(time, disp, varargin)
    %// validate required inputs
    validateattributes(time, {'numeric'}, {'vector', 'increasing'}, 1)
    valid_series = @(x) validateattributes(x, {'numeric'},...
                                           {'vector', 'numel', length(time), 'real'}, 2);
    valid_series(disp);
    
    %// create parser object for inputs to control Newmark parameters and specify a reference signal
    params = inputParser;
    
    %/ default Newmark params are those of constant average acceleration method (trapezoidal rule)
    valid_gamma = @(x) validateattributes(x, {'numeric'}, {'scalar', 'nonnegative', '<=', 1});
    addParameter(params, 'gamma', 0.5, valid_gamma)
    valid_beta = @(x) validateattributes(x, {'numeric'}, {'scalar', 'nonnegative', '<=', 0.5});
    addParameter(params, 'beta', 0.25, valid_beta)
    
    %/ specific acceleration time series for estimating a drift-free displacement to use as
    %/ reference for computing drift and amplitude ratios
    addParameter(params, 'ReferenceAccel', [], valid_series);
    
    %/ specific time series corresponding to a drift-free displacement - if not specified, then
    %/ consistent ICs must be estimated via 'ReferenceAccel' param
    addParameter(params, 'ReferenceDisp', [], valid_series);
    
    %/ run input parser
    parse(params, varargin{:})
end