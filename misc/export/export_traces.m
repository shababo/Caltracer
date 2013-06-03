function export_traces(handles);

% function export_traces(handles);

% Allows the user to export traces data from CalTracer either into the

% workspace or outside of matlab.



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

%% ask order
defaultOrder =  partition.contourOrderId;
orderlist = 1:size(handles.app.experiment.contourOrder,2);
for oidx = 1:size(orderlist,2);
    orderlist2{oidx} = num2str(orderlist(oidx));
end

[order,ok] = listdlg('ListString',orderlist2,...
    'SelectionMode','single','InitialValue',defaultOrder,...
    'PromptString', 'Export traces in which cell order?',...
    'Name','Chose Order');

if ~ok
    return
end

order = handles.app.experiment.contourOrder(order).order;



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
periodplace = strfind(moviename,'.');
totalname = ['Traces_',moviename(1:periodplace-1)];

% Check for spaces in movie name and remove them (otherwise it will throw an error).
temp = totalname==' ';
if max(temp)>0
    warning (['Spaces from ' totalname ' were removed to avoid errors.']);
    totalname(totalname==' ')='_';
end
tempdash = totalname=='-';
if max(tempdash)>0
    warning (['Dashes from ' totalname ' were removed to avoid errors.']);
    totalname(totalname=='-')='_';
end

switch exporttype
    case 'Matrix in base workspace'
        answer = inputdlg('Choose name for output matrix (Cannot begin with a digit)',...
            'Output name',1,{totalname});
        assignin ('base',answer{1},traces);
    case 'Matrix in .mat file'
        eval([totalname,' = traces;'])
        [FileName,PathName] = uiputfile([totalname,'.mat'],'Choose mat file name');
        if isempty(FileName) & isempty(PathName);
            return
        end
        save([PathName,'\',FileName],totalname)
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