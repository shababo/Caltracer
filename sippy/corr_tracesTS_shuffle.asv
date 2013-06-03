workspace=who;

%this function will go through traces in workspaces exported from
%ephysviewer as structures, and correlate them. It divides the data into
%epochs, corralates the data in each epoch, then shuffles the epochs and
%recorrelates. 

%only suitable for 2 simulatneously patched cells. If have more than 2
%cells, must change the code to account for this case. 


% correlations within trials



s=1;

t=1;

mintime = 15000;
maxtime = 25000;
belowthresh = -15;
abovethresh = 20;
epochs = 5;
UP_start = 40000;
UP_end = 43000;

t = 1;

for i=1:length(workspace)
    channels=fieldnames(eval(workspace{i}));
    channels(end) = [];
    for j = 1:length(channels)
        cell = eval([workspace{i} '.' channels{j}]);
        stim_art= find(abs(diff(cell) > 25)); %find the stim artifacts
        not_stim1 = find(stim_art < 40000); %get rid of any sharp rise/fall that are not artifacts
        not_stim2 = find(stim_art > 43000);
        not_stim = union(not_stim1, not_stim2);
        stim_art(not_stim) = [];
        
        a = [find(diff(stim_art) > 50)]'; %find breaks between artifacts
        a = [a, length(stim_art)]; %add back last artifact
        for b = 1:length(a);
            c(b,:) = (stim_art(a(b))-10: stim_art(a(b)) + 10); %use indices
        end
        cell(c) = [];
        basemean(i,j) = findbasemean(cell);
        belowperiods = continuousbelow(cell(41280:60000), basemean(i,j), belowthresh, mintime, maxtime);
        aboveperiods = continuousabove(cell(41280:60000), basemean(i,j), abovethresh, mintime, maxtime);
%         traces_detrended{i,j} = 'none';
%         if ~isempty(belowperiods)
%             cell = detrendTM(cell); %filter out low frequency garbage
%             traces_detrended{i,j} = [workspace{i} '.' channels{j}];
%         end
%         if ~isempty(aboveperiods)
%             cell = detrendTM(cell); %filter out low frequency garbage
%             traces_detrended{i,j} = [workspace{i} '.' channels{j}];
%         end        
        cell_noart_detrend(j,:) = cell(UP_start:UP_end);
        stim_art = [];
        belowperiods = [];
        aboveperiods = [];
    end
    epoch_length = floor(length(cell_noart_detrend)/epochs);
    for d = 1:size(cell_noart_detrend,1)
        start = 1;
        for dd = 1:epochs;
            cell_epochs{d,dd} = cell_noart_detrend(d, start:start + epoch_length-1);
            start = start + epoch_length;
        end
    end
    %correlation no shuffle
    for cc = 1:size(cell_epochs,2)
        for p = 1:size(cell_epochs,1) -1
            for q = p:size(cell_epochs,1) -1
                rsc_corr_temp = corrcoef(cell_epochs{p,cc}, cell_epochs{q+1,cc});
                rsc_corr(t,cc) = rsc_corr_temp(1,2);
            end
        end
    end
    %correlation shuffle
    for cc = 1:size(cell_epochs,2)
        for p = 1:size(cell_epochs,1) -1
            shuffle_index = randperm(epochs);
            c_shuffle = shuffle_index(cc);
            for q = p:size(cell_epochs,1) -1
                rsc_corr_temp = corrcoef(cell_epochs{p,c_shuffle}, cell_epochs{q+1,cc});
                rsc_corr_shuffle(t,cc) = rsc_corr_temp(1,2);
            end
        end
    end
    t = t + 1;
end




        





