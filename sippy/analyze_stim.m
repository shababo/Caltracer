function a = analyze_stim

% This function will go through all .paq files in a specified folder and
% output baseline, indices of UP states, UP state amplitude, and UP state
% duration
% all outputs will be added to data structure tanyadata
% will organize outputs into the appropriate cell, defined by the channels
% from which data is imported from paq2lab

tanyadata.experiment.date = '013009s2'; % change this with each experiment - 1
tanyadata.experiment.foldername = '013009s2'; % -2


files = dir('C:\Tanya_Data\Physiology\013009s2\analyze'); % 3

abovethresh = 50; % make sure gain is correct before setting this number
belowthresh = 50;
mintime = 1000;
maxtime = 40000;


channelsIwant = [1 2 5 6]; % channels to import from data file
% fulldatai = [1 2]; % total number of channels to be imported
Vi = [1 2]; % indices within channelsIwant of voltage channels imported from paq2lab
Ci = [3 4]; % indices within channelsIwant of voltage channels imported from paq2lab

DirCount=0;
for k=1:length(files);
    DirCount = DirCount + files(k).isdir;
end

for k = 1:length(files);
    if (files(k).isdir==0)
        Thisfile = fullfile('C:\Tanya_Data\Physiology\013009s2\analyze', files(k).name); % 4
        [fulldata, names]=paq2lab(Thisfile,'channels',[channelsIwant]);
        NumCellsToAnalyze= length(Vi);
        for c=1:NumCellsToAnalyze;
            SweepID=k-DirCount;
            dataVm = fulldata(:, Vi(c));
            dataI = fulldata(:, Ci(c)); % change 1 to NumCellsToAnalyze if voltage channels are in sequential order
            meanbaselineVm = mean(dataVm(1:30000)); % mean of first 3 seconds of trace
            meanbaselineI = mean(dataI(1:30000));
            tanyadata.experiment.cells(c).numsweeps = length(files)-DirCount;
            tanyadata.experiment.cells(c).sweeps(SweepID).filename = Thisfile; % want every entry in sweeps to be its own structure
            tanyadata.experiment.cells(c).sweeps(SweepID).baselineVm = meanbaselineVm; %subfield 'baseline' is average Vm in first 3s of sweep
            tanyadata.experiment.cells(c).sweeps(SweepID).baselineI = meanbaselineI;
            if meanbaselineVm > -55
                tanyadata.experiment.cells(c).sweeps(SweepID).analyze = 0; % if the mean baseline in above -60 analyze = 0
                tanyadata.experiment.cells(c).sweeps(SweepID).stim = 0;
                tanyadata.experiment.cells(c).sweeps(SweepID).aps = NaN;
                tanyadata.experiment.cells(c).sweeps(SweepID).UPamp = NaN;
                tanyadata.experiment.cells(c).sweeps(SweepID).UPdur = NaN;
                tanyadata.experiment.cells(c).sweeps(SweepID).tt1st = NaN;
                aboveperiodsI = [];
                belowperiodsI = [];
            else if meanbaselineVm < -55
                    tanyadata.experiment.cells(c).sweeps(SweepID).analyze = 1; % if the mean baseline in above -60 analyze = 1
                    aboveI = find(dataI(1:74000) >= meanbaselineI + abovethresh);
                    belowI = find(dataI(1:74000) <= meanbaselineI - belowthresh);
                    if max(diff(diff(aboveI)))<= 1 & length(aboveI)>=mintime & length(aboveI)<=maxtime;
                        aboveperiodsI = [aboveI(1): aboveI(end)];
                    else
                        aboveperiodsI = [];
                    end
                    if max(diff(diff(belowI)))<= 1 & length(belowI)>=mintime & length(belowI)<=maxtime;
                        belowperiodsI = [belowI(1): belowI(end)];
                    else
                        belowperiodsI = [];
                    end
                end
            end
            if ~isempty(aboveperiodsI)
                stim = 1;
                tanyadata.experiment.cells(c).sweeps(SweepID).stim = 1; % no stim =0; stim = 1
                apsindices = findaps2(dataVm(aboveperiodsI));
                tanyadata.experiment.cells(c).sweeps(SweepID).stimaps = length(apsindices);% if stim in this cell, number of AP = aps resulting from stim
                tanyadata.experiment.cells(c).sweeps(SweepID).upstates = NaN;
                tanyadata.experiment.cells(c).sweeps(SweepID).numupstates= NaN;
                tanyadata.experiment.cells(c).sweeps(SweepID).UPamp = NaN;
                tanyadata.experiment.cells(c).sweeps(SweepID).UPdur = NaN;
                apindices_afterstim = findaps2(dataVm(aboveI(end):74000));
                if  ~isempty(apindices_afterstim)
                    tanyadata.experiment.cells(c).sweeps(SweepID).aps = length(apindices_afterstim);
                    tanyadata.experiment.cells(c).sweeps(SweepID).totalaps = length(apsindices) + length(apindices_afterstim);
                else
                    tanyadata.experiment.cells(c).sweeps(SweepID).aps = NaN;
                    tanyadata.experiment.cells(c).sweeps(SweepID).totalaps = NaN;
                end
            else if ~isempty(belowperiodsI)
                    stim = 2;
                    tanyadata.experiment.cells(c).sweeps(SweepID).stim = 2;
                    apsindices = findaps2(dataVm(belowperiodsI));
                    tanyadata.experiment.cells(c).sweeps(SweepID).stimaps = length(apsindices);
                    tanyadata.experiment.cells(c).sweeps(SweepID).upstates = NaN;
                    tanyadata.experiment.cells(c).sweeps(SweepID).numupstates= NaN;
                    tanyadata.experiment.cells(c).sweeps(SweepID).UPamp = NaN;
                    tanyadata.experiment.cells(c).sweeps(SweepID).UPdur = NaN;
                else stim = 0;
                    tanyadata.experiment.cells(c).sweeps(SweepID).stim = 0;
                end
            end
            if stim == 0;
                upstates = findupstates(dataVm(1:74000)); %indices of UPstate in data file
                if ~ isempty(upstates);
                    if upstates (1,1) < 30000; % if the first UP state happens before the stim
                        upstates (1,:) = []; % throw it away
                    end
                    if size(upstates, 1) > 1; % if there is more than 1 UP state found, throw them away; will go back and fix this
                        for u = size(upstates, 1) - 1;
                            upstates(u+1,:) = [];
                        end
                    end
                    if size(upstates, 1) == 1;
                        [apsepoch apssubepoch] = subdiv_epoch(dataVm, upstates); % number of epochs determined in subdiv_epoch.m function
                        tanyadata.experiment.cells(c).sweeps(SweepID).upstates = upstates;
                        tanyadata.experiment.cells(c).sweeps(SweepID).numupstates = size(upstates,1);
                        tanyadata.experiment.cells(c).sweeps(SweepID).APepochs = apsepoch;
                        tanyadata.experiment.cells(c).sweeps(SweepID).APsubepochs = apssubepoch;
                        UP_aps = findaps2(dataVm(upstates(1):upstates(4)), 'durations');
                        Num_UPaps = size(UP_aps,1);
                        UPstate_Vm = dataVm(upstates(1):upstates(4));
                        if ~isempty(UP_aps) %if there are APs in the UP state
                            for a = 1: size(UP_aps,1);
                                UPstate_Vm(UP_aps(a,1):UP_aps(a,2)) = 0; %set Vm trace to 0 where there are APs
                            end
                            UP_Vm = mean(UPstate_Vm(find(UPstate_Vm))); % average Vm excludes points where there are APs.
                            for t = 1:length(UP_aps);
                                tt_all_spikes(t) = UP_aps(t)/10000;
                            end
                            
                            tt1st = tt_all_spikes(1); % time to first spike 
                        else UP_Vm = mean(UPstate_Vm);
                            tt1st= NaN;
                            tt_all_spikes = NaN;
                        end
                        UPamp = UP_Vm - meanbaselineVm;
                        UPdur = [upstates(4)- upstates(1)]/10000;
                        tanyadata.experiment.cells(c).sweeps(SweepID).aps = Num_UPaps; % if no stim, number of aps = aps in UP state
                        tanyadata.experiment.cells(c).sweeps(SweepID).UPamp = UPamp;
                        tanyadata.experiment.cells(c).sweeps(SweepID).UPdur = UPdur;
                        tanyadata.experiment.cells(c).sweeps(SweepID).tt1st = tt1st;
                        tanyadata.experiment.cells(c).sweeps(SweepID).tt_all_spikes = tt_all_spikes;
                    end
                end
                if isempty(upstates);
                    tanyadata.experiment.cells(c).sweeps(SweepID).upstates = NaN;
                    tanyadata.experiment.cells(c).sweeps(SweepID).numupstates= 0;
                    tanyadata.experiment.cells(c).sweeps(SweepID).aps = NaN;
                    tanyadata.experiment.cells(c).sweeps(SweepID).UPamp = NaN;
                    tanyadata.experiment.cells(c).sweeps(SweepID).UPdur = NaN;
                    tanyadata.experiment.cells(c).sweeps(SweepID).APepochs = [NaN;NaN;NaN];
                    tanyadata.experiment.cells(c).sweeps(SweepID).tt1st = NaN;
                    tanyadata.experiment.cells(c).sweeps(SweepID).tt_all_spikes = NaN;
                end
                tanyadata.experiment.cells(c).sweeps(SweepID).NUMcellsACT= [];
            end
            a = tanyadata;
        end
    end
end
end


