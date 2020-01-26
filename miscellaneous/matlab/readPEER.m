function [time_series, dt, npts, rsn] = readPEER(varargin)
%% This program is used to read ground motion data from PEER database

%% Written by

%% GOPI

%% Input

% varargin(1) - filefolder - where peer ground motion data file is located 
% varargin(1) - filefolder- example - 'D:/Thesis/extra' (with quotes)

% varargin(2) - file_name - name of the file along with the extension
% varargin(2) - file_name - example - 'RSN982_NORTHR_JEN022.AT2' (with quotes)

%% Example input
% [time_series, dt, npts] = readPEER('C:\Users\IIT\Google Drive\Thesis\Northridge', 'RSN982_NORTHR_JEN022');

%% Output

% time_series - vector of any quantity 
% time_series - (be it acceleration or velocity or displacement)
% ACCELERATION TIME SERIES IN UNITS OF g (9.81)
% VELOCITY TIME SERIES IN UNITS OF cm/sec
% DISPLACEMENT TIME SERIES IN UNITS OF cm

% dt - sampling time in seconds
% npts - no of sampling point in the time_series (length of time_series)

%% Program starts from here

if isempty(varargin) == 1
    
    [file_name, filefolder] = uigetfile({'*', 'File Selector'});
    
else
    
    filefolder = varargin{1};
    file_name = varargin{2};
    
end

fid = fopen([filefolder '/' file_name], 'r');
datacell = textscan(fid, '%f', 'Delimiter', ',', ...
    'Headerlines', 4, 'CollectOutput', 0) ;
fclose(fid);
time_series = datacell{1};

fid = fopen([filefolder '/' file_name], 'r');
string_data = textscan(fid, '%s', 'Delimiter', '\n');
fclose(fid);

time_data = string_data{1};
numbers = sscanf(char(time_data(4)), 'NPTS=   %f, DT=   %f SEC');
dt = numbers(2);
npts = numbers(1);
rsn = sscanf(char(file_name), 'RSN %f _');

end

