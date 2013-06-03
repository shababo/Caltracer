function data = ct_median_by_segment(data, options)

startstop = [options.startIdxs.value options.stopIdxs.value];
stops = cumsum(diff(startstop,1,2)+1);
starts = [1; stops(1:end-1)+1];

for idx = 1:size(stops,1);
    dataout(:,idx) = median(data(:,starts(idx):stops(idx)),2);
end

data=dataout;