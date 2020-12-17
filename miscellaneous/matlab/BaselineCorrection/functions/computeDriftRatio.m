%// for vibrations which are initially at rest and terminally at rest, DR

function [DR, AR] = computeDriftRatio(t, d2u, disp, varargin)
    %// 
    params = inputParser;
    addParameter(params, 'Gamma', 0.5, @(x) isnumeric(x) && (0 <= x) && (x <= 1))
    addParameter(params, 'Beta', 0.25, @(x) isnumeric(x) && (0 <= x) && (x <= 0.5))
    parse(params, varargin{:})

    %// get nominal velocity and displacement
    [du, u] = newmarkIntegrate(t, d2u, params.Results.Gamma, params.Results.Beta);
    
    %// compute consistent displacement signal
    u_consistent = u - mean(u - mean(du) * t);
    
    %// compute drifting and amplitude ratios
    DR = abs(mean(disp) / rms(u_consistent));
    AR = abs(rms(disp) / rms(u_consistent));
end