function [] = validateRequiredParams(p, varargin)
    
    %// write the name of the matlab function or script for which to verify its inputs
    S = dbstack();
    funcstr = [S(2).file(1:end-2), '()']; % S(2) = one stack location back to the invoking function
    
    for param = 1:nargin-1
        if (any(strcmp(p.UsingDefaults, varargin{param})))
            error(['Missing required paramater, ', varargin{param}, ', for ', funcstr]) 
        end
    end
    
end