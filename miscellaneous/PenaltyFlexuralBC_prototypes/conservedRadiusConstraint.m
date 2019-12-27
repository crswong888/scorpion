clear all
format longeng

% input trial scenario
r = [ 0 ; -5 ; 0 ] ;
u = [ 0 ; 0 ; 0 ] ;

% initialize arrays to store both trivial and nontrivial solutions for the disp components {x,y,z}
uxyz = zeros(3,2) ; residual = zeros(3,2) ;

% compute solutions for the displacement components
for i = 1:3
    rhs = 0 ;
    for j = 1:3
        if j ~= i
            rhs = rhs + 2 * r(j) * u(j) + u(j)^2 ;
        end
    end
    
    uxyz(i,1) = -r(i) + sqrt(r(i)^2 - rhs) ;
    uxyz(i,2) = -r(i) - sqrt(r(i)^2 - rhs) ;
    
    residual(i,1) = u(i) - uxyz(i,1) ;
    residual(i,2) = u(i) - uxyz(i,2) ;
end