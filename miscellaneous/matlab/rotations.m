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

%// Compute Euler angle coefficients using the right-hand rule
%// For convenience, define and set them as the following variables:
cos_alpha = xprime(1); sin_alpha = xprime(2); % alpha = rotation about z
cos_beta = xprime(3); sin_beta = xprime(1); % beta = rotation about y
cos_gamma = xprime(2); sin_gamma = xprime(3); % gamma = rotation about x

%// Translation matrices
trans_x = [1 0 0 xprime(1); 0 1 0 0; 0 0 1 0; 0 0 0 1];
trans_y = [1 0 0 0; 0 1 0 xprime(2); 0 0 1 0; 0 0 0 1];
trans_z = [1 0 0 0; 0 1 0 0; 0 0 1 xprime(3); 0 0 0 1];

%// Rotation matrices
roll = [1 0 0 0; 0 cos_gamma -sin_gamma 0; 0 sin_gamma cos_gamma 0; 0 0 0 1];
pitch = [cos_beta 0 sin_beta 0; 0 1 0 0; -sin_beta 0 cos_beta 0; 0 0 0 1];
yaw = [cos_alpha -sin_alpha 0 0; sin_alpha cos_alpha 0 0; 0 0 1 0; 0 0 0 1];

%// append 1 to vectors
x(end+1) = 1; y(end+1)=1; z(end+1)=1; xprime(end+1)=1;

%%% Other random computations

%// The transform from x to to x' can be accomplished by a translation through, as well as a 
%// rotation about, the z-axis. Verify that x' = trans_z * yaw * x
transform_x = trans_z * yaw;
verify_transform_x = all(xprime == transform_x * x);

%// interestingly, although, not helpful:
transform_y = trans_x * roll;
verify_transform_y = all(xprime == transform_y * y);

transform_z = trans_y * pitch;
verify_transform_z = all(xprime == transform_z * z);

%// this violates normal matrix multiplication rules, I guess thats why they call it "lie" algebra
interesting = all(trans_z * yaw == yaw * trans_z);

%// remove the extra component from the vectors
% x = x(1:3); y = y(1:3); z = z(1:3); xprime = xprime(1:3); %yprime = yprime(1:3);
% 
% %// get diff vector (for autocad sketching)
% xdiff = xprime - x;
% autocad = [84.8534; 104.0537; 0.0000] + xdiff;



