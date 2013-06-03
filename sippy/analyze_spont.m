function spontups = analyze_spont(data)

% This function is similar in style to analyze_stim except that now ALL
% upstates will be found in a given data file and duration, amplitude and
% number of action potentials will be extracted into a data structure which
% can later be used for comparative analysis within and across experiments

tanyadata.experiment = '072508'; % experiment name in this function will be the same as folder name


files = dir('C:\Tanya_Data\Physiology\072508\analyze'); %files to be analyzed (each file is a 'sweep')
abovethresh = 30;

channelsIwant = [1 2 5 6]; % channels to import from data file
% fulldatai = [1 2]; % total number of channels to be imported
Vi = [1 2]; % indices within channelsIwant of voltage channels imported from paq2lab
Ci = [3 4]; % indices within channelsIwant of voltage channels imported from paq2lab

% to exclude the files which are directories from the analysis:

DirCount=0; %dircount = number of files which are directories
for k=1:length(files);
    DirCount = DirCount + files(k).isdir;
end


for k = 1:length(files);
    if (files(k).isdir==0) % if file is NOT a dir file
        Thisfile = fullfile('C:\Tanya_Data\Physiology\072508\analyze', files(k).name);
        [fulldata, names]=paq2lab(Thisfile,'channels',[channelsIwant]);
        NumCellsToAnalyze= length(Vi);
        for c=1:NumCellsToAnalyze;
            SweepID=k-DirCount; % number of actual sweeps to analyze
            dataVm = fulldata(:, Vi(c));
            dataI = fulldata(:, Ci(c));
            baselineVm = det_baseline(dataVm);
            baselineI = det_baseline(dataI);
            meanbaseVm = mean(baselineVm);
            meanbaseI = mean(baselineI);
            tanyadata.experiment.cells(c).numsweeps = length(files)-DirCount;
            tanyadata.experiment.cells(c).sweeps(SweepID).filename = Thisfile; % want every entry in sweeps to be its own structure
            tanyadata.experiment.cells(c).sweeps(SweepID).meanbaseVm = meanbaselineVm; %subfield 'baseline' is average of baseline
            tanyadata.experiment.cells(c).sweeps(SweepID).meanbaseI = meanbaselineI;
            tanyadata.experiment.cells(c).sweeps(SweepID).isINT = [];
            if meanbaseVm > -55
                tanyadata.experiment.cells(c).sweeps(SweepID).analyze = 0; % if the mean baseline in above -60 analyze = 0
                tanyadata.experiment.cells(c).sweeps(SweepID).UPS = NaN;
            end
            if meanbaseVm < -55
                upstates = findupstates(data);
                if ~ isempty(upstates); % if there are upstates
                    for u = 1:length(size(upstates, 1));
                        [apsepoch(u) apssubepoch(u)] = subdiv_epoch(dataVm, upstates(u)); % number of epochs determined in subdiv_epoch.m function
                        tanyadata.experiment.cells(c).sweeps(SweepID).upstates = upstates;
                        tanyadata.experiment.cells(c).sweeps(SweepID).numupstates = size(upstates,1);
                        tanyadata.experiment.cells(c).sweeps(SweepID).APepochs = apsepoch;
                        tanyadata.experiment.cells(c).sweeps(SweepID).APsubepochs = apssubepoch;







