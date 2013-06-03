function cta_n_random_actives(analyzerHandles)

%get just one chunk
chunknum = get(analyzerHandles.handles.chunksListBox,'value');
if length(chunknum) ~= 1
    errormsg('Must have exactly one chunk selected');
    return
end
chunk = analyzerHandles.data.activitymtxs{chunknum};
actives = sum(chunk,2)';
notnullcells = ~analyzerHandles.data.nullContours;
actives = actives.*notnullcells;
actives = find(actives);



numcells = inputdlg('Enter how many active cells to randomly select?','Number of Actives',1,{'10'});
if isempty(numcells);
    return
end
numcells = str2double(numcells);

[trash,indices]=sort(rand([1,length(actives)]));
indices = indices(1:numcells);
newactives = actives(indices);
excluded  = setdiff(actives,newactives);

newactiveschunk = zeros(size(chunk));
tempvar = chunk(newactives,:);
for cidx = 1:size(tempvar,1);
    newactiveschunk(newactives(cidx),:) = tempvar(cidx,:);
end
newactivesonschunk = ct_keepfirstonframe(newactiveschunk')';
newactivesname = [num2str(numcells),'RandomFrom_',analyzerHandles.data.chunkNames{chunknum}];

excludedchunk = zeros(size(chunk));
tempvar = chunk(excluded,:);
for cidx = 1:size(tempvar,1);
    excludedchunk(excluded(cidx),:) = tempvar(cidx,:);
end
excludedonschunk = ct_keepfirstonframe(excludedchunk')';
excludedname = [num2str(length(excluded)),'ExcludedFrom_',analyzerHandles.data.chunkNames{chunknum}];


analyzerHandles.data.activitymtxs{end+1} = newactiveschunk;
analyzerHandles.data.onsmtxs{end+1} = newactivesonschunk;
analyzerHandles.data.chunkNames{end+1} = newactivesname;

analyzerHandles.data.activitymtxs{end+1} = excludedchunk;
analyzerHandles.data.onsmtxs{end+1} = excludedonschunk;
analyzerHandles.data.chunkNames{end+1} = excludedname;
%assign chunks with names to data and list


%% update gui with new chunk info
newchunk = length(analyzerHandles.data.chunkNames)-1;
textboxtext = [num2str(length(analyzerHandles.data.contours)),' contours.  ',...
    num2str(sum(logical(sum(analyzerHandles.data.onsmtxs{newchunk},2)))),' active cells.'];
set(analyzerHandles.handles.textBox,'string',textboxtext);
set(analyzerHandles.handles.chunksListBox,...
    'string',analyzerHandles.data.chunkNames);
set(analyzerHandles.handles.chunksListBox,...
    'value',newchunk);
guidata(analyzerHandles.handles.figure, analyzerHandles);
%% execute callback of newly selected chunk(s)... make gui look right
%do this after reassigning guidata so that data is not mixed wrong
callbackfunc = get(analyzerHandles.handles.chunksListBox,'callback');
feval(callbackfunc,analyzerHandles.handles.figure,[])