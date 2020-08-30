clear all
format longeng
fprintf("\n")

%%% https://en.wikipedia.org/wiki/Rotation_matrix#Determining_the_axis

%// The global axes unit normals are defined by the following vectors
x = [1; 0; 0] ; y = [0; 1; 0]; z = [0; 0; 1];

%// say a beam's local axis vector (x') points from end a towards end b
enda = rand(3,1); endb = rand(3,1); % random locations for beam ends
while any(enda > endb); endb = rand(3,1); end % I wan't to ensure a positive vector here
xprime = endb - enda ; xprime = xprime / norm(xprime); % x' orientation

% just use yaw times y to get yprime, normalize it, then get zprime = cross(xprime, yprime)
% zprime needs to be normalize too (see rotations.m)
%
% sketch all the final normalized axes in autocad too just to be sure!

cos_alpha = xprime(1); sin_alpha = xprime(2);
yaw = [cos_alpha -sin_alpha 0; sin_alpha cos_alpha 0; 0 0 1];

yprime = yaw * y; yprime = yprime / norm(yprime);

zprime = cross(xprime, yprime); zprime = zprime / norm(zprime);

%// Verifications
normal_x = norm(xprime) == 1;
normal_y = norm(yprime) == 1;
normal_z = norm(zprime) == 1;

perpindicular_xy = transpose(xprime) * yprime == 0;
perpindicular_zx = transpose(zprime) * xprime == 0;
perpindicular_yz = transpose(yprime) * zprime == 0;




% %// Compute Euler angle coefficients using the right-hand rule
% %// For convenience, define and set them as the following variables:
% cos_alpha = xprime(1); sin_alpha = xprime(2); % alpha = rotation about z
% cos_beta = xprime(1); sin_beta = -xprime(3); % beta = rotation about y
% cos_gamma = xprime(2); sin_gamma = xprime(3); % gamma = rotation about x
% 
% %// Rotation matrices
% roll = [1 0 0; 0 cos_gamma -sin_gamma; 0 sin_gamma cos_gamma];
% pitch = [cos_beta 0 sin_beta; 0 1 0; -sin_beta 0 cos_beta];
% yaw = [cos_alpha -sin_alpha 0; sin_alpha cos_alpha 0; 0 0 1];

% // initialize the x' normal vector in each plane
% xprime_xy = zeros(3,1);
% xprime_zx = zeros(3,1);
% xprime_yz = zeros(3,1);
% 
% // Begin with xy-plane (to yaw):
% xprime_xy(1:2) = xprime(1:2) / norm(xprime(1:2));
% cos_alpha = xprime(1); sin_alpha = xprime(2); % alpha = rotation about z
% yaw = [cos_alpha -sin_alpha 0; sin_alpha cos_alpha 0; 0 0 1];

%%% https://math.stackexchange.com/questions/180418/calculate-rotation-matrix-to-align-vector-a-to-vector-b-in-3d/476311#476311
% v = cross(x, xprime);
% sin_theta = norm(v);
% cos_theta = transpose(x) * xprime;
% 
% v_skew = [0 -v(3) v(2); v(3) 0 -v(1); -v(2) v(1) 0];
% R = eye(3) + v_skew + v_skew^2 * (1 - cos_theta) / sin_theta^2;


