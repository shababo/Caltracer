workspace=who;

%data will be in workspace from packephys (export visible data)

%indices of workspace which correspond to each condition should be set
%here:
no_shutter = [1];
shutter = [2];


sample_rate = 10000;
ISI = 40; %interstimulus interval in Hz
ITI = 4; % intertrial interval--> seconds in between stimulation trials change according to experimental conditions
base_time = 1; %time before trials in which there is a baseline
thresh_factor = 20;

ITIs = ITI*sample_rate;

ISIs = (1/ISI)*sample_rate;


bt = base_time*sample_rate;

for d=1:length(workspace)
    channels=fieldnames(eval(workspace{d}));
    channels(end) = [];
    data = eval([workspace{d} '.' channels{1}]);
    diff1 = diff(data,1,1);
    mean_diff = mean(diff1(1:bt,1));
    sd_diff = std(diff1(1:bt,1));
    diff_thresh = mean_diff + thresh_factor*sd_diff;
    stim_art_index = find(abs(diff1) > diff_thresh);
    diff2 = roundn(diff(stim_art_index),1);
    number_trials = length(find(diff2 >= ITIs)) + 1;
    set = ISIs-10:1:ISIs+10;
    is_stim = find(ismember(diff2,set));
    number_stims = (length(is_stim) + number_trials)/number_trials;
    diff2(end + 1) = diff2(end) + ITIs;
    last_stim = find(diff2 >= ITIs);
    starts = union(is_stim, last_stim);
    s = 1;
    for i = 1:number_trials
        indices{i} = zeros(number_stims,2);
        indices{i}(1:number_stims,1) = stim_art_index(starts(s:s + number_stims -1)) + 20;
        indices{i}(1:number_stims,2) = indices{i}(1:number_stims,1) + (ISIs -40);
        event_index = indices{i};
        bl = mean(data(event_index(1,1)- bt:event_index(1,1) - 100));
        data_trial{i,d} = data(event_index(1) - bt:event_index(1) + number_stims*ISIs + bt);
        for ii = 1:length(event_index)
            [max_amp index_max] = max(data(event_index(ii,1):event_index(ii,2)));
            index_max = event_index(ii,1) + index_max -1;
            [min_amp index_min] = min(data(event_index(ii,1):index_max));
            index_min = event_index(ii,1) + index_min - 1;
            amp_event = data(index_min:index_max) - min_amp;
            amp_10 = find(amp_event > .1*max(amp_event),1, 'first');
            amp_90 = find(amp_event > .9*max(amp_event),1, 'first');
            amp_event = data(index_min:event_index(ii,2)) - min_amp;
            integral(ii)  = sum(amp_event);
            integral_event = data((index_min:event_index(ii,2))) - bl;
            integral_total(ii) = sum(integral_event);
            amps(ii) = max_amp - min_amp;
            ten_90(ii) = (amp_90 - amp_10)/sample_rate;
        end
        integral_total_event(i) = sum(integral_total);
        for iii = 1:length(event_index);
            amp_ratio(iii) = amps(iii)/amps(1);         
        end
        all_amps{i,d} = amps;
        amp_ratios{i,d} = amp_ratio;
        ten_90_all{i,d} = ten_90;
        integral_all{i,d} = integral;
        integral_total_event_all{:,d} = integral_total_event;
        s = s + number_stims;
        amps = [];
        amp_ratio = [];
        ten_90 = [];
        integral = [];
        integral_total = [];
        amp_event = [];
        integral_event = [];
    end
    data = [];
    diff1 = [];
    stim_art_index = [];
    diff2 = [];
    starts = [];
end

% calculate and plot averages in both conditions

for n = 1:number_trials
    amp_ns(n,:) = all_amps{n, no_shutter};
    amp_s(n,:) = all_amps{n, shutter};
    amp_ratios_ns(n,:) = amp_ratios{n, no_shutter};
    amp_ratios_s(n,:) = amp_ratios{n, shutter};
    ten_90_s(n,:) = ten_90_all{n, no_shutter};
    ten_90_ns(n,:) = ten_90_all{n, shutter};
    integral_ns(n,:) = integral_all{n, no_shutter};
    integral_s(n,:) = integral_all{n, shutter};    
end

integral_total_event_ns = integral_total_event_all{no_shutter};
integral_total_event_s = integral_total_event_all{shutter};



total_integral(no_shutter,1) = mean(integral_total_event_ns,2);
total_integral(shutter,2) = mean(integral_total_event_s,2);
errors_integral(no_shutter,1) = sem(integral_total_event_ns,2);
errors_integral(shutter,2) = sem(integral_total_event_s,2);


figure;
a(1) = subplot(3,1,1); hold on; title('amp');
errorbar(mean(amp_ns,1), std(amp_ns,1)); errorbar(mean(amp_s,1), std(amp_s,1),  'r');

a(2) = subplot(3,1,2); hold on; title('integral');
errorbar(mean(integral_ns,1), std(integral_ns,1)); errorbar(mean(integral_s,1), std(integral_s,1),  'r');

a(3) = subplot(3,1,3); hold on; title('Pulse Ratios');
errorbar(mean(amp_ratios_ns,1), std(amp_ratios_ns,1)); errorbar(mean(amp_ratios_s,1), std(amp_ratios_s,1), 'r');
linkaxes(a,'x');
hold off;


data_no_shutter = cat(3,data_trial{:,no_shutter});
data_shutter = cat(3,data_trial{:,shutter});

avg_data_ns = mean(data_no_shutter,3);
avg_data_s = mean(data_shutter,3);
figure; plot(avg_data_ns - mean(avg_data_ns(1:bt-10))); hold on; plot(avg_data_s - mean(avg_data_s(1:bt-10)), 'r'); hold off;

figure; barweb(total_integral, errors_integral);
