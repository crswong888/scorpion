clear all

dt = 1E-4 ;
t = 0 : dt : 0.1 ;
N = length(t) ;

beta = 1/4 ;
gamma = 1/2 ;

u_dot_dot(1) = 0 ;
u_dot(1) = 0 ;
u_(1) = 0 ;

for i = 1:N-1
    if t(i) < 0.05 -dt
        u_dot_dot(i+1) = - (200 * pi)^2 * sin(200 * pi * t(i+1)) ;
    else
        u_dot_dot(i+1) = 0 ;
    end
    u_dot(i+1) = u_dot(i) + (1-gamma) * dt * u_dot_dot(i) + gamma * dt * u_dot_dot(i+1) ;
    u_(i+1) = u_(i) + dt * u_dot(i) + (0.5 - beta) * dt * dt * u_dot_dot(i) + beta * dt * dt * u_dot_dot(i+1) ;
end
