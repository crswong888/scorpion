clear all

%%% This just tests one case, although probably the most common case

neutral_axis = [0.75, 0, 0] ;
transverse_axis = [0, 1, 0] ;
quad_point = [0.75, -2, 5] ;

r_0 = quad_point - neutral_axis ;

r_0_mag = sqrt(r_0(1)^2 + r_0(2)^2 + r_0(3)^2) ;

disp_x = 0.25 ;

x = quad_point(1) + disp_x ;

if r_0(2) <= neutral_axis(2)
    y = -sqrt(r_0_mag^2 - disp_x^2) ;
else 
    y = sqrt(r_0_mag^2 - disp_x^2) ;
end

r_def = [x, y, 0] ;

r_def_mag = sqrt(r_def(1)^2 + r_def(2)^2 + r_def(3)^2) ; % r_def_mag = r_0_mag true

disp_y = y - r_0(2) ; % this works at least for the case where x>0 and r_0(2)<0

disp = [disp_x, disp_y, 0] ;

t_trial = atan(disp(1) / (r_0(2) + disp_y)) ;

if r_0(2) >= 0
    isEqual = cos(t_trial) == (r_0(2) + disp_y) / r_0_mag ;
    
    residual = (r_0 + disp) * transpose(r_0) - r_0_mag * (r_0 + disp) * transpose(transverse_axis) ;
    isResidual = residual == 0 ;
    
    isRewritten = (r_0 + disp) * transpose(r_0 - r_0_mag * transverse_axis) == residual ;
else
    isEqual = cos(t_trial) == - (r_0(2) + disp_y) / r_0_mag ;
    
    residual = (r_0 + disp) * transpose(r_0) + r_0_mag * (r_0 + disp) * transpose(transverse_axis) ;
    isResidual = residual == 0 ;
    
    isRewritten = (r_0 + disp) * transpose(r_0 + r_0_mag * transverse_axis) == residual ;
end