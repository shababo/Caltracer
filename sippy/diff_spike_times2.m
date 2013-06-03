
workspace=who;

c=0;

dd = 0;

for i=1:length(workspace)
    c = c+1;

    channels=fieldnames(eval(workspace{i}));
    channels(end) = [];

    cell1 = eval([workspace{i} '.' channels{1}]);
    cell2 = eval([workspace{i} '.' channels{2}]);
    cell1 = cell1(30000:99999);
    cell2 = cell2(30000:99999);
    spt1 = get_spike_timesTS(cell1);
    spt2 = get_spike_timesTS(cell2);
    cc = 0;
    if length(spt1) <= length(spt2)
        spt_short = spt1;
        spt_long = spt2;
    else
        spt_short = spt2;
        spt_long = spt1;
    end
    for n = 1:length(spt_short)
        for m = 1:length(spt_long)
            cc = cc+1;
            diffs(cc) = abs(spt_long(m) - spt_short(n))/10; %time between spikes in ms
            diff_spikes{c} = diffs;
        end
        dd = dd + 1;
        diffs_min(dd) = min(diffs);
        cc = 0;
        diffs = [];
    end   
end

