function [onsets, offsets, param] = ...
    ct_find_upstates(rastermap, handles, ridxs, clustered_contour_ids, options);


timesnoise = 2;%arbitrary number
minduration = .5;%minimum duration of an event, in seconds
minduration = minduration * handles.app.experiment.fs;%now min duration in # of frames

%%detect overall noise level for the movie using the entire duration of all
%%traces
pidx = handles.app.data.currentPartitionIdx;
wholetraces = handles.app.experiment.partitions(pidx).cleanContourTraces;
noise = wholetraces(wholetraces<0);
noise = [noise;-noise];
noise = std(noise);
noise = timesnoise*noise;

%% find actual activity

for a = 1:size(rastermap,1);
    aboveperiods = continuousabove(rastermap(a,:),zeros(1,size(rastermap,2)),noise,minduration,Inf);

    if ~isempty(aboveperiods)
        onsets{a} = aboveperiods(:,1);
        offsets{a} = aboveperiods(:,2);
    else
        onsets{a} = [];
        offsets{a} = [];
    end
end
param = [];




function aboveperiods = continuousabove(data,baseline,abovethresh,mintime,maxtime);
% Finds periods in a linear trace that are above some baseline by some
% minimum amount (abovethresh) for between some minimum amount of time
% (mintime) and some maximum amount of time (maxtime).  Output is the
% indices of start and stop of those periods in data.
above = find(data>=baseline+abovethresh);

% If only 1 potential event found
if (max(diff(diff(above))) == 0 & ...
    length(above) >= mintime & ...
    length(above) <= maxtime)
    aboveperiods = [above(1) above(end)];
% if many possible event
elseif (length(above) > 0)
    % find breaks between potential events
    ends = find(diff(above)~=1);
    % for the purposes of creating lengths of each potential event
    ends(end+1) = 0;
    % one of the ends comes at the last found point above baseline
    ends(end+1) = length(above);
    ends = sort(ends);
    % length of each potential event
    lengths = diff(ends);
    % must be longer than 500ms but shorter than 15sec
    good = find(lengths >= mintime & lengths <= maxtime);
    ends(1) = [];%lose the 0 added before
    e3 = reshape(above(ends(good)),[length(good) 1]);
    l3 = reshape(lengths(good)-1,[length(good) 1]);
    % event ends according to the averaged reading
    aboveperiods(:,2) = e3;
    % event beginnings according to averaged reading
    aboveperiods(:,1) = e3-l3;
else
    aboveperiods = [];
end
