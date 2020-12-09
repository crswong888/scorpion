%%% Solves the ordinary differential equation of motion for a viscously damped mass-spring system 
%%% that exhibits non-linear, cyclic, force-displacement behavior when subject to an arbitrary 
%%% external force.
%%%
%%% By: Christopher Wong | crswong888@gmail.com

function [t, d2u, du, u, fs_history] = solveEquationOfMotion(m, c, fs, ke, t, dt, du_initial,... 
                                                        u_initial, p, gamma, beta, R_tol, max_it)
    %// store upper and lower isotropic yield points (first point of backbone assumed to be yield)
    uy_top = fs(1,1); uy_bot = -uy_top; % yield displacement
    fy_top = fs(2,1); fy_bot = -fy_top; % yield force

    %// reflect supplied backbone through horizontal and vertical axes and combine with original
    fs = cat(2, -flip(fs,2), fs);

    %// allocate array of grid points along time domain and arrays of variable values for each
    [t, N] = generate1DGridPoints(t(1), t(2), dt);
    d2u = zeros(1, N); du = d2u; u = d2u; % acceleration, velocity, and displacement, respectively
    fs_history = zeros(1,N); % save restoring force value at each time for postprocessing

    %// set initial conditions
    du(1) = du_initial; u(1) = u_initial;

    %// compute initial restoring force and acceleration
    fs_history(1) = linearInterpolation(fs(1,:), fs(2,:), u(1), 'Extrapolate', true);
    d2u(1) = (p(t(1)) - c * du(1) - fs_history(1)) / m;

    %// compute constants in Newmark integrals
    a = [1 / (2 * beta) - 1; 
         1 / (beta * dt); 
         1 / (beta * dt^2); 
         dt * (gamma / (2 * beta) - 1); 
         gamma / beta - 1];
    a(6) = gamma * a(2);

    %// compute constants in equation of motion
    b = m * a(1:3) + c * a(4:6);

    %// loop through all time points and solve nonlinear equation of motion at each
    k = ke; yielded = false; % initialize stuff
    for i = 1:(N - 1)
        fprintf('Time = %g\n', t(i));

        %/ most of residual is invariant - no need to recalculate this during nonlinear iterations
        const = p(t(i+1)) + b(1) * d2u(i) + b(2) * du(i) + b(3) * u(i);

        %/ if unloading from plastic, shift yield point of backbone curve to current fs(u)
        if (yielded && (delta_u * (const / (k + b(3)) - u(i)) <= nthroot(R_tol, 1.5)))
            % compute horizontal and vertical shifts
            if (fs_history(i) >= 0)
                horizontal_shift = u(i) - uy_top;
                vertical_shift = fs_history(i) - fy_top;
            else
                horizontal_shift = u(i) - uy_bot;
                vertical_shift = fs_history(i) - fy_bot;
            end

            % shift abscissa-ordinate pairs
            fs(1,:) = fs(1,:) + horizontal_shift * ones(1, length(fs(1,:)));
            fs(2,:) = fs(2,:) + vertical_shift * ones(1, length(fs(2,:)));

            % update state variables
            uy_top = uy_top + horizontal_shift ; fy_top = fy_top + vertical_shift;
            uy_bot = uy_bot + horizontal_shift ; fy_bot = fy_bot + vertical_shift;
            k = ke; % tangent stiffness is elastic again
            yielded = false; % rebounded, so no longer yielding
        end

        %/ set initial guess for root of residual as linear case
        u(i+1) = const / (k + b(3));

        %/ define residual R(u) = 0 and begin Newton-Rapshon procedure
        R = @(u) (const - b(3) * u - linearInterpolation(fs(1,:), fs(2,:), u, 'Extrapolate', true));
        u(i+1) = newtonSolve(R, [u(i), u(i+1)], max_it, R_tol);

        %/ use a single point forward difference to compute current tangent stiffness
        delta_u = u(i+1) - u(i);
        fs_history(i+1) = linearInterpolation(fs(1,:), fs(2,:), u(i+1), 'Extrapolate', true);
        k = (fs_history(i+1) - fs_history(i)) / delta_u;

        %/ if tangent stiffness not equal to elastic one - system has gone plastic
        if (~yielded && (abs(k - ke) / ke >= R_tol)) % check against R_tol to avoid small errors
            yielded = true;
        end 

        %/ update acceleration and velocity
        d2u(i+1) = -a(1) * d2u(i) - a(2) * du(i) + a(3) * (u(i+1) - u(i));
        du(i+1) = -a(4) * d2u(i) - a(5) * du(i) + a(6) * (u(i+1) - u(i));
    end
    
    fprintf('Time = %g\n\nSOLVE COMPLETE!\n', t(N));
    fprintf('--------------------------------------------------------------\n\n')
end