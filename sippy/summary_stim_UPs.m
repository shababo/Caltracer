workspace = who;

PV_index = 1;
SOM_index = 1;
PC_index = 1;

for w = 1:length(workspace);
    expt = eval(workspace{w});
    for c = 1:length(expt.experiment.cells)
        if expt.experiment.age >= 8 && expt.experiment.age <= 18
            for s = 1:length(expt.experiment.cells(c).sweeps)
                if expt.experiment.cells(c).sweeps(s).analyze ==1
                    if ~isempty(expt.experiment.cells(c).sweeps(s).Numaps)
                        if abs(expt.experiment.cells(c).sweeps(s).baselineI) < 150;
                            Vm(s) = expt.experiment.cells(c).sweeps(s).baselineVm;
                            tt1st(s) = expt.experiment.cells(c).sweeps(s).tt1st;
                            UP_amp(s) = expt.experiment.cells(c).sweeps(s).UPamp;
                            UP_dur(s) = expt.experiment.cells(c).sweeps(s).UPdur;
                            ISIs{s} = expt.experiment.cells(c).sweeps(s).ISIs;
                            tt_all_spikes{s} = expt.experiment.cells(c).sweeps(s).tt_all_spikes;
                            Numaps(s) = expt.experiment.cells(c).sweeps(s).Numaps;
                        else
                            Vm(s) = NaN;
                            tt1st(s) = NaN;
                            UP_amp(s) = NaN;
                            UP_dur(s) = NaN;
                            ISIs{s} = NaN;
                            tt_all_spikes{s} = NaN;
                            Numaps(s) = NaN;
                        end
                    else
                        Vm(s) = NaN;
                        tt1st(s) = NaN;
                        UP_amp(s) = NaN;
                        UP_dur(s) = NaN;
                        ISIs{s} = NaN;
                        tt_all_spikes{s} = NaN;
                        Numaps(s) = NaN;
                    end
                else
                    Vm(s) = NaN;
                    tt1st(s) = NaN;
                    UP_amp(s) = NaN;
                    UP_dur(s) = NaN;
                    ISIs{s} = NaN;
                    tt_all_spikes{s} = NaN;
                    Numaps(s) = NaN;
                end
            end
        else
            Vm = NaN;
            tt1st = NaN;
            UP_amp = NaN;
            UP_dur = NaN;
            ISIs = {NaN};
            tt_all_spikes = {NaN};
            Numaps = NaN;
        end
        if exist('Numaps', 'var') && ~isempty(Numaps) 
            if strcmp(expt.experiment.cells(c).cell_type, 'PV') ==1
                Vm_PV(PV_index) = getmeans(Vm);
                tt1st_PV(PV_index) = getmeans(tt1st);
                UP_amp_PV(PV_index) = getmeans(UP_amp);
                UP_dur_PV(PV_index) = getmeans(UP_dur);
                ISIs_PV{PV_index} = ISIs;
                tt_all_PV{PV_index} = tt_all_spikes;
                Numaps_PV(PV_index) = getmeans(Numaps);
                if Numaps_PV(PV_index) > 0
                    Numaps(isnan(Numaps)) = [];
                    prob_spike_PV(PV_index) = length(find(Numaps))/length(Numaps);
                else
                    prob_spike_PV(PV_index) = NaN;
                end
                PV_index = PV_index + 1;
            end
            if strcmp(expt.experiment.cells(c).cell_type, 'SOM') ==1
                Vm_SOM(SOM_index) = getmeans(Vm);
                tt1st_SOM(SOM_index) = getmeans(tt1st);
                UP_amp_SOM(SOM_index) = getmeans(UP_amp);
                UP_dur_SOM(SOM_index) = getmeans(UP_dur);
                ISIs_SOM{SOM_index} = ISIs;
                tt_all_SOM{SOM_index} = tt_all_spikes;
                Numaps_SOM(SOM_index) = getmeans(Numaps);
                if Numaps_SOM(SOM_index) > 0
                    Numaps(isnan(Numaps)) = [];
                    prob_spike_SOM(SOM_index) = length(find(Numaps))/length(Numaps);
                else
                    prob_spike_SOM(SOM_index) = NaN;
                end
                SOM_index = SOM_index + 1;
            end
            if strcmp(expt.experiment.cells(c).cell_type, 'PC') == 1
                Vm_PC(PC_index) = getmeans(Vm);
                tt1st_PC(PC_index) = getmeans(tt1st);
                UP_amp_PC(PC_index) = getmeans(UP_amp);
                UP_dur_PC(PC_index) = getmeans(UP_dur);
                ISIs_PC{PC_index} = ISIs;
                tt_all_PC{PC_index} = tt_all_spikes;
                Numaps_PC(PC_index) = getmeans(Numaps);
                if Numaps_PC(PC_index) > 0 
                    Numaps(isnan(Numaps)) = [];
                    prob_spike_PC(PC_index) = length(find(Numaps))/length(Numaps);
                else
                    prob_spike_PC(PC_index) = NaN;
                end
                PC_index = PC_index + 1;
            end
        end
    end
    Vm = [];
    tt1st = [];
    UP_amp = [];
    UP_dur =[];
    ISIs = [];
    tt_all_spikes = [];
    Numaps = [];
end


%avg values for PV positive cells
Vm_PV(isnan(Vm_PV)) = [];
Number_PV = length(Vm_PV);
avg_Vm_PV = getmeans(Vm_PV);
SE_Vm_PV = get_SE(Vm_PV);
avg_amp_PV  = getmeans(UP_amp_PV);
SE_amp_PV = get_SE(UP_amp_PV);
avg_dur_PV = getmeans(UP_dur_PV);
SE_dur_PV = get_SE(UP_dur_PV);
avg_tt1st_PV = getmeans(tt1st_PV);
SE_tt1st_PV = get_SE(tt1st_PV);
avg_Numaps_PV = getmeans(Numaps_PV);
SE_Numaps_PV = get_SE(Numaps_PV);
avg_prob_spike_PV = getmeans(prob_spike_PV(find(prob_spike_PV))); %in cells that DO spike, what is the prob of spiking in any given trial?
SE_prob_spike_PV = get_SE(prob_spike_PV(find(prob_spike_PV)));
avg_aps_active_PV = getmeans(Numaps_PV(find(Numaps_PV)));
SE_aps_active_PV = get_SE(Numaps_PV(find(Numaps_PV)));
Numaps_PV(isnan(Numaps_PV)) = [];
percent_active_PV = length(find(Numaps_PV))/length(Numaps_PV); %out of all cells, what percent spike during any trial?


%avg values for SOM positive cells
Vm_SOM(isnan(Vm_SOM)) = [];
Number_SOM = length(Vm_SOM);
avg_Vm_SOM = getmeans(Vm_SOM);
SE_Vm_SOM = get_SE(Vm_SOM);
avg_amp_SOM = getmeans(UP_amp_SOM);
SE_amp_SOM = get_SE(UP_amp_SOM);
avg_dur_SOM = getmeans(UP_dur_SOM);
SE_dur_SOM = get_SE(UP_dur_SOM);
avg_tt1st_SOM = getmeans(tt1st_SOM);
SE_tt1st_SOM = get_SE(tt1st_SOM);
avg_Numaps_SOM = getmeans(Numaps_SOM);
SE_Numaps_SOM = get_SE(Numaps_SOM);
avg_prob_spike_SOM = getmeans(prob_spike_SOM(find(prob_spike_SOM)));
SE_prob_spike_SOM = get_SE(prob_spike_SOM(find(prob_spike_SOM)));
avg_aps_active_SOM = getmeans(Numaps_SOM(find(Numaps_SOM)));
SE_aps_active_SOM = get_SE(Numaps_SOM(find(Numaps_SOM)));
Numaps_SOM(isnan(Numaps_SOM)) = [];
percent_active_SOM = length(find(Numaps_SOM))/length(Numaps_SOM);

%avg values for PC cells
Vm_PC(isnan(Vm_PC)) = [];
Number_PC = length(Vm_PC);
avg_Vm_PC = getmeans(Vm_PC);
SE_Vm_PC = get_SE(Vm_PC);
avg_amp_PC = getmeans(UP_amp_PC);
SE_amp_PC = get_SE(UP_amp_PC);
avg_dur_PC = getmeans(UP_dur_PC);
SE_dur_PC = get_SE(UP_dur_PC);
avg_tt1st_PC = getmeans(tt1st_PC);
SE_tt1st_PC = get_SE(tt1st_PC);
avg_Numaps_PC = getmeans(Numaps_PC);
SE_Numaps_PC = get_SE(Numaps_PC);
avg_prob_spike_PC = getmeans(prob_spike_PC(find(prob_spike_PC)));
SE_prob_spike_PC = get_SE(prob_spike_PC(find(prob_spike_PC)));
avg_aps_active_PC = getmeans(Numaps_PC(find(Numaps_PC)));
SE_aps_active_PC = get_SE(Numaps_PC(find(Numaps_PC)));
Numaps_PC(isnan(Numaps_PC)) = [];
percent_active_PC = length(find(Numaps_PC))/length(Numaps_PC);

%avg values for all cells
all_amps = [UP_amp_PV UP_amp_SOM UP_amp_PC];
avg_all_amps = mean(all_amps);
SE_all_amps = get_SE(all_amps);
all_dur = [UP_dur_PV UP_dur_SOM UP_dur_PC];
avg_all_dur = mean(all_dur);
SE_all_dur = get_SE(all_dur);


%ISIs for all three cell types
ISIs_PV_all = [];
for p = 1:length(ISIs_PV)
    tempPV = ISIs_PV{p};
    for pp = 1:length(tempPV)
        ISIs_PV_all = [ISIs_PV_all tempPV{pp}];
        mean_trial(pp) = getmeans(tempPV{pp});
    end
    ISIs_PV_mean_cell(p) = getmeans(mean_trial);
    mean_trial = [];
end

ISIs_SOM_all = [];
for s = 1:length(ISIs_SOM)
    tempSOM = ISIs_SOM{s};
    for ss = 1:length(tempSOM)
        ISIs_SOM_all = [ISIs_SOM_all tempSOM{ss}];
        mean_trial(ss) = getmeans(tempSOM{ss});
    end
    ISIs_SOM_mean_cell(s) = getmeans(mean_trial);
    mean_trial = [];
end

ISIs_PC_all = [];
for pc = 1:length(ISIs_PC)
    tempPC = ISIs_PC{pc};
    for ppc = 1:length(tempPC)
        ISIs_PC_all = [ISIs_PC_all tempPC{ppc}];
        mean_trial(ppc) = getmeans(tempPC{ppc});
    end
    ISIs_PC_mean_cell(pc) = getmeans(mean_trial);
    mean_trial = [];
end

%tt_all for all subtypes

tt_all_PV_all = [];
for q = 1:length(tt_all_PV)
    ttempPV = tt_all_PV{q};
    for qq = 1:length(ttempPV)
        tt_all_PV_all = [tt_all_PV_all ttempPV{qq}];
    end
end

tt_all_SOM_all = [];
for r = 1:length(tt_all_SOM)
    ttempSOM = tt_all_SOM{r};
    for rr = 1:length(ttempSOM)
        tt_all_SOM_all = [tt_all_SOM_all ttempSOM{rr}];
    end
end

tt_all_PC_all = [];
for x = 1:length(tt_all_PC)
    ttempPC = tt_all_PC{x};
    for xx = 1:length(ttempPC)
        tt_all_PC_all = [tt_all_PC_all ttempPC{xx}];
    end
end

Vm_all = [avg_Vm_PV avg_Vm_SOM avg_Vm_PC];
errors_Vm = [SE_Vm_PV SE_Vm_SOM SE_Vm_PC];

amps_all = [avg_amp_PV avg_amp_SOM avg_amp_PC];
errors_amp = [SE_amp_PV SE_amp_SOM SE_amp_PC];

dur_all = [avg_dur_PV avg_dur_SOM avg_dur_PC];
errors_dur = [SE_dur_PV SE_dur_SOM SE_dur_PC];

APs_all = [avg_Numaps_PV avg_Numaps_SOM avg_Numaps_PC];
errors_APs = [SE_Numaps_PV SE_Numaps_SOM SE_Numaps_PC];




%%relevant plotting

figure;
a(1) = subplot(1,3,1);
hold on; title('Amp')
barweb([amps_all], [errors_amp]);
a(2) = subplot(1,3,2);
hold on; title('Duration');
barweb(dur_all, errors_dur);
a(3) = subplot(1,3,3);
hold on; title('tt1st spike');
barweb([avg_tt1st_PV avg_tt1st_SOM avg_tt1st_PC], [SE_tt1st_PV/2 SE_tt1st_SOM/2 SE_tt1st_PC/2]);





figure;
aa(1) = subplot(1,3,1);
hold on; title('percent cells active');
barweb([percent_active_PV percent_active_SOM percent_active_PC], [0 0 0]);
aa(2) = subplot(1,3,2);
hold on; title('probability of spiking in active cells');
barweb([avg_prob_spike_PV avg_prob_spike_SOM avg_prob_spike_PC], [SE_prob_spike_PV SE_prob_spike_SOM SE_prob_spike_PC]);
aa(3) = subplot(1,3,3);
hold on; title('Number of APs in active cells vs ALL cells')
barweb([avg_aps_active_PV avg_aps_active_SOM avg_aps_active_PC], [SE_aps_active_PV/2.5 SE_aps_active_SOM SE_aps_active_PC]);
% aa(4) = subplot(1,4,4);
% hold on; title('tt1st spike');
% barweb([avg_tt1st_PV avg_tt1st_SOM avg_tt1st_PC], [SE_tt1st_PV/2 SE_tt1st_SOM/2 SE_tt1st_PC/2]);


ISImin = 0;
ISImax = 1;
bins = 20;
edges = linspace(ISImin,ISImax,bins);

counts_ISIs_PV = histc(ISIs_PV_all, edges);
counts_ISIs_SOM = histc(ISIs_SOM_all, edges);
counts_ISIs_PC = histc(ISIs_PC_all, edges);

N_ISIs_PV_all = sum(counts_ISIs_PV);
N_ISIs_SOM_all = sum(counts_ISIs_SOM);
N_ISIs_PC_all = sum(counts_ISIs_PC);

counts_prob_ISI_PV_all = counts_ISIs_PV/N_ISIs_PV_all;
counts_prob_ISI_SOM_all = counts_ISIs_SOM/N_ISIs_SOM_all;
counts_prob_ISI_PC_all = counts_ISIs_PC/N_ISIs_PC_all;

figure;
a(1) = subplot(3,1,1); hold on; title('PV ISIs');
bar(edges, counts_prob_ISI_PV_all, 'b');

a(2) = subplot(3,1,2); hold on; title('SOM ISIs');
bar(edges, counts_prob_ISI_SOM_all, 'g');

a(3) = subplot(3,1,3); hold on; title('PC ISIs');
bar(edges, counts_prob_ISI_PC_all, 'r');
linkaxes(a,'x');
hold off;

ISImin2 = 0;
ISImax2 = 2.5;
bins2 = 40;
edges2 = linspace(ISImin2,ISImax2,bins2);

counts_tt_all_PV = histc(tt_all_PV_all, edges2);
counts_tt_all_SOM = histc(tt_all_SOM_all, edges2);
counts_tt_all_PC = histc(tt_all_PC_all, edges2);

N_tt_all_PV = sum(counts_tt_all_PV);
N_tt_all_PC = sum(counts_tt_all_PC);
N_tt_all_SOM = sum(counts_tt_all_SOM);

counts_prob_tt_all_PV = counts_tt_all_PV/N_tt_all_PV;
counts_prob_tt_all_SOM = counts_tt_all_SOM/N_tt_all_SOM;
counts_prob_tt_all_PC = counts_tt_all_PC/N_tt_all_PC;
  

figure;
a(1) = subplot(3,1,1); hold on; title('PV tt all');
bar(edges2, counts_prob_tt_all_PV, 'b');

a(2) = subplot(3,1,2); hold on; title('SOM tt all');
bar(edges2, counts_prob_tt_all_SOM, 'g');

a(3) = subplot(3,1,3); hold on; title('PC tt all');
bar(edges2, counts_prob_tt_all_PC, 'r');
linkaxes(a,'x');
hold off;

clear  ISImax2 ISImin2 q r x qq rr xx w c s tt1st UP_amp UP_dur ISIs Numaps ISImin ISImax bins edges p pp s ss pc ppc amps_all errors_amp dur_all errors_dur avg_tt1st_all errors_tt1st;


