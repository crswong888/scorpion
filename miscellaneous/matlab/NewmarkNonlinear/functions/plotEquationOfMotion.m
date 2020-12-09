%%% Generates plots of a particular solution to the ordinary differential equation of motion of a 
%%% damped mass-spring system.
%%%
%%% By: Christopher Wong | crswong888@gmail.com

function [] = plotEquationOfMotion(t, d2u, du, u, fs_history, p, units)    
    %// 'reset(groot)' breaks 'DefaultFigurePosition', so store current default and manually reset
    defaultFP = get(groot, 'DefaultFigurePosition');
    
    %// set default root graphics properties to generate plots with uniform formatting
    set(groot, 'DefaultAxesColorOrder', [0, 0, 0], 'DefaultLineLineWidth', 1.25,...
        'DefaultTextFontName', 'Times New Roman', 'DefaultTextFontSize', 10,...
        'DefaultTextInterpreter', 'Latex', 'DefaultFigurePosition', [680, 678, 700, 420])
    
    %// plot forcing function
    figure()
    fplot(p, [t(1), t(end)], 'LineWidth', 1.25)
    hold on
    title('\bf{Forcing Function Time History}')
    xlabel(['Time (', units{1}, '), $t$'])
    ylabel(['External Force (', units{3}, '), $p$'])
    grid on
    grid minor

    %// plot hysteresis loop
    figure()
    plot(u, fs_history)
    hold on
    title('\bf{Restoring (Spring) Force Hysteresis Loop}')
    xlabel(['Displacement (', units{2}, '), $u$'])
    ylabel(['Restoring Force (', units{3}, '), $f_{s}$'])
    grid on
    grid minor

    %// plot acceleration time history
    figure()
    plot(t, d2u)
    hold on
    title('\bf{Acceleration Time History}')
    xlabel(['Time (', units{1}, '), $t$'])
    ylabel(['Acceleration (', units{2}, '/', units{1}, '\textsuperscript{2}), $\ddot{u}$'])
    grid on
    grid minor

    %// plot velocity time history
    figure()
    plot(t, du)
    hold on
    title('\bf{Velocity Time History}')
    xlabel(['Time (', units{1}, '), $t$'])
    ylabel(['Velocity (', units{2}, '/', units{1}, '), $\dot{u}$'])
    grid on
    grid minor

    %// plot displacement time history
    figure()
    plot(t, u)
    hold on
    title('\bf{Displacement Time History}')
    xlabel(['Time (', units{1}, '), $t$'])
    ylabel(['Displacement (', units{2}, '), $u$'])
    grid on
    grid minor
    
    %// reset root graphics properties
    reset(groot)
    set(groot, 'DefaultFigurePosition', defaultFP);
end