clear all
format longeng


% INPUT PARAMETERS
% --------------------------------------------------------------------------------------------------

dt = 0.1 ;
T = 2 ;
t = 0:dt:T ;
NT = length(t) ;
N = 3 ; % approximation order = N - 1 (SHOULD BE <= 10)

gamma = 1 / 2 ;
beta = 1 / 4 ;

adjust_accel = true ;
adjust_vel = false ;
adjust_disp = false ;

integrate_corrected_accel = true ;
scale_factor = 1 ; % scale = desired / result

plot_unadjusted = false ;
plot_adjusted = true ;


% GENERATE ACCELERATION TIME HISTORY
% --------------------------------------------------------------------------------------------------

d2u = zeros(1,NT) ;
for i = 1:NT
    d2u(i) = pi * pi * sin(pi * t(i)) ;
end


% COMPUTE NOMINAL TIME HISTORIES WITH NEWMARK
% --------------------------------------------------------------------------------------------------

du = zeros(1,NT) ;
u = zeros(1,NT) ;
for i = 1:NT-1
    du(i+1) = du(i) + (1 - gamma) * dt * d2u(i) + gamma * dt * d2u(i+1) ;
    u(i+1) = u(i) + dt * du(i) + (1 / 2 - beta) * dt^2 * d2u(i) + beta * dt^2 * d2u(i+1) ;
end

%// initialize the adjusted time histories as the unadjusted
d2uStar = d2u ; duStar = du ; uStar = u ;


% COMPUTE ADJUSTED TIME HISTORIES WITH ACCELERATION FIT
% --------------------------------------------------------------------------------------------------

if (adjust_accel == true)
    K = zeros(N,N) ;
    for k = 1:N
        for j = 1:N
            K(k,j) = (j * j + j) * T^(k + j - 1) / (k + j - 1) ;
        end
    end

    [L,U,perm] = lu(K) ; % LU factorization with row-reordering permuation matrix

    I = zeros(N,1) ; i = 1 ;
    while i <= NT-1
        for k = 1:N
            I(k) = I(k) + (1 - gamma) * dt * t(i)^(k - 1) * d2uStar(i) ...
                        + gamma * dt * t(i+1)^(k - 1) * d2uStar(i+1) ;
        end, i = i + 1 ;
    end

    C = U \ (L \ perm * I) ; % solve the LU system
    
    d2P = zeros(1,NT) ; dP = zeros(1,NT) ; P = zeros(1,NT) ;
    for i = 1:NT
        for k = 1:N
            d2P(i) = d2P(i) + (k * k + k) * C(k) * t(i)^(k-1) ;
            dP(i) = dP(i) + (k + 1) * C(k) * t(i)^k ;
            P(i) = P(i) + C(k) * t(i)^(k+1) ;
        end
        d2uStar(i) = d2uStar(i) - d2P(i) ;
        duStar(i) = duStar(i) - dP(i) ;
        uStar(i) = uStar(i) - P(i) ;
    end
end


% COMPUTE ADJUSTED TIME HISTORIES WITH VELOCITY FIT
% --------------------------------------------------------------------------------------------------

if (adjust_vel == true)
    K = zeros(N,N) ;
    for k = 1:N
        for j = 1:N
            K(k,j) = (j + 1) * T^(k + j + 1) / (k + j + 1) ;
        end
    end

    [L,U,perm] = lu(K) ;

    I = zeros(N,1) ; i = 1 ;
    while i <= NT-1
        for k = 1:N
            I(k) = I(k) + dt * t(i)^k * duStar(i) + (0.5 - beta) * dt * dt ...
                        * (t(i)^k * d2uStar(i) + k * t(i)^(k - 1) * duStar(i)) + beta * dt * dt ...
                        * (t(i+1)^k * d2uStar(i+1) + k * t(i+1)^(k - 1) * duStar(i+1)) ;
        end, i = i + 1 ;
    end

    C = U \ (L \ perm * I) ;
    
    d2P = zeros(1,NT) ; dP = zeros(1,NT) ; P = zeros(1,NT) ;
    for i = 1:NT
        for k = 1:N
            d2P(i) = d2P(i) + (k * k + k) * C(k) * t(i)^(k-1) ;
            dP(i) = dP(i) + (k + 1) * C(k) * t(i)^k ;
            P(i) = P(i) + C(k) * t(i)^(k+1) ;
        end
        d2uStar(i) = d2uStar(i) - d2P(i) ;
        duStar(i) = duStar(i) - dP(i) ;
        uStar(i) = uStar(i) - P(i) ;
    end
end


% COMPUTE ADJUSTED TIME HISTORIES WITH DISPLACEMENT FIT
% --------------------------------------------------------------------------------------------------

if (adjust_disp == true)
    K = zeros(N,N) ;
    for k = 1:N
        for j = 1:N
            K(k,j) = T^(k + j + 3) / (k + j + 3) ;
        end
    end

    [L,U,perm] = lu(K) ;

    I = zeros(N,1) ; i = 1 ;
    while i <= NT-1
        for k = 1:N
            I(k) = I(k) + dt * (t(i+1)^(k+1) * uStar(i+1) + t(i)^(k+1) * uStar(i)) ;
        end, i = i + 1 ;
    end, I = I / 2 ;

    C = U \ (L \ perm * I) ;
    
    d2P = zeros(1,NT) ; dP = zeros(1,NT) ; P = zeros(1,NT) ;
    for i = 1:NT
        for k = 1:N
            d2P(i) = d2P(i) + (k * k + k) * C(k) * t(i)^(k-1) ;
            dP(i) = dP(i) + (k + 1) * C(k) * t(i)^k ;
            P(i) = P(i) + C(k) * t(i)^(k+1) ;
        end
        d2uStar(i) = d2uStar(i) - d2P(i) ;
        duStar(i) = duStar(i) - dP(i) ;
        uStar(i) = uStar(i) - P(i) ;
    end
end


% INTEGRATE CORRECTED ACCEL AND APPLY SCALE FACTOR IF DESIRED
% --------------------------------------------------------------------------------------------------

if (integrate_corrected_accel)
    d2uStar = scale_factor * d2uStar ;
    
    for i = 1:NT-1
        duStar(i+1) = duStar(i) + (1 - gamma) * dt * d2uStar(i) + gamma * dt * d2uStar(i+1) ;
        uStar(i+1) = uStar(i) + dt * duStar(i) + (1 / 2 - beta) * dt^2 * d2uStar(i) + beta * dt^2 * d2uStar(i+1) ;
    end
end


% GENERATE PLOTS
% --------------------------------------------------------------------------------------------------

if (plot_unadjusted)
    figure(1)
    plot(t,d2u)
    hold on
    set(gca,'fontname','arial','fontsize',12)
    title('Acceleration Time History')
    ylabel ('\fontname{cambria math}{\ita}({\itt})\fontname{arial}, mm/s^{2}')
    xlabel ('\fontname{cambria math}{\itt}\fontname{arial}, s')
    grid on
    grid minor

    figure(2)
    plot(t,du)
    hold on
    set(gca,'fontname','arial','fontsize',12)
    title('Velocity Time History')
    ylabel ('\fontname{cambria math}{\itv}({\itt})\fontname{arial}, mm/s')
    xlabel ('\fontname{cambria math}{\itt}\fontname{arial}, s')
    grid on
    grid minor

    figure(3)
    plot(t,u)
    hold on
    set(gca,'fontname','arial','fontsize',12)
    title('Displacement Time History')
    ylabel ('\fontname{cambria math}{\ity}({\itt})\fontname{arial}, mm')
    xlabel ('\fontname{cambria math}{\itt}\fontname{arial}, s')
    grid on
    grid minor
end

if (plot_adjusted)
    figure(4)
    plot(t,d2uStar,'color',[1 0 0])
    hold on
    set(gca,'fontname','arial','fontsize',12)
    title('Adjusted Acceleration Time History')
    ylabel ('\fontname{cambria math}{\ita^{*}}({\itt})\fontname{arial}, mm/s^{2}')
    xlabel ('\fontname{cambria math}{\itt}\fontname{arial}, s')
    grid on
    grid minor

    figure(5)
    plot(t,duStar,'color',[1 0 0])
    hold on
    set(gca,'fontname','arial','fontsize',12)
    title('Adjusted Velocity Time History')
    ylabel ('\fontname{cambria math}{\itv^{*}}({\itt})\fontname{arial}, mm/s')
    xlabel ('\fontname{cambria math}{\itt}\fontname{arial}, s')
    grid on
    grid minor

    figure(6)
    plot(t,uStar,'color',[1 0 0])
    hold on
    set(gca,'fontname','arial','fontsize',12)
    title('Adjusted Displacement Time History')
    ylabel ('\fontname{cambria math}{\ity^{*}}({\itt})\fontname{arial}, mm')
    xlabel ('\fontname{cambria math}{\itt}\fontname{arial}, s')
    grid on
    grid minor
end
