%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Newmark-beta Method for Nonlinear SDOF Systems %%%
%%%              By: Christopher Wong              %%%
%%%              crswong888@gmail.com              %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% This script runs all '.m' scripts in the current directory with a corresponding '.mat' file in
%%% a 'gold/' subdirectory and compares the results. The "gold" files serve as an archive of
%%% verified results (regression tests) for a given demo input file. This is useful for ensuring
%%% that everything solves as expected on new machines or after changes to the source code are made.
%%%
%%% TODO: these tests ought to tolerate small numerical discrepancies when comparing workspaces

clear all %#ok<CLALL>
fprintf('\n')


%// report notation for test results
fprintf('Testing scripts against "gold" files (''OK'' = passed, ''NG'' = failed)\n')
fprintf('--------------------------------------------------------------------------\n')

%// get all '.mat' filenames in gold directory
gold = dir('gold/*.mat');

%// loop over and run demo input files that have a matching gold workspace file
tic % initiate test timer
for test = 1:length(gold)
    %/ report name of demo script currently being tested
    currdemo = erase(gold(test).name, '.mat');
    fprintf('%s... ', currdemo)
    
    %/ script must run from within function so that its workspace is unique
    check_vars = runDemoScript([currdemo, '.m']);
    
    %/ compare temp file variables against those in corresponding gold archive and print results
    status = 'OK'; % initialze a succesful test assumption
    for var = 1:length(check_vars)
        stringvar = check_vars{var};
        if (~isequal(load('temp.mat', stringvar), load(['gold/', gold(test).name], stringvar)))
            status = 'NG'; % test no good
            break
        end
    end
    
    %/ delete temp file and report test results
    delete temp.mat
    fprintf([status, '\n'])
end

%// report completion of testing procedure and how long it took
fprintf('--------------------------------------------------------------------------\n')
fprintf('Ran %d tests in %g seconds\n\n', length(gold), toc)

%// function for invoking demo scripts in a separate workspace and saving results to a temp file
function check_vars = runDemoScript(filename) %#ok<INUSD>
    %/ invoke script and save a temporary workspace file for comparison to gold
    clearout = evalc('run(filename)'); %#ok<NASGU>
    clear clearout
    save('temp')
    
    %/ compile list of variables subject to comparison
    check_vars = who;
    ignore_vars = []; % compile idices here
    for var = 1:length(check_vars)
        % ignore function handles
        if (isa(eval(check_vars{var}), 'function_handle'))
            ignore_vars = cat(1, ignore_vars, var);
        end
    end
    check_vars(ignore_vars) = []; % clear variables at ignored indices
    
    %/ close any plots generated
    close all
end