workspace = who;

PV_index = 1;
SOM_index = 1;
PC_index = 1;

for w = 1:length(workspace);
    expt = eval(workspace{w});
    if expt.experiment.age >= 13
        for c = 1:length(expt.experiment.cells)
            for s = 1:length(expt.experiment.cells(c).sweeps)
                if ~isempty(expt.experiment.cells(c).sweeps(s).Numaps)
                    tt1st(c,s) = expt.experiment.cells(c).sweeps(s).tt1st;
                    UP_amp(c,s) = expt.experiment.cells(c).sweeps(s).UPamp;
                    UP_dur(c,s) = expt.experiment.cells(c).sweeps(s).UPdur;
                    ISIs{c,s} = expt.experiment.cells(c).sweeps(s).ISIs;
                    Numaps(c,s) = expt.experiment.cells(c).sweeps(s).Numaps;
                end
            end           
            if strcmp(expt.experiment.cells(c).cell_type, 'PV') ==1
                tt1st_PV(PV_index) = getmeans(tt1st(c,:));
                UP_amp_PV(PV_index) = getmeans(UP_amp(c,:));
                UP_dur_PV(PV_index) = getmeans(UP_dur(c,:));
                ISIs_PV{PV_index} = ISIs(c,:);
                Numaps_PV(PV_index) = getmeans(Numaps(c,:));
                PV_index = PV_index + 1;
            else if strcmp(expt.experiment.cells(c).cell_type, 'SOM') ==1
                    tt1st_SOM(SOM_index) = getmeans(tt1st(c,:));
                    UP_amp_SOM(SOM_index) = getmeans(UP_amp(c,:));
                    UP_dur_SOM(SOM_index) = getmeans(UP_dur(c,:));
                    ISIs_SOM{SOM_index} = ISIs(c,:);
                    Numaps_SOM(SOM_index) = getmeans(Numaps(c,:));
                    SOM_index = SOM_index + 1;
                else
                    tt1st_PC(PC_index) = getmeans(tt1st(c,:));
                    UP_amp_PC(PC_index) = getmeans(UP_amp(c,:));
                    UP_dur_PC(PC_index) = getmeans(UP_dur(c,:));
                    ISIs_PC{PC_index} = ISIs(c,:);
                    Numaps_PC(PC_index) = getmeans(Numaps(c,:));
                    PC_index = PC_index + 1;
                end
            end
        end
    end
    tt1st = [];
    UP_amp = [];
    UP_dur =[];
    ISIs = [];
    Numaps = [];
end

%avg values for PV positive cells
avg_amp_PV  = getmeans(UP_amp_PV);
SE_amp_PV = get_SE(UP_amp_PV);
avg_dur_PV = getmeans(UP_dur_PV);
SE_dur_PV = get_SE(UP_dur_PV);
avg_tt1st_PV = getmeans(tt1st_PV);
SE_tt1st_PV = get_SE(tt1st_PV);
avg_Numaps_PV = getmeans(Numaps_PV);
SE_Numaps_PV = get_SE(Numaps_PV);

%avg values for SOM positive cells
avg_amp_SOM = getmeans(UP_amp_SOM);
SE_amp_SOM = get_SE(UP_amp_SOM);
avg_dur_SOM = getmeans(UP_dur_SOM);
SE_dur_SOM = get_SE(UP_dur_SOM);
avg_tt1st_SOM = getmeans(tt1st_SOM);
SE_tt1st_SOM = get_SE(tt1st_SOM);
avg_Numaps_SOM = getmeans(Numaps_SOM);
SE_Numaps_SOM = get_SE(Numaps_SOM);

%avg values for PC cells
avg_amp_PC = getmeans(UP_amp_PC);
SE_amp_PC = get_SE(UP_amp_PC);
avg_dur_PC = getmeans(UP_dur_PC);
SE_dur_PC = get_SE(UP_dur_PC);
avg_tt1st_PC = getmeans(tt1st_PC);
SE_tt1st_PC = get_SE(tt1st_PC);
avg_Numaps_PC = getmeans(Numaps_PC);
SE_Numaps_PC = get_SE(Numaps_PC);

%ISIs for all three cell types
ISIs_PV_all = [];
for p = 1:length(ISIs_PV)
    tempPV = ISIs_PV{p};
    for pp = 1:length(tempPV)
        ISIs_PV_all = [ISIs_PV_all tempPV{pp}];
    end
end

ISIs_SOM_all = [];
for s = 1:length(ISIs_SOM)
    tempSOM = ISIs_SOM{s};
    for ss = 1:length(tempSOM)
        ISIs_SOM_all = [ISIs_SOM_all tempSOM{ss}];
    end
end

ISIs_PC_all = [];
for pc = 1:length(ISIs_PC)
    tempPC = ISIs_PC{pc};
    for ppc = 1:length(tempPC)
        ISIs_PC_all = [ISIs_PC_all tempPC{ppc}];
    end
end

amps_all = [avg_amp_PV avg_amp_SOM avg_amp_PC];
errors_amp = [SE_amp_PV SE_amp_SOM SE_amp_PC];
dur_all = [avg_dur_PV avg_dur_SOM avg_dur_PC];
errors_dur = [SE_dur_PV SE_dur_SOM SE_dur_PC];
avg_tt1st_all = [avg_tt1st_PV avg_tt1st_SOM avg_tt1st_PC];
errors_tt1st = [SE_tt1st_PV SE_tt1st_SOM SE_tt1st_PC];
APs_all = [avg_Numaps_PV avg_Numaps_SOM avg_Numaps_PC];
errors_APs = [SE_Numaps_PV SE_Numaps_SOM SE_Numaps_PC];


%%relevant plotting
figure; hold on; title('Amp')
barweb(amps_all, errors_amp); hold off;
figure; hold on; title('Duration');
barweb(dur_all, errors_dur); hold off;
figure; hold on; title('tt1st spike');
barweb(dur_all, errors_dur); hold off;
figure; hold on; title('Number of APs')
barweb(APs_all, errors_APs); hold off;

clear w c s tt1st UP_amp UP_dur ISIs Numaps p pp s ss pc ppc amps_all errors_amp dur_all errors_dur avg_tt1st_all errors_tt1st APs_all errors_APs;


