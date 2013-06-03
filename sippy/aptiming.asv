function [numaps1 numaps2 numaps3] = aptiming(dataVm);

% this function will divide the plateau of the UP state into 3 epochs and
% count the number of action potentials in each of them

upstates = findupstates(dataVm(1:100000)); %indices of UPstate in data file
if ~ isempty(upstates);
    if upstates (1,1) < 35000; % if the first UP state happens before the stim
        upstates (1,:) = []; % throw it away
    end
    if size(upstates, 1) > 1; % if there is more than 1 UP state found, throw them away; will go back and fix this
        for u = 1:size(upstates, 1) - 1;
            upstates(u+1,:) = [];
        end
    end
    remain=rem(length(dataVm(upstates(2):upstates(3))), 3);
    if remain > 0; % if the number of data points during the plateau is not divisible by 3
        epochlength = (length(dataVm(upstates(2):upstates(3)))+ 3 - remain)/3; % add on the remainder to make it divisible by 3
    else epochlength = length(dataVm(upstates(2):upstates(3)))/3;
    end
    epoch1start = upstates(2);
    epoch1end = upstates(2)+ epochlength;
    epoch2start = epoch1end + 1;
    epoch2end = epoch2start + epochlength;
    epoch3start = epoch2end + 1;
    epoch3end = epoch3start + epochlength;
    aps1 = findaps2(dataVm(epoch1start:epoch1end));
    aps2 = findaps2(dataVm(epoch2start:epoch2end));
    aps3 = findaps2(dataVm(epoch3start:epoch3end));
    numaps1 = length(aps1);
    numaps2 = length(aps2);
    numaps3 = length(aps3);
    apsepoch = cat(1, numaps1, numaps2, numaps3)
end
end

    
    
    


    