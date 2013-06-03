function [onsets, offsets, param] = ...
    ct_ogb(rastermap, handles, ridxs, clustered_contour_ids, options)
% NB -DCS:2005/08/04
% Because the data matrix DOES NOT reflect all of the contours, the
% programmer MUST used clustered_contour_ids to index ANYTHING experiment
% Specific to detecting signals with oregon green-bapta. 
% This is an example of a signal detection routine that uses it's
% own preprocessing.  In other words, it does everything that the
% preprocessing setup is made to do.  Just be sure to set
% options.preprocessStrings = {} and you will get the raw data.;
num_contours = size(rastermap, 1);
param = [];
framelength = options.timeRes.value;
framerate = 1/framelength;%
waithandle = waitbar(0,'Detecting signals');
for a = 1:num_contours
    %signal = handles.exp.contours(a).intensity;
    signal = rastermap(a,:);    
    % less than one third the length of the signal
    filtorder = min([50,round(length(signal)/3)-1]);
    % make a 300 frame long filter
    filtlength = framerate*10;
    %corresponding to 60 seconds of time
    lowpass = fir1(filtorder,2/filtlength);
    %lowpass filter to find the trend in the data
    trendA = filtfilt(lowpass,sum(lowpass),signal);
    %divide each point by the local baseline
    signalA = signal./trendA;
    tempthresh = mean(signalA)+1.5*std(signalA);
    highpoints = find(signalA>tempthresh);
    signalB = signal;
    signalB(highpoints) = trendA(highpoints);
    %lowpass filter to find the trend in the data
    trendB = filtfilt(lowpass,sum(lowpass),signalB);
    %divide each point by the local baseline
    signalC = signal./trendB;
    noise = std(signalC(find(signalC<1)));
    thresh = max([1.005 1+5*noise]);
    % Find all areas of the trace that are at least 1 point long that
    % are at least "thesh" in amplitude.
    aboveperiods = continuousabove(signalC,zeros(size(signalC)),thresh,1,Inf);
    if ~isempty(aboveperiods)
        onsets{a} = aboveperiods(:,1);
        offsets{a} = aboveperiods(:,2);
    else
        onsets{a} = [];
        offsets{a} = [];
    end
    waitbar(a/num_contours, waithandle);
end
delete(waithandle);
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