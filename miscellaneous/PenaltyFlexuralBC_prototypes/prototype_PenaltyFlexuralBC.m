clear all

axis_origin = [0 0 0] ; % this should equal the boundary coordinates somehow
axis_direction = [0 0 1] ; % this should be perpindicular to the boundary normal

components = [1 1 0] ; % this could be some type of boolean.

node = [0 1.5 0] ; % arbitrary node @ [0 -1 0]

disp_x = -0.05 ; % hypothetical scenario

for i=1:3
    y_bar(i) = axis_origin(i) + node(i) ;
    
    if y_bar(i) ~= 0
        disp_y = (y_bar(i)^2 - disp_x^2)^(1/2) ;
    end
end

