function export_active_cell_traces(handles);
% function export_active_cell_traces(handles);
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

[orderSelection,ok] = listdlg('ListString',orderlist2,...
    'SelectionMode','single','InitialValue',defaultOrder,...
    'PromptString', 'Export traces in which cell order?',...
    'Name','Chose Order');
if ~ok
    return
end
order = handles.app.experiment.contourOrder(orderSelection).order;

%% Extract traces...keep only those from active cells

traces = partition.cleanContourTraces;
traces = traces(order,:);

actives = handles.app.data.activeCells;

indices = handles.app.experiment.contourOrder(orderSelection).index;
actives = indices(actives);

traces = traces(actives,:);

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