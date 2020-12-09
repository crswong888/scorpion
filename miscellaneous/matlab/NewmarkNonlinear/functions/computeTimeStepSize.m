%%% Computes an adequate time step size in accordance with A.K. Chopra (2014), Section 5.5.1.
%%%
%%% Chopra reccomends that dt < 1 / 10 / f. This will achieve adequate numerical representations
%%% of harmonics and Newmark integration stability. However, for nonlinear problems, the time step
%%% size should be smaller, say dt < 1 / 20 / f, to ensure convergence is achieved and so that
%%% restoring forces at yield points, where slope suddenly changes, may be estimated more precisely.
%%%
%%% By: Christopher Wong | crswong888@gmail.com

function dt = computeTimeStepSize(omega_n, omegaBar, varargin)
    %// parse additional argument controlling wether or not to use Chopra's orginal reccomendation
    %// or an even smaller value more appropriate for nonlinear problems
    params = inputParser;
    addParameter(params, 'Nonlinear', false, @(x) islogical(x));
    parse(params, varargin{:});

    %// use largest between natural frequency and frequency of harmonic forcing function
    omega = max([omegaBar, omega_n]);
    
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