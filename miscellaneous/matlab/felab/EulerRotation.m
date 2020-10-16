clear all %#ok<CLALL>
format longeng
fprintf('\n')

%%% INPUT PARAMETERS
%%% ------------------------------------------------------------------------------------------------

%// input original vector [x; y; z]
a = [-4 / sqrt(2); 0; 0];

%// specify euler angles (radians) and translation (use right-hand rule)
theta = 0; % rotation about x
phi = pi / 4; % rotation about y
psi = pi / 4; % rotation about z
T = [0; 0; 0]; % translation through [x; y; z]

%%% need some way to specify order - cuz it supposedly matters. Matrix multiplication goes from 
%%% right to left in that order. Shouldn't be so difficult to figure this out...

%%% writing a symbolic version of this script would actually be more helpful


%%% SOURCE COMPUTATIONS
%%% ------------------------------------------------------------------------------------------------

rotx = [1,          0,           0, 0; 
        0, cos(theta), -sin(theta), 0; 
        0, sin(theta),  cos(theta), 0; 
        0,          0,           0, 1];

roty = [ cos(phi), 0, sin(phi), 0; 
                0, 1,        0, 0; 
        -sin(phi), 0, cos(phi), 0; 
                0, 0,        0, 1];

rotz = [cos(psi), -sin(psi), 0, 0; 
        sin(psi),  cos(psi), 0, 0; 
               0,         0, 1, 0; 
               0,         0, 0, 1];
           
trans = eye(4);
trans(1:3,4) = T;

b = trans * rotx * roty * rotz * [a; 1];
b = b(1:3);