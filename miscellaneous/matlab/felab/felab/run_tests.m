%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FE Environment for Solid Mechanics %%%
%%%        By: Christopher Wong        %%%
%%%        crswong888@gmail.com        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% UNDER DEVELOPMENT: Currently, this simply runs all demo input files to ensure they run.
%%%
%%% TODO: This should run each demo and compare the results to an archive of verified results. This
%%% way, when developments to functions are made, or this program is ran on a new machine, it can be
%%% ensured that everything solves properly.

clear all %#ok<CLALL>
format longeng
fprintf('\n')

%// get all '.m' file info in current directory
tests = dir('*.m');
tests = tests(~ismember({tests.name}, 'run_tests.m')); % exclude 'run_tests.m' itself

%// loop over and run demo input files to ensure they complete succesfully
for t = 1:length(tests)
    %/ script must run from within function so that its workspace is unique
    runDemoScript(tests(t).name)
end

%// function for invoking demo scripts in a separate workspace
function [] = runDemoScript(filename)
    %/ invoke script
    run(filename)
    
    %/ create a temporary workspace file for comparison to gold
    save('temp.mat')
    
    %/ close any plots generated and delete temp file
    close all
    delete temp.mat
end
