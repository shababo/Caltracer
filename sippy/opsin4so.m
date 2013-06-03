workspace=who;

%data will be in workspace from packephys (export visible data)

sample_rate = 10000;
ISI = 20; %interstimulus interval in Hz
ITI = 9; % intertrial interval--> seconds in between stimulation trials change according to experimental conditions
base_time = .05; %time before trials in which there is a baseline


ITIs = ITI*sample_rate;

ISIs = (1/ISI)*sample_rate;


bt = base_time*sample_rate;

no_shutter = [];
shutter = [];
shutter_only = [];



soi = 1;
for dd=1:length(workspace)
    channels=fieldnames(eval(workspace{dd}));
    channels(end) = [];
    data = eval([workspace{dd} '.' channels{1}]);
    data_stim = eval([workspace{dd} '.' channels{2}]);
    data_shutter = eval([workspace{dd} '.' channels{3}]);
    stim_art_index = continuousabove(data_stim, 0, 2, 1, 5);
    shutter_index = continuousabove(data_shutter,0,2,10,10000);
    if isempty(stim_art_index)
        shutter_only(soi) = dd;
        soi = soi + 1;
        ISI_shutter = diff(shutter_index(:,1));
        starts = shutter_index(find(ISI_shutter(:,1) > ITIs) +1);
        starts(end +1) = shutter_index(1);
        starts = sort(starts);
        number_shutter = length(shutter_index(:,1))/length(starts);
        for ff = 1:length(starts)
            data_ns{ff} = data(starts(ff) - ISIs:starts(ff) + number_shutter*ISIs + ISIs);
            data_ns{ff} = data_ns{ff} - mean(data_ns{ff}(1:ISIs-10));
        end
    end
end

all_data_ns = cat(3,data_ns{1,:});
mean_data_ns = mean(all_data_ns,3);
nsi = 1;
si = 1;



data = [];
data_stim = [];
data_shutter = [];
stim_art_index = [];
shutter_index = [];

for d=1:length(workspace)
    channels=fieldnames(eval(workspace{d}));
    channels(end) = [];
    data = eval([workspace{d} '.' channels{1}]);
    data_stim = eval([workspace{d} '.' channels{2}]);
    data_shutter = eval([workspace{d} '.' channels{3}]);
    stim_art_index = continuousabove(data_stim, 0, 2, 1, 100);
    shutter_index = continuousabove(data_shutter,0,2,10,10000);
    if ~isempty(stim_art_index)
        if isempty(shutter_index)
            no_shutter(nsi) = d;
            nsi = nsi + 1;
        else if ~isempty(shutter_index)
                shutter(si) = d;
                si = si + 1;
            end
        end
        ISI_all = roundn(diff(stim_art_index),1);
        ISIs_data = ISI_all(1);
        ISIs_range = ISIs_data-20:ISIs_data + 20;
        end_trial = find(ISI_all(:,1) > ITIs);
        number_trials = length(end_trial) + 1;
        number_stims = length(stim_art_index)/number_trials;
        if isempty(find(ismember(ISIs_data,ISIs_range)))
            error('user input ISIs does not match calculated ISIs');
        end
        s = 1;
        for i = 1:number_trials
            indices{i} = zeros(number_stims,2);
            indices{i}(1:number_stims,1) = stim_art_index(s:s + number_stims -1,2) + 20;
            indices{i}(1:number_stims,2) = indices{i}(1:number_stims,1) + (ISIs -40);
            event_index = indices{i};
            bl = mean(data(event_index(1,1)- bt:event_index(1,1) - 100));
            data= data -bl;
            bl = mean(data(event_index(1,1)- bt:event_index(1,1) - 100));
            if ismember(d,shutter)
                data(stim_art_index(s)-ISIs:stim_art_index(s) + number_stims*ISIs + ISIs) = data(stim_art_index(s)-ISIs:stim_art_index(s) + number_stims*ISIs + ISIs) - mean_data_ns;
            end
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
        stim_art_index = [];
    end
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



total_integral(1,1) = mean(integral_total_event_ns,2);
total_integral(2,1) = mean(integral_total_event_s,2);
errors_integral(1,1) = sem(integral_total_event_ns,2);
errors_integral(2,1) = sem(integral_total_event_s,2);


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
figure; plot(avg_data_ns); hold on; plot(avg_data_s, 'r'); hold off;

figure; barweb(total_integral, errors_integral);
