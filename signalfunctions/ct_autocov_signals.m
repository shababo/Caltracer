function handles = ct_autocov_signals(handles)
% function handles=detect_signals(handles)
%Evaluates signals in traces using a signal detector from the signal
%detectors folder.  Takes the signal onsets, offset and any signal detector
%programer's parameters, as well as the name of the signal detector used
%and puts them into handles.app.experiment for posterity.
numcells=size(handles.app.experiment.contours,2)
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
%i = handles.app.data.activeCells-1;    
%nidx = find([handles.app.experiment.contours.id] == i);
cnt = handles.guiOptions.face.cnt;
axes(handles.guiOptions.face.clickMap);
lengthtrace=length(clean_traceA)
stimfreq=1/6;
lengthfreq=ceil((1/time_res)/stimfreq)
nhfilt = 300;		% filter length
hpass = .01;		% high pass in Hz.
Fs = 1/time_res;
normfreq_hpass = hpass/(Fs/2)	% 1 corresponds to Nyquist rate.
hfilt = fir1(nhfilt/2, normfreq_hpass, 'high');
%xfilt = filtfilt(hfilt, 1, x')';
for i=1:numcells,
    nidx = find([handles.app.experiment.contours.id] == i);
    clean_traceA = p.cleanContourTraces(nidx,:);
    clean_traceAautocovA=xcov(clean_traceA,clean_traceA,'coef');
    newautotrace=clean_traceAautocovA(ceil(0.25*length(clean_traceAautocovA)):...
        (length(clean_traceAautocovA)-ceil(0.25*length(clean_traceAautocovA))));
    autotrace=xcov(newautotrace,newautotrace,'coef');
    autotrace = filtfilt(hfilt, 1, autotrace);
    handles.app.experiment.autocovmaxvalues(i)=max(autotrace((lengthtrace+lengthfreq/2):(lengthtrace+lengthfreq+lengthfreq/2)));
    handles.app.experiment.autocovmaxvalues(i)=handles.app.experiment.autocovmaxvalues(i)-...
        min(autotrace((lengthtrace+lengthfreq*1):(lengthtrace+lengthfreq*2)));
    xxx=max(autotrace((lengthtrace+lengthfreq*1+lengthfreq/2):(lengthtrace+lengthfreq*2+lengthfreq/2)));
    xxx=xxx-min(autotrace((lengthtrace+lengthfreq*2):(lengthtrace+lengthfreq*3)));
    yyy=max(autotrace((lengthtrace+lengthfreq*2+lengthfreq/2):(lengthtrace+lengthfreq*3+lengthfreq/2)));
    yyy=yyy-min(autotrace((lengthtrace+lengthfreq*3):(lengthtrace+lengthfreq*4)));
    handles.app.experiment.autocovmaxvalues(i)=(handles.app.experiment.autocovmaxvalues(i)+xxx+yyy)/2;
    %handles.app.experiment.autocovmaxvalues(i)=handles.app.experiment.autocovmaxvalues(i)/2;
        
    
    testing=handles.app.experiment.autocovmaxvalues(i);
   % if (i == handles.app.data.activeCells)
   %     handles.app.experiment.covmaxvalues(i)=handles.app.experiment.covmaxvalues(i-1);
   % end;
  %  handles.app.experiment.covmaxvalues(i)=max(clean_traceAcovB((length(clean_traceAc
  %  ovB)-...
  %  length(clean_traceA)-0):(length(clean_traceAcovB)-length(clean_traceA)
  %  +0)));
  
  %covmaxval(i)=handles.app.experiment.covmaxvalues(i);
end;
    newcolor=handles.app.experiment.autocovmaxvalues;
    newcolor(handles.app.data.activeCells)=mean(newcolor);
    newcolor=newcolor-min(newcolor)+0.01;
    newcolor=newcolor/(max(newcolor)+0.01);
    newcolor;
for i=1:numcells,
    handles.app.experiment.contours(i).color=[newcolor(i),newcolor(i),newcolor(i)];
    set(cnt(i), 'facecolor', handles.app.experiment.contours(i).color);
end;
%fade = 0.65*ones(1,3)
%handles.app.experiment.contours(i).color
%cnt = handles.guiOptions.face.cnt;
%set(cnt(116), 'facecolor', handles.app.experiment.contours(116).color.*fade);
%covmaxval(116)=-100;
%maxloc=find(covmaxval==max(covmaxval))
%handles.app.experiment