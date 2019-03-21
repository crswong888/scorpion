clear all

N = 11 ;
T = 0.05 ;

dt = 1E-4 ;
t = 0 : dt : T ;
t_N = length(t) ; 

SLE = zeros(6,6,N) ;
C = zeros(6,1,N) ;
homg = zeros(6,1) ;

beta = 1/4 ;
gamma = 1/2 ;

u_dot_dot(1) = 0 ;
u_dot(1) = 0 ;
u_(1) = 0 ;

for i = 1:t_N - 1
    if t(i) < 0.05 - dt
        u_dot_dot(i+1) = - (200 * pi)^2 * sin(200 * pi * t(i+1)) ;
    else
        u_dot_dot(i+1) = 0 ;
    end
    u_dot(i+1) = u_dot(i) + (1-gamma) * dt * u_dot_dot(i) + gamma * dt * u_dot_dot(i+1) ;
    u_(i+1) = u_(i) + dt * u_dot(i) + (0.5 - beta) * dt * dt * u_dot_dot(i) + beta * dt * dt * u_dot_dot(i+1) ;
end

for n = 1:N
    
    if rem(n,2) ~= 0
    
    v(n) = (n + 1) * pi ;
    
    CS_plus(n) = sqrt(3) * cos(v(n) / 2) + sin(v(n) / 2) ;
    CS_min(n) = sqrt(3) * cos(v(n) / 2) - sin(v(n) / 2) ;
    
    SC_plus(n) = sqrt(3) * sin(v(n) / 2) + cos(v(n) / 2) ;
    SC_min(n) = sqrt(3) * sin(v(n) / 2) - cos(v(n) / 2) ;
    
    e_plus(n) = exp(sqrt(3) * v(n) / 2) ;
    e_min(n) = exp(-sqrt(3) * v(n) / 2) ;
    
    SLE(:,:,n) = [1 0 1 0 1 0 ;
        
                  0 2 sqrt(3) 1 -sqrt(3) 1 ;
                  
                  -2 0 1 sqrt(3) 1 -sqrt(3) ;
                  
                  cos(v(n)) sin(v(n)) e_plus(n)*cos(v(n)/2) ...
                    e_plus(n)*sin(v(n)/2) e_min(n)*cos(v(n)/2) e_min(n)*sin(v(n)/2) ;
                    
                  -2*sin(v(n)) 2*cos(v(n)) e_plus(n)*CS_min(n) ...
                    e_plus(n)*SC_plus(n) -e_min(n)*CS_plus(n) -e_min(n)*SC_min(n) ;
                  
                  -2*cos(v(n)) -2*sin(v(n)) -e_plus(n)*SC_min(n) ...
                    e_plus(n)*CS_plus(n) e_min(n)*SC_plus(n) -e_min(n)*CS_min(n) ] ;
       
    C(:,:,n) = null(SLE(:,:,n)) ;
    
    lambda(n) = v(n) / T ;
    
    for i = 1:t_N
         
        Psi(n,i) = C(1,n) * cos(lambda(n) * t(i)) + C(2,n) * sin(lambda(n) * t(i)) ...
            + exp(sqrt(3) * lambda(n) * t(i) / 2) * ( C(3,n) * cos(lambda(n) * t(i) / 2) ...
            + C(4,n) * sin(lambda(n) * t(i) / 2) ) + exp(-sqrt(3) * lambda(n) * t(i) / 2) ...
            * ( C(5,n) * cos(lambda(n) * t(i) / 2) + C(6,n) * sin(lambda(n) * t(i) / 2) ) ;
         
        Psi_dot(n,i) = lambda(n) / 2 * ( -2 * C(1,n) * sin(lambda(n) * t(i)) ...
            + 2 * C(2,n) * cos(lambda(n) * t(i)) + exp(sqrt(3) * lambda(n) * t(i) / 2) ...
            * ( C(3,n) * ( sqrt(3) * cos(lambda(n) * t(i) / 2) - sin(lambda(n) * t(i) / 2) ) ...
            + C(4,n) * ( cos(lambda(n) * t(i) / 2) + sqrt(3) * sin(lambda(n) * t(i) / 2) ) ) ...
            - exp(-sqrt(3) * lambda(n) * t(i) / 2) * ( C(5,n) * ( sqrt(3) ...
            * cos(lambda(n) * t(i) / 2) + sin(lambda(n) * t(i) / 2) ) + C(6,n) ...
            * ( -cos(lambda(n) * t(i) / 2) + sqrt(3) * sin(lambda(n) * t(i) / 2) ) ) ) ;
         
        Psi_dot_dot(n,i) = lambda(n)^2 / 2 * ( -2 * C(1,n) * cos(lambda(n) * t(i)) ...
            - 2 * C(2,n) * sin(lambda(n) * t(i)) + exp(sqrt(3) * lambda(n) * t(i) / 2) ...
            * ( C(3,n) * ( cos(lambda(n) * t(i) / 2) - sqrt(3) * sin(lambda(n) * t(i) / 2) ) ...
            + C(4,n) * ( sqrt(3) * cos(lambda(n) * t(i) / 2) + sin(lambda(n) * t(i) / 2) ) ) ...
            + exp(-sqrt(3) * lambda(n) * t(i) / 2) * ( C(5,n) * ( cos(lambda(n) * t(i) / 2) ...
            + sqrt(3) * sin(lambda(n) * t(i) / 2) ) + C(6,n) * ( -sqrt(3) ...
            * cos(lambda(n) * t(i) / 2) + sin(lambda(n) * t(i) / 2) ) ) ) ;
        
        Psi2_dot_dot(n,i) = Psi_dot_dot(n,i)^2 ;
       
    end
     
    end
end

A = u_dot_dot ;
a = zeros(n,1) ;
integral = zeros(n,1) ;

for i = 1:t_N - 2
    x_i = i * T / t_N ;
    x_i_plus_1 = (i + 1) * T / t_N ;
    for n = 1:N
        if rem(n,2) ~= 0
            integral(n) = 0.5 * sum((x_i_plus_1 - x_i)*(Psi2_dot_dot(n,i+1) + Psi2_dot_dot(n,i))) ;
            a(n) = 1 / integral(n) * sum(A(i)*Psi_dot_dot(n,i))*dt ;
        end
    end
end

for n = 1:N
    for i = 1:t_N 
        V(i) = sum(a(n)*Psi_dot(n,i)) ;
        D(i) = sum(a(n)*Psi(n,i)) ;
    end
end

for i = 1:2*t_N-1
    if i < 501
        A(i) = A(i) ;
        V(i) = V(i) ;
        D(i) = D(i) ;
    else
        A(i) = 0 ;
        V(i) = 0 ;
        D(i) = 0 ;
    end
end

figure(1)
plot(0:dt:0.1,A)
figure(2)
plot(0:dt:0.1,V)
figure(3)
plot(0:dt:0.1,D)

% figure(4)
% plot(t,Psi(:,:))
% figure(5)
% plot(t,Psi_dot(:,:))
% figure(6)
% plot(t,Psi_dot_dot(:,:))