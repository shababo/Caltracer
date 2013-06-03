workspace=who;

 

%% correlations within trials

 

s=1;



for i=1:length(workspace)

    channels=fieldnames(eval(workspace{i}));
    channels(end) = [];

    for j = 1:length(channels)
        cell = eval([workspace{i} '.' channels{j}]);
%         cell = detrend(cell); %filter out low frequency garbage
        cell = cell(41280:65000); %will correlate traces between 4s and 6s
        cell_detrend(j,:) = cell;
    end  
    for k = 1:size(cell_detrend,1) -1
        for m = k:size(cell_detrend,1) -1
        tempcorr= corrcoef(cell_detrend(k,:), cell_detrend(m+1,:));%correlating traces pairwise
        r(s) = tempcorr(1,2);
        aa{i}.r(s) = tempcorr(1,2); % r values for correlation
        s = s+1;
        end
    end 
    cell_detrend(j,:) = [];
end



       
% auto_corr = find(r >= .9995); %code is stupid, and runs correlations for some traces with themselves. 
%This leads to an r value equal to or very close to 1 which I eliminate.
% r(auto_corr) = [];
% r = unique(r); %code is stupid and runs some correlations twice, so I remove them
r2=r.^2; 
meanr2 = mean(r2);
varr2 = var(r2);