function export_traces_with_signals(handles);
% function export_traces(handles);
% Allows the user to export traces data from CalTracer either into the
% workspace or outside of matlab.
% Hacked to export signals as well (Adam Packer 20080329)

%% ask which partition to use
for pidx = 1:size(handles.app.experiment.partitions,2)
    parnames{pidx} = handles.app.experiment.partitions(pidx).title;
end
[parnum,ok] = listdlg('ListString',parnames,...
    'SelectionMode','single','Name','Partitions',...
    'PromptString','Trace data from which partition?');
if ok == 0
    return
end

partition = handles.app.experiment.partitions(parnum);
string=parnames(parnum);
token=findstr(string{1},'id');
idstring=string{1}(token:end);

%% always use the first order so it matches the signals
order = 1;
order = handles.app.experiment.contourOrder(order).order;


%% get current signals
didx = handles.app.data.currentDetectionIdx;
onsets=handles.app.experiment.detections(didx).onsets;

%% Extract traces...keep only those in non-killed clusters

nonKilledContours = [];
for cidx = 1:size(partition.clusters,2);
    nonKilledContours = [nonKilledContours partition.clusters(cidx).contours];
end

traces = partition.cleanContourTraces;
traces = traces(order,:);

allContours = 1:size(traces,1);
killedContours = setdiff(allContours,nonKilledContours);
traces(killedContours,:) = [];

%% Ask export options

exportlist = {'Matrix in base workspace';'Matrix in .mat file';'Comma Separated Values (.csv) file';'Tab-delimited file'};
[Selection,ok] = listdlg('ListString',exportlist,...
    'SelectionMode','single', 'PromptString', 'Export traces to where?',...
    'Name','Export');
if ~ok
    return
end
exporttype = exportlist{Selection};

%% Export
moviename = handles.app.experiment.fileName;
% Check for spaces in movie name and remove them (otherwise it will throw an error).
temp = moviename==' ';
if max(temp)>0
    warning (['Spaces from ' moviename ' were removed to avoid errors.']);
    moviename(moviename==' ')='_';
end
tempdash = moviename=='-';
if max(tempdash)>0
    warning (['Dashes from ' moviename ' were removed to avoid errors.']);
    moviename(moviename=='-')='_';
end

periodplace = strfind(moviename,'.');
totalname = ['Traces_',moviename(1:periodplace-1)];
tracename = totalname;
signalname = ['Signals_',moviename(1:periodplace-1)];
switch exporttype
    case 'Matrix in base workspace'
        tanswer = inputdlg('Choose name for output matrix for traces (Cannot begin with a digit)',...
            'Output name',1,{tracename});
        assignin ('base',tanswer{1},traces);
        sanswer = inputdlg('Choose name for output matrix for signals (Cannot begin with a digit)',...
            'Output name',1,{signalname});
        assignin ('base',sanswer{1},onsets);
    case 'Matrix in .mat file'
        [tFileName,tPathName] = uiputfile([tracename,'_',idstring,'.mat'],'Choose mat file name for traces');
        if isempty(tFileName) & isempty(tPathName);
            return
        end
        save([tPathName,'\',tFileName],'traces')
        [sFileName,sPathName] = uiputfile([signalname,'_',idstring,'.mat'],'Choose mat file name for signals');
        if isempty(sFileName) & isempty(sPathName);
            return
        end
        save([sPathName,'\',sFileName],'onsets')
    case 'Comma Separated Values (.csv) file'
        [FileName,PathName] = uiputfile([totalname,'.csv'],'Choose file name');
        if isempty(FileName) & isempty(PathName);
            return
        end
        csvwrite([PathName,'\',FileName], traces)
    case 'Tab-delimited file'
        [FileName,PathName] = uiputfile([totalname],'Choose file name');
        if isempty(FileName) & isempty(PathName);
            return
        end
        dlmwrite([PathName,'\',FileName], traces)
end