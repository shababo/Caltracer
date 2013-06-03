function [sumdata] = extractaps(tanyadata);


num_cellsactive = []; % if running online remove
aps_cells = [];
stim = [];
up_amp = [];
up_dur = [];


% first create vector with num of cells active- since this is the same for
% all cells within a given sweep, will just use the first cell to construct
% the matrix
% note: "num_cellsactive" is the number of cells in the imaging data that
% were active during a given trial- this data is imported manually from
% CalTracer and/or a saved signal analyzer window

for k = 1: length(tanyadata.experiment.cells(1).sweeps)
    num_cellsactive(k) = tanyadata.experiment.cells(1).sweeps(k).NUMcellsACT;
end

% next create all other vectors, aps_cell, up_amp, up_dur and finally a summary vector sumdata
% with all variables.

for c = 1: length(tanyadata.experiment.cells)
    for k = 1: length(tanyadata.experiment.cells(1).sweeps)
        if tanyadata.experiment.cells(c).sweeps(k).analyze == 0
            aps_cells(c,k) = NaN;
            stim(c,k) = NaN;
            up_amp(c,k) = NaN;
            up_dur(c,k)= NaN;
        else if tanyadata.experiment.cells(c).sweeps(k).analyze == 1
                stim(c,k) = tanyadata.experiment.cells(c).sweeps(k).stim;
                if tanyadata.experiment.cells(c).sweeps(k).numupstates == 0
                    up_amp(c,k) = NaN;
                    up_dur(c,k) = NaN;
                else if isnan([tanyadata.experiment.cells(c).sweeps(k).numupstates]) == 1;
                        up_amp(c,k) = NaN;
                        up_dur(c,k) = NaN;
                    else
                        up_amp(c,k) = ([tanyadata.experiment.cells(c).sweeps(k).UPamp]);
                        up_dur(c,k) = ([tanyadata.experiment.cells(c).sweeps(k).UPdur]);
                    end
                end
                if tanyadata.experiment.cells(c).sweeps(k).stim == 0
                    aps_cells(c,k) = ([tanyadata.experiment.cells(c).sweeps(k).aps]);
                end
                if tanyadata.experiment.cells(c).sweeps(k).stim == 1
                    aps_cells(c,k) = ([tanyadata.experiment.cells(c).sweeps(k).stimaps]);
                    if isnan([tanyadata.experiment.cells(c).sweeps(k).totalaps]) == 0
                        aps_cells(c,k) = ([tanyadata.experiment.cells(c).sweeps(k).totalaps]);
                    end
                end
            end
        end
    end
    sumdata = cat(1, num_cellsactive, stim, aps_cells, up_amp, up_dur); %if running online should remove num_cellsactive as won't have that data yet
end
end







