function [result, rastermap, options] = ...
    ct_crosscov_to_contour(handles, ridxs, rastermap, regions, options)

% Evaluates signals in traces using a signal detector from the signal
% detectors folder.  Takes the signal onsets, offset and any signal
% detector programer's parameters, as well as the name of the signal
% detector used.

% Unlike the clustering, the ordering routines must work on all
% contours, including those that have been eliminated from
% clustering.  This is true because the concept of ordering extends
% to all kinds of viewing such as coloration of the clickmap and
% trace plot as well.

% Updated 7/29/09 -MD

num_contours = size(rastermap,1);
trace_len = size(rastermap, 2);
tidx = 1;

% There are two highlighting modes.  One where there are many
% (activeCells) and one where there is only one. (currentCellId).
if (~handles.app.data.useContourSlider)
    i = handles.app.data.activeCells;    
    if (length(i) < 1)
	errordlg('There must be one active cell to compare to.');
	return;
    end
    if (length(i) > 1)
	warndlg(['There are multiple active cells.  Using contour ' num2str(i(1)) '.']);
    end
    i = i(1);
else
    i = handles.app.data.currentCellId;
end
    
clean_traceA = rastermap(i,:);

for nidx = 1:num_contours
    clean_traceB = rastermap(nidx,:);
    %
    % We don't want to subtract the mean since the traces should
    % have the baseline set to zero.
    clean_traceAcovB = xcorr(clean_traceA, clean_traceB, 'coef');    
    crosscov_values(nidx) = max(clean_traceAcovB);
end

result = crosscov_values;

