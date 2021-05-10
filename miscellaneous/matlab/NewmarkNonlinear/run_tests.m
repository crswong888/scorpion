%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Newmark-beta Method for Nonlinear SDOF Systems %%%
%%%              By: Christopher Wong              %%%
%%%              crswong888@gmail.com              %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% This script runs all '.m' scripts in the current directory with a corresponding '.mat' file in
%%% a 'gold/' subdirectory and compares the results. The "gold" files serve as an archive of
%%% verified results (regression tests) for a given demo input file. This is useful for ensuring
%%% that everything solves as expected on new machines or after refactoring the source code.

clear all %#ok<CLALL>
close all
fprintf('\n')


%// report notation for test results
fprintf('Testing scripts against "gold" files (''OK'' = passed, ''NG'' = failed)\n')
fprintf('--------------------------------------------------------------------------\n')

%// get all '.mat' filenames in gold directory
gold = dir('gold/*.mat');

%// set a small numeric tolerance to use when comparing applicable test variables to gold
TOL = 1e-12;
arrayTOL = min(0.5, (log10(TOL) + 16) / 26); % portion of a given array's elements allowed to fail

%// loop over and run demo input files that have a matching gold workspace file
tic % initiate test timer
for test = 1:length(gold)
    %/ report name of script currently being tested
    testname = erase(gold(test).name, '.mat');
    fprintf('%s... ', testname)
    
    %/ script must run from within function so that its workspace is unique
    check_vars = runDemoScript([testname, '.m']);
    
    %/ compare temp file variables against those in corresponding gold archive and print results
    status = 'OK'; % initialize status indicator with a successful test assumption
    for var = 1:length(check_vars)
        % load variables from test and gold workspaces into cells
        varname = check_vars{var};
        results = {load('temp.mat', varname), load(['gold/', gold(test).name], varname)};
        results = cellfun(@(x) struct2cell(x), results);
        
        % round numeric types to nearest 'TOL' - only very minor discrepancies should be tolerated
        numvar = isnumeric(results{1}); 
        if (numvar)
            results = cellfun(@(x) round(x / TOL) * TOL, results, 'UniformOutput', false);
        end
        
        % compare results - if different, set status indicating failure and report current varname,
        % also, as a last resort, check if number of diffed array entries is tolerable
        if ((numvar && numel(setdiff(results{:})) / numel(results{:}) >= arrayTOL)...
            || ~isequal(results{:}))
            status = ['NG (''', varname, ''')'];
            break
        end
    end
    
    %/ report current test results
    fprintf([status, '\n'])
end

%// report completion of testing procedure and how long it took
fprintf('--------------------------------------------------------------------------\n')
fprintf('Ran %d tests in %g seconds\n\n', length(gold), toc)

%// testing procedure is complete... remove temporary data
delete temp.mat
clear all %#ok<CLALL>

%%% Helper function for invoking demo scripts in a separate workspace and writing it to a temp file
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