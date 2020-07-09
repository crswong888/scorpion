function [d2u, NT, dt, file] = findWorstDrift(path, ftype, gamma, beta, chktype)
    
    %%% ftype should indicate a file type to search for. Just assuming a *vdc* for now...
    
    files = dir(fullfile([path '/' ftype]));
    maxval = 0;
    for fname = 1:length(files)
        %// get acceleration time history data
        [d2u, NT, dt] = readVDC(path, files(fname).name);
        
        %// integrate with Newmark
        du_old = 0; %area = 0;
        u = zeros(1, NT);
        for i = 1 : NT - 1
            du = du_old + (1 - gamma) * dt * d2u(i) + gamma * dt * d2u(i+1);
            u(i+1) = u(i) + dt * du_old + (1 / 2 - beta) * dt^2 * d2u(i) + beta * dt^2 * d2u(i+1);
            %area = area + dt * (u(i) + u(i+1));
            du_old = du;
        end

        %area = abs(area) / 2 ; % take the absolute area and apply constant for trapezoidal rule
        
        %// update the worst drift index
        if (strcmp(chktype, 'avg'))
            current = abs(mean(u / max(abs(u)))) ;
            %current = abs(mean(u / area));
        elseif (strcmp(chktype, 'stddev'))
            current = std(u / max(abs(u)));
        end
        if (current > maxval)
            maxval = current;
            worst = fname;
        end
    end
    
    file = files(worst).name;
    [d2u, NT, dt] = readVDC(path, file);
    
end