clear all

N = 19 ;
T = 25 ;

dt = 0.1 ;
t = 0 : dt : T ;
t_N = length(t) ; 

SLE = zeros(6,6,N) ;

for n = 1:N
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
                
    C = null(SLE(6,:,n)) ;
    
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
             * ( -sqrt(3) * cos(lambda(n) * t(i) / 2) + sin(lambda(n) * t(i) / 2) ) ) ) ;
         
         Psi_dot_dot(n,i) = lambda(n)^2 / 2 * ( -2 * C(1,n) * cos(lambda(n) * t(i)) ...
             - 2 * C(2,n) * sin(lambda(n) * t(i)) + exp(sqrt(3) * lambda(n) * t(i) / 2) ...
             * ( C(3,n) * ( cos(lambda(n) * t(i) / 2) - sqrt(3) * sin(lambda(n) * t(i) / 2) ) ...
             + C(4,n) * ( sqrt(3) * cos(lambda(n) * t(i) / 2) + sin(lambda(n) * t(i) / 2) ) ) ...
             + exp(-sqrt(3) * lambda(n) * t(i) / 2) * ( C(5,n) * ( cos(lambda(n) * t(i) / 2) ...
             + sqrt(3) * sin(lambda(n) * t(i) / 2) ) + C(6,n) * ( -sqrt(3) ...
             * cos(lambda(n) * t(i) / 2) + sin(lambda(n) * t(i) / 2) ) ) ) ;
     end
end

figure(1)
plot(t,Psi(N,:))
figure(2)
plot(t,Psi_dot(N,:))
figure(3)
plot(t,Psi_dot_dot(N,:))