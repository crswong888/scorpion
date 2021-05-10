%%% Computes an adequate time step size in accordance with A.K. Chopra (2014), Section 5.5.1.
%%%
%%% Chopra reccomends that 'dt < 1 / 10 / f'. This will achieve adequate numerical representations
%%% of harmonics and Newmark integration stability. However, for nonlinear problems, the time step
%%% size should be smaller, say 'dt < 1 / 20 / f', to ensure convergence is achieved and so that
%%% restoring forces at yield points, where slope suddenly changes, may be estimated more precisely.
%%%
%%% By: Christopher Wong | crswong888@gmail.com

function dt = computeTimeStepSize(t, omega_n, p, varargin)
    %// parse and validate function inputs
    params = validParams(t, omega_n, p, varargin{:});
    
    %// use largest between natural frequency and frequency of forcing func (determined by its FFT)
    omega = max(omega_n, maxForcingFrequency(t, p));
    
    %// compute appropriate coefficient and time step size
    coefficient = 1 / 10;
    if (params.Results.Nonlinear)
        coefficient = coefficient / 2;
    end
    dt = coefficient * 2 * pi / omega;
    
    %// round down to nearest half order of magnitude
    halfmag = 10^(sign(log10(dt)) * floor(abs(log10(dt)) + 1)) / 2;
    dt = floor(dt / halfmag) * halfmag;
end

%%% Helper function for parsing input parameters, setting defaults, and validating data types
function params = validParams(t, omega_n, p, varargin)
    %// validate required inputs
    validateattributes(t, {'numeric'}, {'vector', 'numel', 2, 'increasing'}, 1)
    validateattributes(omega_n, {'numeric'}, {'scalar', 'positive'}, 2)
    validateattributes(p, {'function_handle'}, {'scalar', 'real'}, 3)
    
    %// create parser object for additional input controlling whether or not to use Chopra's 
    %// orginal reccomendation or an even smaller value more appropriate for nonlinear problems
    params = inputParser;
    addParameter(params, 'Nonlinear', false, @(x) validateattributes(x, {'logical'}, {'scalar'}));
    
    %/ run parser
    parse(params, varargin{:})
end

%%% This helper function performs a 1-sided discrete Fourier transform of a dynamic force formatted 
%%% as an anonymous function 'p' that returns a value at each time instant in 't'. The object of 
%%% this is to determine the forcing frequency corresponding to the maximum frequency with an 
%%% amplitude that is at least 1% the maximum amplitude, which ultimately may control when selecting 
%%% a suitable time step size.
function omegaBar = maxForcingFrequency(t, p)
    %// evaluate forcing function along a reasonably fine time mesh (100,000 instants)
    t = linspace(t(1), t(2), 1e+05);
    p = p(t);

    %// frequency domain amplitudes smaller than 1% of largest amp are considered insignificant
    pTOL = max(p) / 100;
    
    %/ we also need to mark zero-padded portions at ends of signals to not be include in its FFT, as
    %/ these would be superfluous evaluations and introduce anomalies to frequency domain
    i = 1; j = length(t);
    while (round(p(i) / pTOL) * pTOL == 0), i = i + 1; end % 'i' is lower idx of significant portion
    while (round(p(j) / pTOL) * pTOL == 0), j = j - 1; end % 'j' is upper idx
    
    %// now perform FFT between time indices i and j in angular frequecy domain
    [omega_p, FFT] = discreteFourierTransform(t(i:j), p(i:j), 'FrequencyType', 'angular');
    
    %/ get local maxima freqs - ignore small amps likely to be mere artifacts of FFT algorithm
    [po, o] = findpeaks([0, FFT, 0]); % pad zeros to help findpeaks() algorithm
    
    %// now find max freequency of significant amplitudes and return
    omegaBar = max(omega_p(o(po >= pTOL) - 1)); % subtract one index to remove zero-padding shift
end