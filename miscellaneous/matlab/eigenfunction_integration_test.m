% SOLUTION CONVERGENCE SEEMS TO BE HEAVILY DEPENDENT ON THE TIME-STEP SIZE,
% THE LENGTH OF THE TIME DOMAIN T, THE NUMBER OF EIGNENPROBLEMS SOLVED N,
% AND THE TYPE OF ALGEBRAIC SOLVER USED....
% SIGNIFICANT NUMERICAL ERRORS ARISE

clear all
format longeng

% %// Input the solver parameters
% T = 0.4 ; % ending boundary of the time domain
% T = 0.0069 ;
% dt = 1e-04 ; % time step interval size
% t = 0:dt:T ; % discretize the time domain
% NT = length(t) ; % total number of time steps
% N = NT ; % do not use N > NT + 2!!
% N = 126 ;
% numPads = 100 ;
% 
% %// Numerically solve a specified acceleration time-history
% A = zeros(1,NT) ; % allocate the acceleration data
% for i = 1:NT
%    A(i) = 5.1 * (40 * pi)^2 * sin(40 * pi * t(i)) ; 
% end

[A,dt,NT] = readPEER('CoyoteLake','RSN148_COYOTELK_G03-UP.AT2') ;
A = cat(2,0,transpose(A)) ; NT = NT + 1 ;
T = dt * (NT - 1) ;
t = 0:dt:T ;
N = 129 ;
numPads = 100 ;

%// Add zero-padding acceleration at both ends of the time domain
num = 1 ;
while num <= numPads
    A = cat(2,0,A,0) ; t = cat(2,0,t+dt,T+2*dt) ;
    T = T + 2 * dt ; NT = length(t) ;
    num = num + 1 ;
end

%// Initialize the Eigenproblem variables
coeffs = zeros(6,6) ; % allocate the Eigenproblem coefficient matrix 
first3Rows = [  1 0       1       0        1        0 ;
                0 2 sqrt(3)       1 -sqrt(3)        1 ;
               -2 0       1 sqrt(3)        1 -sqrt(3) ] ; % compute the first 3 rows of coefficients
%nu = readtable('detMRoots.csv') ; nu = nu{1:N,1} ; % read in the eigenvalues
detM = @(nu) 8 * sin(nu) - sin(2 * nu) - 16 * sin(nu / 2) * cosh(sqrt(3) * nu / 2) ...
       + 2 * sin(nu) * cosh(sqrt(3) * nu) ; % function handle for the expression of the determinant
C = zeros(6,N) ; % allocate the vector of N solutions to the eigneproblem
psi = zeros(N,NT) ; psi_dot = zeros(N,NT) ; psi_dot_dot = zeros(N,NT) ; % allocate Eigenfunctions

nu = zeros(1,N) ;
%// Begin the Eigenfunction expansion procedure
for n = 1:N
    %/ attempt to find the roots of the determinant of the coefficient matrix
    approxRoot = (n + 1) * pi ;
    nu(n) = fzero(detM,approxRoot) ;
    
    %/ Compute some of the coefficient matrix
    CS_plus = sqrt(3) * cos(nu(n) / 2) + sin(nu(n) / 2) ;
    CS_min = sqrt(3) * cos(nu(n) / 2) - sin(nu(n) / 2) ;
    SC_plus = sqrt(3) * sin(nu(n) / 2) + cos(nu(n) / 2) ;
    SC_min = sqrt(3) * sin(nu(n) / 2) - cos(nu(n) / 2) ;
    e_plus = exp(sqrt(3) * nu(n) / 2) ;
    e_min = exp(-sqrt(3) * nu(n) / 2) ;
    
    %/ Compute the coefficient matrix
    coeffs(1:3,:) = first3Rows ; % Allocate the first 3 rows into the current matrix
    coeffs(4:6,:) = [          cos(nu(n))         sin(nu(n)) e_plus*cos(nu(n)/2) ...
                      e_plus*sin(nu(n)/2) e_min*cos(nu(n)/2)  e_min*sin(nu(n)/2) ;
                    
                            -2*sin(nu(n))       2*cos(nu(n))      e_plus*CS_min ...
                           e_plus*SC_plus     -e_min*CS_plus      -e_min*SC_min ;
                  
                            -2*cos(nu(n))      -2*sin(nu(n))     -e_plus*SC_min ...
                           e_plus*CS_plus      e_min*SC_plus      -e_min*CS_min ] ;      
    
    %/ Solve the Eigenproblem for the constants C1, C2, ..., C6
    nullSpace = null(coeffs) ;
    C(:,n) = nullSpace(:,end) ;
    
    lambda = nu(n) / T ;
    for i = 1:NT
        %/ Compute the Eigenvectors for the current timestep
        psi(n,i) = C(1,n) * cos(lambda * t(i)) + C(2,n) * sin(lambda * t(i)) ...
            + exp(sqrt(3) * lambda * t(i) / 2) * (C(3,n) * cos(lambda * t(i) / 2) ...
            + C(4,n) * sin(lambda * t(i) / 2)) + exp(-sqrt(3) * lambda * t(i) / 2) ...
            * (C(5,n) * cos(lambda * t(i) / 2) + C(6,n) * sin(lambda * t(i) / 2)) ;
        
        psi_dot(n,i) = lambda / 2 * ( -2 * C(1,n) * sin(lambda * t(i)) ...
            + 2 * C(2,n) * cos(lambda * t(i)) + exp(sqrt(3) * lambda * t(i) / 2) ...
            * (C(3,n) * (sqrt(3) * cos(lambda * t(i) / 2) - sin(lambda * t(i) / 2)) ...
            + C(4,n) * (cos(lambda * t(i) / 2) + sqrt(3) * sin(lambda * t(i) / 2))) ...
            - exp(-sqrt(3) * lambda * t(i) / 2) * (C(5,n) * (sqrt(3) ...
            * cos(lambda * t(i) / 2) + sin(lambda * t(i) / 2)) + C(6,n) ...
            * (-cos(lambda * t(i) / 2) + sqrt(3) * sin(lambda * t(i) / 2)))) ;
         
        psi_dot_dot(n,i) = lambda^2 / 2 * (-2 * C(1,n) * cos(lambda * t(i)) ...
            - 2 * C(2,n) * sin(lambda * t(i)) + exp(sqrt(3) * lambda * t(i) / 2) ...
            * (C(3,n) * (cos(lambda * t(i) / 2) - sqrt(3) * sin(lambda * t(i) / 2)) ...
            + C(4,n) * (sqrt(3) * cos(lambda * t(i) / 2) + sin(lambda * t(i) / 2))) ...
            + exp(-sqrt(3) * lambda * t(i) / 2) * (C(5,n) * (cos(lambda * t(i) / 2) ...
            + sqrt(3) * sin(lambda * t(i) / 2)) + C(6,n) * (-sqrt(3) ...
            * cos(lambda * t(i) / 2) + sin(lambda * t(i) / 2)))) ;
    end
end

%psi = -psi ; psi_dot = -psi_dot ; psi_dot_dot = -psi_dot_dot ;

PhiIntegrand = zeros(N,N,NT) ; Phi = zeros(N,N) ;
r = zeros(N,1) ;
for m = 1:N
    for n = 1:N
        for i = 1:NT
            PhiIntegrand(m,n,i) = psi_dot_dot(m,i) * psi_dot_dot(n,i) ;
        end
        for i = 1:NT-1
            Phi(m,n) = Phi(m,n) + 1 / 2 * dt * (PhiIntegrand(m,n,i+1) + PhiIntegrand(m,n,i)) ;
        end
    end
    
    for i = 1:NT-1
        r(m) = r(m) + 1 / 2 * dt * (A(i+1) * psi_dot_dot(m,i+1) + A(i) * psi_dot_dot(m,i)) ;
    end
end
iter = floor(N / 10) * 10 ;
a = gmres(Phi,r,iter,[],iter) ;

V = zeros(1,NT) ; D = zeros(1,NT) ; % A = zeros (1,NT) ;
for i = 1:NT
    for n = 1:N
        V(i) = V(i) + a(n) * psi_dot(n,i) ;
        D(i) = D(i) + a(n) * psi(n,i) ;
        % A(i) = A(i) + a(n) * psi_dot_dot(n,i) ;
    end
end

figure(1), hold on, for i = 1:N, plot(t,psi(i,:)), end
figure(2), hold on, for i = 1:N, plot(t,psi_dot(i,:)), end
figure(3), hold on, for i = 1:N, plot(t,psi_dot_dot(i,:)), end

%// Remove zero-padding at both ends of the time domain
num = 1 ;
while num <= numPads
    A = A(2:NT-1) ; V = V(2:NT-1) ; D = D(2:NT-1) ; t = t(2:NT-1) - dt ; 
    T = T - 2 * dt ; NT = length(t) ;
    num = num + 1 ;
end

figure(4)
plot(t,A)
figure(5)
plot(t,V)
figure(6)
plot(t,D)