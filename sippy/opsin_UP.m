workspace=who;

%data will be in workspace from packephys (export visible data)

%indices of workspace which correspond to each condition should be set
%here:
no_shutter = [1 2 3 4];
shutter = [5 6 7 8 9];

sample_rate = 10000;
ISI = 40; %interstimulus interval in Hz

base_time = 2; %time before trials in which there is a baseline
thresh_factor = 18;
number_trials = 1;


ISIs = (1/ISI)*sample_rate;


bt = base_time*sample_rate;

channels1 = fieldnames(eval(workspace{1}));
channels1(end) = [];
sample_data = eval([workspace{1} '.' channels1{1}]);
diff1 = diff(sample_data,1,1);
mean_diff = mean(diff1(1:bt,1));
sd_diff = std(diff1(1:bt,1));
diff_thresh = mean_diff + thresh_factor*sd_diff;
stim_art_index = find(abs(diff1) > diff_thresh);
diff2 = roundn(diff(stim_art_index),1);
diff2(end + 1) = diff2(end) + ISIs;
set = ISIs-50:1:ISIs+50;
is_stim = find(ismember(diff2,set));
number_stims = length(is_stim);
starts = is_stim;


for d=1:length(workspace)
    channels=fieldnames(eval(workspace{d}));
    channels(end) = [];
    data = eval([workspace{d} '.' channels{1}]);
    s = 1;
    for i = 1:number_trials
        indices{i} = zeros(number_stims,2);
        indices{i}(1:number_stims,1) = stim_art_index(starts(s:s + number_stims -1)) + 20;
        indices{i}(1:number_stims,2) = indices{i}(1:number_stims,1) + (ISIs -40);
        event_index = indices{i};
        bl = mean(data(event_index(1,1)- bt:event_index(1,1) - 100));
        data_trial{i,d} = data(event_index(1) - bt:event_index(1) + number_stims*ISIs + bt);        
        data = [];
    end
end


    
    
    data_no_shutter = cat(3,data_trial{:,no_shutter});
    data_shutter = cat(3,data_trial{:,shutter});
    
    avg_data_ns = mean(data_no_shutter,3);
    avg_data_s = mean(data_shutter,3);
    figure; plot(avg_data_ns - mean(avg_data_ns(1:bt-10))); hold on; plot(avg_data_s - mean(avg_data_s(1:bt-10)), 'r'); hold off;
    

