function allsignals = findsignals(binarydata);

% this function will divide a binary signal matrix exported from CALTRACER
% in which the rows are contour numbers and the columns correspond to the
% frames

contour_lastframe = [];
exptime = .100;  %exposure time in s

% first create cell array in which the first column is contour number,
% second column is indices in which the contour is active
for k = 1: size(binarydata, 1); % for the number of contours present
    signals(k,1) = {k};
    signals_cells = find(binarydata(k,:));
    if ~isempty(signals_cells)
        signals(k,2) = {signals_cells};
    else
        signals(k,2) = {[]};
    end
    if ~isempty(signals{k,2})
        if max(diff(diff(signals{k,2}))) == 0; % if only one signal detected
            signals(k,3) = {max(signals{k,2})}; % index of frame where signal is the greatest
        else
            a = find(diff(signals{k,2})~= 1);
            lastframes = signals{k,2}(a);
            lastframes(end+1) = max(signals{k,2}); % one signal will be the last frame
            signals(k,3) = {lastframes};
        end
    end
    if isempty(signals{k,2})
        signals(k,3) = {[]};
    end
    if isempty(signals{k,3})
        ends(k) = [NaN];
    else ends(k)= max(signals{k,3});
    end
end

firstframe = min(ends);
lastframe = max(ends);
length_UPstate = (lastframe - firstframe)*exptime
signals{1,5} = length_UPstate;
remain = rem((lastframe - firstframe), 3);
epochlength = ((lastframe - firstframe) + 3 - remain)/3; % divide movie into 3 epochs
epoch1start = min(ends); %beginning of first epoch is always the first frame
epoch3end = max(ends); % end of last epoch is always the last frame

if remain == 0;
    epoch1end = epoch1start + (epochlength -1);
    epoch2start = epoch1start + epochlength;
    epoch2end = epoch2start + (epochlength -1);
    epoch3start = epoch2start + epochlength
end
if remain == 1;
    epoch1end = epoch1start + epochlength - 2;
    epoch2start = epoch1end + 1;
    epoch2end = epoch2start + epochlength - 1;
    epoch3start = epoch2end + 1;
end
if remain == 2;
    epoch1end = epoch1start + epochlength - 1;
    epoch2start = epoch1end + 1;
    epoch2end = epoch2start + epochlength - 2;
    epoch3start = epoch2end + 1;
end



for i = 1:size(signals,1);
    for j = 1:length(signals{i,3})
        if signals{i,3}(j) >= epoch1start &  signals{i,3}(j) <= epoch1end;
            signals{i,4}(j) = {1};
        end
        if signals{i,3}(j) >= epoch2start & signals{i,3}(j) <= epoch2end;
            signals{i,4}(j) = {2};
        end
        if signals{i,3}(j) >= epoch3start & signals{i,3}(j) <= epoch3end;
            signals{i,4}(j) = {3};
        end
    end
    
end
allsignals = signals
end







