clear all
format longeng

%// executioner parameters
dt = 1e-03 ;
T = 0.4 ;
t = 0:dt:T ;
NT = length(t) ;

%// generate acceleration time-history
d2u = zeros(1,NT) ;
for i = 1:NT
    d2u(i) = 5.1 * (40 * pi)^2 * sin(40 * pi * t(i)) ;
end

%// input constants from seismosignal's cubic correction=
C = [31329.42082, -710679.64392, 4179907.05603, -7018028.18437] ;

%// apply polynomial fit to acceleration
d2P = zeros(1,NT) ; d2uStar = zeros(1,NT) ;
for i = 1:NT
    for k = 1:4
        d2P(i) = d2P(i) + C(k) * t(i)^(k-1) ;
    end
    d2uStar(i) = d2u(i) - d2P(i) ;
end

%// integrate with Newmark
du = zeros(1,NT) ; u = zeros(1,NT) ;
beta = 1 / 4 ; gamma = 1 / 2 ;
for i = 1:NT-1
    du(i+1) = du(i) + (1 - gamma) * dt * d2uStar(i) + gamma * dt * d2uStar(i+1) ;
    u(i+1) = u(i) + dt * du(i) + (1 / 2 - beta) * dt^2 * d2uStar(i) + beta * dt^2 * d2uStar(i+1) ;
end

%// Generate plots
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
plot(t,d2uStar,'color',[1 0 0])
grid on
grid minor

figure(3)
plot(t,du)
grid on
grid minor

figure(4)
plot(t,u)
hold on
set(gca,'fontname','arial','fontsize',12)
title('Adjusted Displacement Time History')
ylabel ('\fontname{cambria math}{\ity^{*}}({\itt})\fontname{arial}, mm')
xlabel ('\fontname{cambria math}{\itt}\fontname{arial}, s')
grid on
grid minor