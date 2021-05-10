%%% This function evaluates the discrete Fourier transform of a time series 'u' specified at an
%%% array of time instants 't'. It subsequently performs a one-sided (real) expansion and sums the 
%%% absolute values of conjugate pairs to get total amplitudes in the frequency domain. The user may
%%% restrict the output domain to specified boundaries of any of the three frequency types: 'cyclic'
%%% (e.g., Hz), 'angular' (e.g., rad/s), or 'periodic' (e.g., 1/s). If the user does not specify a
%%% domain, than the largest possible domain is output. The time points may be spaced at irregular
%%% intervals, but it is important that the degree of irregularities be classified as either
%%% 'uniform', 'semiuniform', or 'nonuniform' using the 'Distribution' parameter.
%%%
%%% By: Christopher Wong | crswong888@gmail.com

function [f, uo] = discreteFourierTransform(t, u, varargin)
    %// parse & validate function inputs
    [params, tokens] = validParams(t, u, varargin{:});
    N = length(t); % total number of time instants
    dtype = tokens.Distribution;
    ftype = tokens.FrequencyType;
    fdom = params.Results.Domain;
    
    %// setup one-sided expansion of frequency domain based on type of discretization
    switch dtype
        case 'uniform'
            %/ compute upper bound of cyclic domain assuming dt is truly constant through time
            fmax = (N - 1) / 2 / range(t); % (Chopra Eqn. A.5.2 & A.5.5)
            
            %/ for uniform dt, real amplitudes are well defined at a number of sample points equal
            %/ to half no. of time instants
            df = fmax / floor(N / 2); % sampling frequency
        otherwise
            %/ compute an appropriate upper bound value based on maximum timestep size
            fmax = 1 / (2 * max(abs(t(2:N) - t(1:(N - 1)))));
            
            if (strcmp(dtype, 'semiuniform'))
                %/ here, it should be safe to say real amplitudes are well defined at almost all
                %/ 1-sided sample points, with negligible artifacts here and there
                df = (N - 1) / 2 / range(t) / floor(N / 2); % based on fmax of uniform dtype
            else
                %/ but for straight up nonuniform spacing, everything is going to be messed up, and
                %/ sampling every 1 cycle/unit time seems to always be safe
                df = 1;
            end
    end
    
    %// check bounds of fdom and convert non-cyclic types... if not specified, then set a default
    if (~ismember('Domain', params.UsingDefaults))
        switch ftype
            case 'cyclic'
                if (fdom(2) > fmax)
                    error(['The ''Domain'' parameter is invalid. The maximum sample frequency '...
                           'must be less than or equal to %g.'], fmax)
                end
            case 'angular'
                if (fdom(2) > 2 * pi * fmax)
                    error(['The ''Domain'' parameter is invalid. The maximum sample angular '...
                           'frequency must be less than or equal to %g.'], 2 * pi * fmax)

                end
                
                %/ conversion: 'f = frac{\omega}{2 \pi}'
                fdom = fdom / 2 / pi;
            otherwise % 'periodic'
                if (fdom(2) > range(t)) % 1-sided periodic domain expands entire time domain
                    error(['The ''Domain'' parameter is invalid. The maximum sample period must '...
                           'be less than or equal to %g.'], range(t))
                end
                
                %/ conversion: 'f = frac{1}{T}'
                fdom = 1 ./ flip(fdom); % frequency increases as period decreases, hence flip()
                
                %/ need to warn about zero-valued periods and adjust upper domain bound used for FFT
                if (fdom(2) == Inf)
                    fdom(2) = fmax;
                    warning(sprintf(['Harmonics with zero-valued period are not defined. This '...
                                     'amplitude will be taken as the one computed at the '...
                                     'smallest valid sample.\n'])) %#ok<SPWRN>
                    fprintf('\n')
                end
        end
    elseif (strcmp(ftype, 'periodic'))
        %/ default fdom includes all real frequencies except zero, which is undefined
        fdom = [df, fmax];
    else
        %/ default fdom includes all real frequencies
        fdom = [0, fmax];
    end
    
    %// discretize frequency domain and evaluate magnitudes of complex (fast) Fourier transform
    f = generate1DGridPoints(fdom(1), fdom(2), df);
    uo = abs(nufft(u, t, f) / N);
    
    %/ sum conjugate pairs (i.e., multiply 1-sided expansion by 2) to get total amplitudes
    uo(f ~= 0) = 2 * uo(f ~= 0); % except at zero frequency, which has no conjugate pair
    
    %/ if there is an odd number of time instants, then amplitude at fmax also has no conjugate pair
    if (~rem(N, 2))
        uo(f == fmax) = uo(f == fmax) / 2;
    end
    
    %// lastly, convert domain to specified frequency type other than 'cyclic'
    switch ftype
        case 'angular'
            f = 2 * pi * f; % conversion: '\omega = 2 \pi f'
        case 'periodic'
            %/ since cyclic domain is being inverted, periodic domain needs to rotate 180-degrees
            f = flip(1 ./ f); % conversion: 'T = frac{1}{f}'
            uo = flip(uo);
            
            %/ assume amplitude at fmax extrapolates out to periodic singularity at a constant rate
            if (fdom(2) == fmax)
                f = [0, f];
                uo = [uo(1), uo];
            end
    end
end

%%% Helper function for parsing input parameters, setting defaults, and validating data types
function [params, tokens] = validParams(t, u, varargin)
    %// validate required inputs
    validateattributes(t, {'numeric'}, {'vector', 'increasing'}, 1)
    validateattributes(u, {'numeric'}, {'vector', 'numel', length(t), 'real'}, 2)
    
    %// create parser object for additional inputs controlling data processing of time and frequency
    params = inputParser;
    
    %/ general description of how time domain is discretized to decide how to properly set up a 
    %/ frequency domain... here's what they mean:
    %/     uniform - nearly all time instants have exactly equal spacing between one another
    %/     semiuniform - small deviations in size of many intervals, but roughly uniform overall
    %/     nonuniform - large deviations in size of some or all intervals; severe irregularities
    valid_discretization = @(x) validatestring(x, {'uniform', 'semiuniform', 'nonuniform'});
    addParameter(params, 'Distribution', 'uniform', @(x) any(valid_discretization(x)));
    
    %/ type of abscissa to be paired with amplitudes
    valid_ftype = @(x) validatestring(x, {'cyclic', 'angular', 'periodic'});
    addParameter(params, 'FrequencyType', 'cyclic', @(x) any(valid_ftype(x)));
    
    %/ lower and upper bounds of frequency domain - if type not supplied, assumed to be cyclic
    valid_fdom = @(x) validateattributes(x, {'numeric'},...
                                         {'vector', 'numel', 2, 'increasing', 'nonnegative'});
    addParameter(params, 'Domain', [], valid_fdom);
    
    %/ run parser
    parse(params, varargin{:});
    
    %/ re-run string validators and create pointers to expected inputs from only partial matches
    tokens.Distribution = valid_discretization(params.Results.Distribution);
    tokens.FrequencyType = valid_ftype(params.Results.FrequencyType);
end