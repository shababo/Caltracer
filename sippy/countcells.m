function cells_w_signal = countcells(signals)

% signals is a 1 x n cell where n is the number of contours imported in
% workspace from Caltracer

for c = 1:length(signals)
    sig(c) = ~isempty(signals{c});
end

cells_sig = find(sig);
cells_w_signal = length(cells_sig);
