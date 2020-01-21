clear all
format longeng

N = 30 ;
T = 10 ;

dt = 0.01 ;
t = 0 : dt : T ;
N_T = length(t) ; 

coefficients = zeros(6,6,N) ;
first3Rows = [  1 0       1       0        1        0 ;
                0 2 sqrt(3)       1 -sqrt(3)        1 ;
               -2 0       1 sqrt(3)        1 -sqrt(3) ] ;



C = zeros(6,N) ;

psi = zeros(N,N_T) ; psi_dot = zeros(N,N_T) ; psi_dot_dot = zeros(N,N_T) ;

det_tol = 1e-06 ;

for n = 1:N
    
    v(n) = (n + 1) * pi ;
    
    CS_plus = sqrt(3) * cos(v(n) / 2) + sin(v(n) / 2) ;
    CS_min = sqrt(3) * cos(v(n) / 2) - sin(v(n) / 2) ;
    
    SC_plus = sqrt(3) * sin(v(n) / 2) + cos(v(n) / 2) ;
    SC_min = sqrt(3) * sin(v(n) / 2) - cos(v(n) / 2) ;
    
    e_plus = exp(sqrt(3) * v(n) / 2) ;
    e_min = exp(-sqrt(3) * v(n) / 2) ;
    
    coefficients(1:3,:,n) = first3Rows ;
    coefficients(4:6,:,n) = [          cos(v(n))         sin(v(n)) e_plus*cos(v(n)/2) ...
                              e_plus*sin(v(n)/2) e_min*cos(v(n)/2)  e_min*sin(v(n)/2) ;
                    
                                    -2*sin(v(n))       2*cos(v(n))      e_plus*CS_min ...
                                  e_plus*SC_plus    -e_min*CS_plus      -e_min*SC_min ;
                  
                                    -2*cos(v(n))      -2*sin(v(n))     -e_plus*SC_min ...
                                  e_plus*CS_plus     e_min*SC_plus      -e_min*CS_min ] ;
    
    detCoefficients = 8 * sin(v(n) / 2) - sin(2 * v(n) / 2) - 16 * sin(v(n) / 2) ...
                      * cosh(sqrt(3) * v(n) / 2) + 2 * sin(v(n)) * cosh(sqrt(3) * v(n)) ;
    
    if abs(det(coefficients(:,:,n))) >= det_tol, continue, end        
    
    C(:,n) = null(coefficients(:,:,n)) ;
    
    lambda = v(n) / T ;
    
    for i = 1:N_T
         
        psi(n,i) = C(1,n) * cos(lambda * t(i)) + C(2,n) * sin(lambda * t(i)) ...
            + exp(sqrt(3) * lambda * t(i) / 2) * ( C(3,n) * cos(lambda * t(i) / 2) ...
            + C(4,n) * sin(lambda * t(i) / 2) ) + exp(-sqrt(3) * lambda * t(i) / 2) ...
            * ( C(5,n) * cos(lambda * t(i) / 2) + C(6,n) * sin(lambda * t(i) / 2) ) ;
         
        psi_dot(n,i) = lambda / 2 * ( -2 * C(1,n) * sin(lambda * t(i)) ...
            + 2 * C(2,n) * cos(lambda * t(i)) + exp(sqrt(3) * lambda * t(i) / 2) ...
            * ( C(3,n) * ( sqrt(3) * cos(lambda * t(i) / 2) - sin(lambda * t(i) / 2) ) ...
            + C(4,n) * ( cos(lambda * t(i) / 2) + sqrt(3) * sin(lambda * t(i) / 2) ) ) ...
            - exp(-sqrt(3) * lambda * t(i) / 2) * ( C(5,n) * ( sqrt(3) ...
            * cos(lambda * t(i) / 2) + sin(lambda * t(i) / 2) ) + C(6,n) ...
            * ( -cos(lambda * t(i) / 2) + sqrt(3) * sin(lambda * t(i) / 2) ) ) ) ;
         
        psi_dot_dot(n,i) = lambda^2 / 2 * ( -2 * C(1,n) * cos(lambda * t(i)) ...
            - 2 * C(2,n) * sin(lambda * t(i)) + exp(sqrt(3) * lambda * t(i) / 2) ...
            * ( C(3,n) * ( cos(lambda * t(i) / 2) - sqrt(3) * sin(lambda * t(i) / 2) ) ...
            + C(4,n) * ( sqrt(3) * cos(lambda * t(i) / 2) + sin(lambda * t(i) / 2) ) ) ...
            + exp(-sqrt(3) * lambda * t(i) / 2) * ( C(5,n) * ( cos(lambda * t(i) / 2) ...
            + sqrt(3) * sin(lambda * t(i) / 2) ) + C(6,n) * ( -sqrt(3) ...
            * cos(lambda * t(i) / 2) + sin(lambda * t(i) / 2) ) ) ) ;
        
    end
    
end
 
% figure(1)
% plot(0:dt:0.1,A)
% figure(2)
% plot(0:dt:0.1,V)
% figure(3)
% plot(0:dt:0.1,D)

% V_prime = diff(V)/dt ;
% figure
% plot(0:dt:0.1-dt,V_prime)

figure(4)
plot(t,psi(:,:))
% figure(5)
% plot(t,Psi_dot(:,:))
% figure(6)
% plot(t,Psi_dot_dot(:,:))