%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The Type-oriented Algorithm for Baseline Correction %%%
%%%                By: Christopher Wong                 %%%
%%%                crswong888@gmail.com                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% This script runs all '.m' scripts in the current directory with a corresponding '.mat' file in
%%% a 'gold/' subdirectory and compares the results. The "gold" files serve as an archive of
%%% certified results (regression tests) for a given demo input file. This is useful for ensuring
%%% computational quality on new machines or after refactoring the source code.
%%% 
%%% For problems which are highly sensitive to perturbations, different machines can easily produce
%%% slightly different results. In these cases, the 'gold/alt/' directory can be used as a backup or
%%% "alternative" archive of certified results. If the workspace produced by a test does not match
%%% the corresponding "gold" file, then it will check the "alt" file as a last resort, if it exists.

clear all %#ok<CLALL>
close all
fprintf('\n')


%// set a small numeric tolerance to use when comparing applicable test variables to gold
TOL = 1e-12;
arrayTOL = min(0.5, (log10(TOL) + 16) / 26); % portion of a given array's elements allowed to fail

%// switch off figure visibility at root graphics object (it will be turned back on after)
%// 
%// NOTE: This won't work if the 'Visible' property is set for an individual figure object
set(groot, 'DefaultFigureVisible', 'off')

%// get all '.mat' filenames in 'gold' directory
gold = {dir('gold/*.mat').name};
maxchars = max(cellfun(@ length, gold)) - 4; % used for text ouput alignment (-4 cuz '.mat')

%/ also get those in 'gold/alt' (this is just an empty cell if no alternatives exist)
alt = {dir('gold/alt/*.mat').name};

%// issue prompt indicating that test procedure has initalized along with notation for test results
fprintf('Testing scripts against "gold" files (''OK'' = passed, ''NG'' = failed)\n')
fprintf('-------------------------------------------------------------------\n')

%// loop over and run demo input files that have a matching gold workspace file
tic % initiate test timer
for test = string(gold)
    %/ get and report name of script currently being tested
    testname = erase(char(test), '.mat');
    fprintf('%s...', testname)
    
    %/ run script matching 'testname' in current directory to generate its workspace
    vars = runScript([testname, '.m']);
    
    %/ invoke diff helper on 'testname', if it fails by diff, try alternative gold if it exists
    status = checkDiff(vars, testname, 'gold', TOL, arrayTOL);
    if (startsWith(status, 'NG') && ~endsWith(status, '[ERROR]') && any(strcmp(test, alt)))
        status = checkDiff(vars, testname, 'gold/alt',  TOL, arrayTOL) + " [used alt.]";
    end
    
    %/ report current test results (prepending amount of dot characters to align result reports)
    fprintf('%s %s\n', repmat('.', [1, max(maxchars - length(testname), 0)]), status)
end

%// report completion of testing procedure and how long it took
fprintf('-------------------------------------------------------------------\n')
fprintf('Ran %d tests in %g seconds\n\n', length(gold), toc)

%// testing procedure is complete... switch figure visibility back on and remove temporary data
set(groot, 'DefaultFigureVisible', 'on')
delete temp.mat
clear all %#ok<CLALL>

%%% Helper function for regression testing - the 'temp.mat' and the "gold" workspace file must exist
function status = checkDiff(vars, testname, testdir, TOL, arrayTOL)
    %// initialize status indicator with a successful test assumption
    status = 'OK';
    
    %// compare 'temp.mat' variables against those stored in 'testdir/testname.mat'
    if (~all(strcmp(vars, 'ERROR')))
        for var = vars
            %/ load variables from test and gold workspaces into cells
            res = cellfun(@(x) struct2cell(x),...
                          {load('temp.mat', var), load([testdir, '/', testname, '.mat'], var)});
            
            %/ round numeric types to nearest 'TOL' to allow for minor discrepancies
            numvar = isnumeric(res{1});
            if (numvar)
                res = cellfun(@(x) round(x / TOL) * TOL, res, 'UniformOutput', false);
            end
            
            %/ compare results - if different, set status indicating failure and report current
            %/ varname, also, as a last resort, check if number of diffed array entries is tolerable
            if ((numvar && numel(setdiff(res{:})) / numel(res{:}) >= arrayTOL) || ~isequal(res{:}))
                status = "NG ('" + var + "')";
                break
            end
        end
    else
        %/ if runScript() function returned 'ERROR', this means it failed to execute, which is
        %/ different from a regression failure (i.e., when code runs fine but not as expected)
        status = 'NG [ERROR]';
    end
end

%%% Helper function for invoking a script in a separate workspace and saving it to a temporary file
function vars = runScript(filename_) %#ok<INUSD>
    %// try to invoke script 'filename_' and save its workspace to a temporary file 'temp.mat'
    try
        clearout_ = evalc('run(filename_)'); %#ok<NASGU>
        clear clearout_ filename_ % these shouldn't show up in temp workspace
        save('temp')
        
        %/ compile list of variables subject to comparison, i.e., anything but anonymous functions
        vars = transpose(string(who)); % format as row vector so it can be easily enumerated
        vars(arrayfun(@(v) isa(evalin('caller', v), 'function_handle'), vars)) = [];
    catch
        %/ if errors occured, return with an unambigous indicator of execution failure
        vars = 'ERROR';
    end
    
    %// close any lingering figure windows
    close all
end