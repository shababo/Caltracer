function [curve, a] = make_IV_struct(ExpDat);

% if the data has been exported into the workspace as an ExpDat structure
% with voltage as the first field and current and the second field

names = fieldnames(ExpDat);

Vm = eval(strcat('ExpDat.',names{1}));
I = eval(strcat('ExpDat.',names{2}));  


abovethresh = 4; %this is the minumum current injected that you want to detect
belowthresh = -4;
mintime = 100; %divide by sample rate usually 10,000 to convert to seconds
maxtime = 1000000;
inj_length = 10000; 


% Vm = data(:,1);
% I = data(:,2);

baselineI = mean(I(1:4000)); % the calculation of this baseline value assumes no current injections in the first 400ms of the data file

aboveperiodsI = continuousabove(I, baselineI, abovethresh, mintime, maxtime);
% aboveperiodsI(end+1,1) = 130000;
% aboveperiodsI(end,2) = 139999;
belowperiodsI = continuousbelow(I, baselineI, belowthresh, mintime, maxtime);
% belowperiodsI(end+1,1) = 90001;
% belowperiodsI(end,2) = 100000;

all_I_periods = cat(1, belowperiodsI, aboveperiodsI);

for c = 1: length(all_I_periods)
dataVm(:,c) = Vm(all_I_periods(c,1) + 10:all_I_periods(c,1) + inj_length - 10);
dataVm_plot(:,c) = Vm(all_I_periods(c,1) -1500:all_I_periods(c,1) + inj_length + 2000);
dataVms = dataVm(:,c);
full_minus100ms(c) = length(dataVm(:,c)) - 1000; % find endex of the beginning of the last 100ms of current step.
meanVm(c) = mean(dataVms(full_minus100ms(c): size(dataVms,1))); % find the average voltage of the trace during the last 100ms of current step
meanI(c) = mean(I(all_I_periods(c,1)+100:all_I_periods(c,2)-100)); 
end

dataVm_plot(:,end +1) = Vm(120000 -1500:120000 + inj_length + 2000);
voltages(1) = mean(Vm(1:4000)); % first entry is mean Vm of trace
currents(1) = baselineI; % first entry is baseline I injected (usually this is 0)

for d = 1:length(meanVm) % as many current steps as were given
voltages(d + 1) = meanVm(d); % add the value of the voltage at each current step to this vector
currents(d + 1) = meanI(d); % add the value of the current at each current step to this vector
end

voltages = sort(voltages);
currents = sort(currents);


figure;
for p = 1:size(dataVm_plot,2);
    plot(dataVm_plot(:,p), 'b');
    hold on;
end
hold off;

figure;
plot(currents(1:6), voltages(1:6), 'o');
curve = figure;
a(:,1) = voltages;
a(:,2) = currents;
% Fit a line thru the data and plot the result over the data plot
temp = polyfit(currents(1:6),voltages(1:6),1); % least squares fitting to a line
a1 = temp(2); % y-intercept of the fitted line
a2 = temp(1); % slope of fitted lines
fit = a1+a2*currents(1:11);
hold on;
plot(currents(1:11),fit, 'ko-');

plot(currents(1:11), voltages(1:11), 'ob-');
end




