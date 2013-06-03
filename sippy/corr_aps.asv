function [cellsactive, stim1, APs1, UP_amp1, UP_dur1, varargout] = corr_aps(tanyadata)

% this function will go through all sweeps in a data structure and plot the
% number of action potentials in the neuron of interest with number of
% cells active
% In experiments in which there are two or more cells patched, this
% function will also plot #APs vs UPamp, and duration for each of the other
% patched cells

% cellsactive = []; put back in once have completed the structure to
% include this value
cellsactive = [];
stim1 = [];
APs1 = [];
UP_amp1 = [];
UP_dur1 = [];
stim2 = [];
APs2 = [];
UP_amp2 = [];
UP_dur2 = [];
stim3 = [];
APs3 = [];
UP_amp3 = [];
UP_dur3 = [];


for c = 1:length(tanyadata.experiment.cells);
    for i = 1:length(tanyadata.experiment.cells(1).sweeps);
        cellsactive(i) = [tanyadata.experiment.cells(1).sweeps(i).NUMcellsACT];
        if isempty([tanyadata.experiment.cells(1).sweeps(i).NUMcellsACT]);
            cellsactive(i) = NaN;
        end
        if length(tanyadata.experiment.cells) == 1 & tanyadata.experiment.cells.sweeps(i).analyze ==1;
            if tanyadata.experiment.cells.sweeps(i).stim == 0;
                stim1(i) = [0];
                APs1(i) = [tanyadata.experiment.cells.sweeps(i).aps];
            end
            if tanyadata.experiment.cells.sweeps(i).stim == 1 & isnan([tanyadata.experiment.cells.sweeps(i).totalaps]) == 1;
                stim1(i) = [1];
                APs1(i) = [tanyadata.experiment.cells.sweeps(i).stimaps];
            else if tanyadata.experiment.cells.sweeps(i).stim == 1 & ~isempty([tanyadata.experiment.cells(2).sweeps(i).totalaps])
                    APs1(i) = [tanyadata.experiment.cells.sweeps(i).totalaps];
                end
            end
            UP_amp1(i) = [tanyadata.experiment.cells(1).sweeps(i).UPamp];
            UP_dur1(i) = [tanyadata.experiment.cells(1).sweeps(i).UPdur];
        else if tanyadata.experiment.cells(1).sweeps(i).analyze ==0;
                stim1(i) = NaN;
                APs1(i) = NaN;
                UP_amp1(i) = NaN;
                UP_dur1(i) = NaN;
            end
            varargout(1) = {[]};
            varargout(2) = {[]};
            varargout(3) = {[]};
            varargout(4) = {[]};
            varargout(5) = {[]};
            varargout(6) = {[]};
            varargout(7) = {[]};
            varargout(8) = {[]};
        end
        if length(tanyadata.experiment.cells) == 2 & tanyadata.experiment.cells(2).sweeps(i).analyze ==1;
            if tanyadata.experiment.cells(2).sweeps(i).stim == 0;
                APs2(i) = [tanyadata.experiment.cells(2).sweeps(i).aps];
            end
            if tanyadata.experiment.cells(2).sweeps(i).stim == 1 & isnan([tanyadata.experiment.cells(2).sweeps(i).totalaps]) == 1;
                APs2(i) = [tanyadata.experiment.cells(2).sweeps(i).stimaps];
            else if tanyadata.experiment.cells(2).sweeps(i).stim == 1 & ~isempty([tanyadata.experiment.cells(2).sweeps(i).totalaps])
                    APs2(i) = [tanyadata.experiment.cells(2).sweeps(i).totalaps];
                end
            end
            UP_amp2(i) = [tanyadata.experiment.cells(2).sweeps(i).UPamp];
            UP_dur2(i) = [tanyadata.experiment.cells(2).sweeps(i).UPdur];
        elseif length(tanyadata.experiment.cells) == 2 & tanyadata.experiment.cells(2).sweeps(i).analyze ==0;
            stim2(i) = [NaN];
            APs2(i) = [NaN];
            UP_amp2(i) = [NaN];
            UP_dur2(i) = [NaN];
        end
        varargout(5) = {[]};
        varargout(6) = {[]};
        varargout(7) = {[]};
        varargout(8) = {[]};
    end
    if length(tanyadata.experiment.cells) == 3 & tanyadata.experiment.cells(2).sweeps(i).analyze ==1;
        if tanyadata.experiment.cells(3).sweeps(i).stim == 0
            APs3(i) = [tanyadata.experiment.cells(3).sweeps(i).aps];
        end
        if tanyadata.experiment.cells(3).sweeps(i).stim == 1 & isnan([tanyadata.experiment.cells(3).sweeps(i).totalaps]) == 1;
            APs3(i) = [tanyadata.experiment.cells(3).sweeps(i).stimaps];
        else if tanyadata.experiment.cells(3).sweeps(i).stim == 1 & ~isempty([tanyadata.experiment.cells(3).sweeps(i).totalaps])
                APs3(i) = [tanyadata.experiment.cells(3).sweeps(i).totalaps];
            end
        end
        UP_amp3(i) = [tanyadata.experiment.cells(3).sweeps(i).UPamp];
        UP_dur3(i) = [tanyadata.experiment.cells(3).sweeps(i).UPdur];
    elseif length(tanyadata.experiment.cells) == 3 & tanyadata.experiment.cells(2).sweeps(i).analyze == 0;
        stim3(i) = NaN;
        APs3(i) = NaN;
        UP_amp3(i) = NaN;
        UP_dur3(i) = NaN;
    end
end
% outputs
varargout(1) = {stim2};
varargout(2) = {APs2};
varargout(3) = {UP_amp2};
varargout(4) = {UP_dur2};
varargout(5) = {stim3};
varargout(6) = {APs3};
varargout(7) = {UP_amp3};
varargout(8) = {UP_dur3};
end


