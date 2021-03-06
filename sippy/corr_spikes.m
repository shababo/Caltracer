workspace=who;

t = 1;
bin_size = 10; %ms *10 
start_corr = floor(40000/bin_size);
end_corr = floor(70000/bin_size);
shift = 30000/bin_size;

for i=1:length(workspace)


    channels=fieldnames(eval(workspace{i}));
    channels(end) = [];

    cell1 = eval([workspace{i} '.' channels{1}]);
    cell2 = eval([workspace{i} '.' channels{2}]);
    spt1 = get_spike_timesTS(cell1); %extract spike times from each cell 
    spt2 = get_spike_timesTS(cell2);
    cell1 = zeros(length(cell1),1);
    cell2 = zeros(length(cell2),1);
    cell1(spt1) = 1;
    cell2(spt2) = 1;
    cols = floor(length(cell1)/bin_size); %number of columns that will be created for trace matrix
    rem1 = rem(length(cell1),bin_size);
    index = length(cell1) - rem1 + 1; 
    cell1(index:end) = []; %delete points at end of trace which are the remainder of trace/bin_size
    cell2(index:end) = [];
    cell1rs = reshape(cell1, bin_size, cols); %make a matrix in which each column is a tim bin and the # of rows correspond to # of data samples in that time bin
    cell2rs = reshape(cell2, bin_size, cols);
    cell1_bin_spikes = zeros(1,cols);
    cell2_bin_spikes = zeros(1,cols);
    for ii = 1:size(cell1rs,2)
        APs1_index = find(cell1rs(:,ii));
        APs2_index = find(cell2rs(:,ii));
        if ~isempty(APs1_index)
            APs1(ii) = length(APs1_index);
        else APs1(ii) = 0;
        end
        cell1_bin_spikes(ii) = APs1(ii);
        if ~isempty(APs2_index)
            APs2(ii) = length(APs2_index);
        else APs2(ii) = 0;
        end
        cell2_bin_spikes(ii) = APs2(ii);
        APs1_index = [];
        APs2_index = [];
    end
    sc = circshift(cell1_bin_spikes, [0 -shift]); %shift trace 1 by 3 seconds back
    rsc_temp = zeros(2*shift,1);
    for ss = 1:2*shift
        sc = circshift(sc, [0 1]); %shift trace forward by 1 time bin
        tempcorr_sc = corrcoef(cell2_bin_spikes(start_corr:end_corr), sc(start_corr:end_corr)); %correlate
        if ~isnan(tempcorr_sc(1,2))
        rsc_temp(ss) = tempcorr_sc(1,2);
        else rsc_temp(ss) = 0;
        end
        tempcorr_sc = [];
    end
    rsc(:,t) = rsc_temp; %add correlations to matrix rsc; each column is a correlation between a cell pair
    rsc_nolag(t) = rsc_temp(30000/bin_size);
    t = t+1;  
end

