% Extract Single-Trial ERPs for R
% This script will extract data from specified channels and bins into
% 2D .csv files that can be loaded into R.
% In order to be as flexible as possible, this script extracts entire
% epochs which can be sub-epoched/windowed means'd in R or Python, w/e.
%
% Created...: ollie-d [20Apr23]
% Modified..: ollie-d [20Apr23]

%--------------------------------------------------------------------------
% Variable Declaration
%--------------------------------------------------------------------------

% First let's define the bins we're interested in
bins_of_interest = [7, 8, 9, 10];

% And our channels of interest
channels_of_interest = {'Fz', 'Cz', 'Pz'};

% Let's also decide where to save our .csv and what to call it
% (in reality this should contain info about task, ID, chans etc.)
DIR_OUT = './'; % save where current folder is
fname = 'single_trials.csv';

%--------------------------------------------------------------------------
% Main data extraction
%--------------------------------------------------------------------------
% This dataset is kinda weird because events are in multiple bins.
% Bin information is stored in EEG.event.bini and we need to check if a
% bin number is in bini rather than checking if bini == bin.

% Let's create a cell array to store our data in the following form:
% |      col1     |    col2   |    col3     |       coln    |
% | channel label | bin label | data at t=1 | data at t=end |
num_time_points = size(EEG.data, 2);
num_cols = num_time_points + 2;
num_rows = size(EEG.data, 3); % massively overshoot by using total events
df = cell(num_rows, num_cols);
df_counter = 1; % to keep track of adding data.

% Lets map channel labels to indices using a dictionary
values = 1:EEG.nbchan;
keys = {EEG.chanlocs.labels};
%chans = dictionary(keys, values); % requires MATLAB 2022a+
chans = containers.Map(keys, values);

% Let's make a nested loop that goes through bins, channels and epochs
for bin = bins_of_interest
    % Extact all of the bini values for checking
    binis = {EEG.event.bini};
    for chan = channels_of_interest
        %c = chans(chan); % (if you use dict) get channel index
        c = chans(chan{1}); % get channel index

        % Get epochs where bin is in bini
        for i = 1:size(binis, 2)
            % Check if bin belongs to this index of bini
            if ismember(bin, binis{i})
                % Let's extract our data
                data = num2cell(EEG.data(c, :, i));

                % Let's add our data to df
                df{df_counter, 1} = chan{1};
                df{df_counter, 2} = bin;
                [df{df_counter, 3:end}] = deal(data{:}); % MATLAB...

                % Finally let's increment our df_counter
                df_counter = df_counter + 1;
            end
        end
    end
end

% Export time! First, let's create useful column names
column_names = ["channel_label", "bin_label"];
for t = EEG.times
    % We'll truncate to the ones place and add an n for negative
    n = fix(t);
    if n < 0
        ns = num2str(abs(n));
        column_names = [column_names strcat("n", ns)];
    else
        ns = num2str(n);
        column_names = [column_names ns];
    end
end

% Now let's export after converting our df into a table
T = cell2table(df, 'VariableNames', column_names);
writetable(T, [DIR_OUT fname])

