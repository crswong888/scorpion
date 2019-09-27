clear all

%%% This just tests one case, although probably the most common case

nuetral_axis = [0, 0, 0] ;
transverse_axis = [0, 1, 0] ;

r_0 = [0, -1, 0] ;

r_0_mag = sqrt(r_0(1)^2 + r_0(2)^2 + r_0(3)^2) ;

disp_x = 0.25 ;

x = disp_x ;

if r_0(2) <= nuetral_axis(2)
    y = -sqrt(r_0_mag^2 - disp_x^2) ;
end

r_def = 1 / sqrt(x^2 + y^2) * [x, y, 0] ;

r_def_mag = sqrt(r_def(1)^2 + r_def(2)^2 + r_def(3)^2) ; % r_def_mag = r_0_mag true

disp_y = y - r_0(2) ; % this works at least for the case where x>0 and r_0(2)<0

disp = [disp_x, disp_y, 0] ;

t_trial = atan(disp(1) / (r_0(2) + disp_y)) ;

isEqual = cos(t_trial) == - (r_0(2) + disp_y) / r_0_mag ; % this assumption is correct

isResidual = (r_0 + disp) * transpose(r_0) + r_0_mag^2 * (r_0 + disp) / r_0_mag * transpose(transverse_axis) == 0 ; %% this statement is correct



