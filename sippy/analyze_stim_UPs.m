function a = analyze_stim

% This function will go through all .paq files in a specified folder and
% output baseline, indices of UP states, UP state amplitude, and UP state
% duration
% all outputs will be added to data structure tanyadata
% will organize outputs into the appropriate cell, defined by the channels
% from which data is imported from paq2lab

tanyadata.experiment.date = '031810s0'; % change this with each experiment - 1
tanyadata.experiment.foldername = '031810s0\analyze'; % -2
full_folder_name = fullfile('C:\Tanya_Data\Physiology',tanyadata.experiment.foldername);
tanyadata.experiment.age = [15];
stim_time = 4; %time of stim in seconds

files = dir(full_folder_name);

abovethresh = 2; 
belowthresh = 2;
mintime = 1000; 
maxtime = 40000;


channelsIwant = [ 2 6]; % channels to import from data file
% fulldatai = [1 2]; % total number of channels to be imported
Vi = [1]; % indices within channelsIwant of voltage channels imported from paq2lab
Ci = [2]; % indices within channelsIwant of voltage channels imported from paq2lab
% Si = [5]; %index of stim channel

DirCount=0;
for k=1:length(files);
    DirCount = DirCount + files(k).isdir;
end

for k = 1:length(files);
    if (files(k).isdir==0)
        Thisfile = fullfile(full_folder_name, files(k).name); %4
        info = paq2lab(Thisfile,'info');
        ephysrate = info.ObjInfo.SampleRate;
        [fulldata, names]=paq2lab(Thisfile,'channels',[channelsIwant]);
        NumCellsToAnalyze= length(Vi);
        %         stim = fulldata(1:10*ephysrate, Si);
        %         stim_index = continuousabove(stim, 0, 2, 0, 5);
        for c=1:NumCellsToAnalyze;
            SweepID=k-DirCount;
            dataVm = fulldata(1:10*ephysrate, Vi(c));
            dataI = fulldata(1:10*ephysrate, Ci(c)); % change 1 to NumCellsToAnalyze if voltage channels are in sequential order
            %             if ~isempty(stim_index)10
            %                 for s = 1:length(stim_index)
            %                     Si_delete(s,:) = stim_index(s)-5:stim_index(s)+5;
            %                 end
            %             else
            %                 disp('NO STIM DETECTED')
            %             end
            %             dataVm(Si_delete) = [];
            %             dataI(Si_delete) = [];
            [baselineVm meanbaseVm] = findbase(dataVm);
%             [baselineI meanbaseI] = findbase(dataI);
            meanbaseI = mean(dataI(1:35000));
            tanyadata.experiment.cells(c).numsweeps = length(files)-DirCount;
            tanyadata.experiment.cells(c).sweeps(SweepID).filename = Thisfile; % want every entry in sweeps to be its own structure
            tanyadata.experiment.cells(c).sweeps(SweepID).baselineVm = meanbaseVm;
            tanyadata.experiment.cells(c).sweeps(SweepID).baselineI = meanbaseI;
            if meanbaseVm > -55
                tanyadata.experiment.cells(c).sweeps(SweepID).analyze = 0; % if the mean baseline in above -60 analyze = 0
                aboveperiodsI = [];
                belowperiodsI = [];
            else if meanbaseVm < -55
                    figure; plot(dataVm);
                    tanyadata.experiment.cells(c).sweeps(SweepID).analyze = 1;% if the mean baseline in above -60 analyze = 1
                    dataI_norm = dataI./abs(meanbaseI);
                    aboveI = find(dataI_norm >= abovethresh);
                    belowI = find(dataI_norm <= belowthresh);
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
            if isempty(aboveperiodsI) && isempty(belowperiodsI)
                upstates = findupstates(dataVm); %indices of UPstate in data file
                if ~isempty(upstates);
                    if upstates (1,1) < stim_time*ephysrate; % if the first UP state happens before the stim
                        upstates (1,:) = []; % throw it away
                    end
                    if size(upstates, 1) > 1; % if there is more than 1 UP state found, throw them away;
                        for u = size(upstates, 1) -1;                         
                            upstates(u+1, :) = [];
                        end                      
                    end
                    if size(upstates, 1) == 1;
                        UPstate_Vm = dataVm(upstates(1):upstates(4));
                        aps = findaps1(UPstate_Vm);
                        if ~isempty(aps)
                            UP_AP_times = get_spike_timesTS(dataVm(upstates(1):upstates(4)));
                            Num_UPaps = size(UP_AP_times,1);
                            
                            for a = 1: size(UP_AP_times,1);
                                delete(:,a) = UP_AP_times(a)-49:UP_AP_times(a)+50;
                            end
                            UPstate_Vm(delete) = []; %remove 10 ms around each spike before getting average Vm
                            UP_amp = mean(dataVm(upstates(1):upstates(3)))- meanbaseVm; % subtract average Vm to get amp
                            for t = 1:length(UP_AP_times);
                                tt_all_spikes(t) = UP_AP_times(t)./ephysrate;
                            end
                            if length(tt_all_spikes) > 1
                                ISIs = diff(tt_all_spikes);
                            else ISIs = NaN;
                            end
                            tt1st = tt_all_spikes(1); % time to first spike
                        else
                            Num_UPaps = 0;
                            UP_amp = mean(dataVm(upstates(1):upstates(3))) - meanbaseVm;
                            tt1st= NaN;
                            tt_all_spikes = NaN;
                            ISIs = NaN;
                        end
                        UPdur = [upstates(3)- upstates(1)]/ephysrate;
                        tanyadata.experiment.cells(c).sweeps(SweepID).Numaps = Num_UPaps; % if no stim, number of aps = aps in UP state
                        tanyadata.experiment.cells(c).sweeps(SweepID).UPamp = UP_amp;
                        tanyadata.experiment.cells(c).sweeps(SweepID).UPdur = UPdur;
                        tanyadata.experiment.cells(c).sweeps(SweepID).tt1st = tt1st;
                        tanyadata.experiment.cells(c).sweeps(SweepID).tt_all_spikes = tt_all_spikes;
                        tanyadata.experiment.cells(c).sweeps(SweepID).ISIs = ISIs;
                        delete = [];
                    end
                    tanyadata.experiment.cells(c).sweeps(SweepID).upstates = upstates;
                end
                if isempty(upstates);
                    tanyadata.experiment.cells(c).sweeps(SweepID).upstates = NaN;
                    tanyadata.experiment.cells(c).sweeps(SweepID).numupstates= 0;
                    tanyadata.experiment.cells(c).sweeps(SweepID).Numaps = NaN;
                    tanyadata.experiment.cells(c).sweeps(SweepID).UPamp = NaN;
                    tanyadata.experiment.cells(c).sweeps(SweepID).UPdur = NaN;
                    tanyadata.experiment.cells(c).sweeps(SweepID).tt1st = NaN;
                    tanyadata.experiment.cells(c).sweeps(SweepID).tt_all_spikes = NaN;
                    tanyadata.experiment.cells(c).sweeps(SweepID).ISIs = NaN;
                end
                tanyadata.experiment.cells(c).cell_type = [];
            end
            upstates = [];
            tt_all_spikes = [];
            dataVm = [];
            ISIs = [];
            tt1st = [];
            aps = [];
            a = tanyadata;
        end
    end
end

