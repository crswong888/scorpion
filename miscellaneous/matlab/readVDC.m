function [time_history, npts, dt] = readVDC(path, fname)

    fid = fopen([path '/' fname], 'r');
    time_history = textscan(fid, '%f', 'Headerlines', 51);
    time_history = time_history{1};
    fclose(fid);

    fid = fopen(['./ChiChi/Uncorrected' '/' fname], 'r');
    token = textscan(fid, '%s', 'Delimiter', '\n');
    fclose(fid);

    time_data = sscanf(char(token{1}(51)), '%f  acceleration pts a  %f pts/sec');
    npts = time_data(1);
    dt = 1 / time_data(2);

end