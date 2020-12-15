%%% This function evaluates all three least squares polynomials used to correct the kinematic time 
%%% series at given instance in natural time 'tau'. 'J' is the Jacobian map of real time onto 'tau'.
%%%
%%% By: Christopher Wong | crswong888@gmail.com

function pfit = evaluatePolynomials(coeffs, tau, J)
    pfit = zeros(3, 1);
    for k = 1:length(coeffs)
        pfit(1) = pfit(1) + (k * k + k) * coeffs(k) * tau^(k - 1) / (J * J); % acceleration fit
        pfit(2) = pfit(2) + (k + 1) * coeffs(k) * tau^k / J; % velocity fit
        pfit(3) = pfit(3) + coeffs(k) * tau^(k + 1); % displacement fit
    end
end