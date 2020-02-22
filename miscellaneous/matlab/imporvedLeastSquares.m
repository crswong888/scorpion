clear all
format longeng

plot_unadjusted = false ;
plot_adjustment1 = false ;
plot_adjustment2 = true ;

dt = 1e-03 ;
T = 0.4 ;
t = 0:dt:T ;
NT = length(t) ;
N = 4 ; % approximation order = N - 1 (SHOULD BE <= 10)

d2u = zeros(1,NT) ;
for i = 1:NT
    d2u(i) = 5.1 * (40 * pi)^2 * sin(40 * pi * t(i)) ;
end

% folder = 'ChiChi' ;
% data = 'RSN1204_CHICHI_CHY039-E' ;
% [d2u,dt,NT] = readPEER(folder,cat(2,data,'.AT2')) ;
% d2u = d2u * 981 ; % convert from gs to cm/s^2
% realV = readPEER(folder,cat(2,data,'.VT2')) ;
% realD = readPEER(folder,cat(2,data,'.DT2')) ;
% 
% d2u = cat(2,0,transpose(d2u)) ; NT = NT + 1 ;
% realV = cat(2,0,transpose(realV)) ;
% realD = cat(2,0,transpose(realD)) ;
% T = dt * (NT - 1) ;
% t = 0:dt:T ;
% N = 4 ; % approximation order = N - 1
% 
% %%%%%%%%%%%%%
% T = 76.17 ;
% t0 = 26 ;
% 
% istart = t0 / dt + 1;
% iend = T / dt + 1 ;
% NT = iend - istart + 1 ;
% 
% d2u = d2u(istart:iend);
% t = 0:dt:T-t0;
% %%%%%%%%%%%%%

beta = 1 / 4 ;
gamma = 1 / 2 ;


% COMPUTE UNADJUSTED TIME HISTORIES WITH NEWMARK
% --------------------------------------------------------------------------------------------------

du = zeros(1,NT) ;
u = zeros(1,NT) ;
for i = 1:NT-1
    du(i+1) = du(i) + (1 - gamma) * dt * d2u(i) + gamma * dt * d2u(i+1) ;
    u(i+1) = u(i) + dt * du(i) + (1 / 2 - beta) * dt^2 * d2u(i) + beta * dt^2 * d2u(i+1) ;
end


% COMPUTE ADJUSTED TIME HISTORIES WITH VELOCITY FIT
% --------------------------------------------------------------------------------------------------

K = zeros(N,N) ;
for k = 1:N
    for j = 1:N
        K(k,j) = (j + 1) * T^(k + j + 1) / (k + j + 1) ;
    end
end

[L,U,perm] = lu(K) ; % LU factorization with row-reordering permuation matrix

I = zeros(N,1) ; i = 1 ;
while i <= NT-1
    for k = 1:N
        I(k) = I(k) + dt * t(i)^k * du(i) ...
                    + (1 / 2 - beta) * dt^2 * (t(i)^k * d2u(i) + k * t(i)^(k - 1) * du(i)) ...
                    + beta * dt^2 * (t(i+1)^k * d2u(i+1) + k * t(i+1)^(k - 1) * du(i+1)) ;
    end, i = i + 1 ;
end

C = U \ (L \ perm * I) ; % solve the LU system

d2P = zeros(1,NT) ; dP = zeros(1,NT) ; P = zeros(1,NT) ;
d2uStar = zeros(1,NT) ; duStar = zeros(1,NT) ; uStar = zeros(1,NT) ;
for i = 1:NT
    for k = 1:N
        d2P(i) = d2P(i) + (k * k + k) * C(k) * t(i)^(k-1) ;
        dP(i) = dP(i) + (k + 1) * C(k) * t(i)^k ;
        P(i) = P(i) + C(k) * t(i)^(k+1) ;
    end
    d2uStar(i) = d2u(i) - d2P(i) ;
    duStar(i) = du(i) - dP(i) ;
    uStar(i) = u(i) - P(i) ;
end


% COMPUTE ADJUSTED TIME HISTORIES WITH DISPLACEMENT FIT
% --------------------------------------------------------------------------------------------------

KStar = zeros(N,N) ;
for k = 1:N
    for j = 1:N
        KStar(k,j) = T^(k + j + 3) / (k + j + 3) ;
    end
end

[L,U,perm] = lu(KStar) ; % LU factorization with row-reordering permuation matrix

IStar = zeros(N,1) ; i = 1 ;
while i <= NT-1
    for k = 1:N
        IStar(k) = IStar(k) + dt * (t(i+1)^(k+1) * uStar(i+1) + t(i)^(k+1) * uStar(i)) ;
    end, i = i + 1 ;
end, IStar = IStar / 2 ;

CStar = U \ (L \ perm * IStar) ; % solve the LU system

d2PStar = zeros(1,NT) ; dPStar = zeros(1,NT) ; PStar = zeros(1,NT) ;
d2uStar2 = zeros(1,NT) ; duStar2 = zeros(1,NT) ; uStar2 = zeros(1,NT) ;
for i = 1:NT
    for k = 1:N
        d2PStar(i) = d2PStar(i) + (k * k + k) * CStar(k) * t(i)^(k-1) ;
        dPStar(i) = dPStar(i) + (k + 1) * CStar(k) * t(i)^k ;
        PStar(i) = PStar(i) + CStar(k) * t(i)^(k+1) ;
    end
    d2uStar2(i) = d2uStar(i) - d2PStar(i) ;
    duStar2(i) = duStar(i) - dPStar(i) ;
    uStar2(i) = uStar(i) - PStar(i) ;
end


% GENERATE PLOTS
% --------------------------------------------------------------------------------------------------

if (plot_unadjusted == true)
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
    grid on
    grid minor

    figure(3)
    plot(t,u)
    grid on
    grid minor
end

if (plot_adjustment1 == true)
    figure(4)
    plot(t,d2uStar,'color',[1 0 0])
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

if (plot_adjustment2 == true)
    figure(7)
    plot(t,d2uStar2,'color',[0 1 0])
    grid on
    grid minor

    figure(8)
    plot(t,duStar2,'color',[0 1 0])
    grid on
    grid minor

    figure(9)
    plot(t,uStar2,'color',[0 1 0])
    grid on
    grid minor
end