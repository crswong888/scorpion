clear all

r = [0, -2, -0.25] ; u = [0.2, 0.1, 0] ;

r_def = r + u ;

% this not true, a cross product could never magically become a scalar
isEqual = cross(r,r) + cross(r,u) == u(3) * (r(2) + r(1)) ...
                                     + u(2) * (r(1) - r(3)) ...
                                     - u(1) * (r(3) + r(2)) ;
                                 
% however ...
isEqual2 = cross(r,r) == zeros([1 3]) ;

% this is true, since the r and r are parallel, so their cross-product must
% be zero

% therefore, this must also be true
isEqual3 = cross(r,u) == cross(r,r) + cross(r,u) ;

r_cross_u = [ r(2) * u(3) - r(3) * u(2) ;
              r(1) * u(3) + r(3) * u(1) ;
              r(1) * u(2) - r(2) * u(1) ] ;

isEqual4 = cross(r,u) == transpose(r_cross_u) ;

A = [ 1 2 3 ; 4 5 6 ; 7 8 9 ] ; b = [1 ; 2 ; 3] ;
isEqual5 = A * b - b == (A - eye(3)) * b; % yup this is true
                                        