function handles = ct_crosscov_signals(handles)
% function handles=detect_signals(handles)
%Evaluates signals in traces using a signal detector from the signal
%detectors folder.  Takes the signal onsets, offset and any signal detector
%programer's parameters, as well as the name of the signal detector used
%and puts them into handles.app.experiment for posterity.
numcells=size(handles.app.experiment.contours,2);
cellnum = handles.app.data.currentCellId;
cl = handles.app.experiment.regions.cl;
traces = handles.app.experiment.traces;
halo_traces = handles.app.experiment.haloTraces;
time_res = handles.app.experiment.timeRes;
cridx = handles.app.experiment.contourRegionIdx;
contours = handles.app.experiment.contours;
tidx = 1;
size(traces);
size(halo_traces);
tracetime = time_res*(0:size(traces,2)-1);
max(tracetime);
i = handles.app.data.activeCells;    
if (length(i) > 1)
    warndlg(['There are multiple active cells.  Using contour ' num2str(i(1)) '.']);
end
i = i(1);
nidx = find([handles.app.experiment.contours.id] == i);
pidx = handles.app.data.currentPartitionIdx;
p = handles.app.experiment.partitions(pidx);
clean_traceA = p.cleanContourTraces(nidx,:);
cnt = handles.guiOptions.face.cnt;
axes(handles.guiOptions.face.clickMap);
lengthtrace=length(clean_traceA);
for i=1:numcells,
    nidx = find([handles.app.experiment.contours.id] == i);
    clean_traceB = p.cleanContourTraces(nidx,:);
    clean_traceAcovB=xcov(clean_traceA,clean_traceB,'coef');
   handles.app.experiment.covmaxvalues(i)=max(clean_traceAcovB);
end;
    newcolor=handles.app.experiment.covmaxvalues;
    newcolor(handles.app.data.activeCells)=mean(newcolor);
    newcolor=newcolor-min(newcolor)+0.01;
    newcolor=newcolor/(max(newcolor)+0.01);
for i=1:numcells,
    handles.app.experiment.contours(i).color=[newcolor(i),newcolor(i),newcolor(i)];
    set(cnt(i), 'facecolor', handles.app.experiment.contours(i).color);
end;