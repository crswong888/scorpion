%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FE Environment for Solid Mechanics %%%
%%%        By: Christopher Wong        %%%
%%%        crswong888@gmail.com        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [qps, weights] = gaussRules(num_points)
    if (num_points == 1)
        qps = 0;
        weights = 2;
    elseif (num_points == 2)
        qps = 1 / sqrt(3) * [-1, 1];
        weights = [1, 1];
    elseif (num_points == 3)
        qps = sqrt(3 / 5) * [-1, 0, 1];
        weights = 1 / 9 * [5, 8, 5];
    end
end