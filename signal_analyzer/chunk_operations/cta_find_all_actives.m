function cta_find_all_actives(analyzerHandles)

warning off
notnullcells = ~analyzerHandles.data.nullContours;
newactivesname = ['AllActivesFrom_'];

%get all chunks
chunknum = get(analyzerHandles.handles.chunksListBox,'value');
for chidx = 1:length(chunknum);
    chunks{chidx} = analyzerHandles.data.activitymtxs{chunknum(chidx)};
    actives(:,chidx) = logical(sum(chunks{chidx},2));
    actives(:,chidx) = actives(:,chidx).*notnullcells';
    newactivesname = [newactivesname,analyzerHandles.data.chunkNames{chunknum(chidx)}];
    if chidx<length(chunknum);
        newactivesname = [newactivesname,'_&_'];
    end
end       

actives = logical(sum(actives,2));


analyzerHandles.data.activitymtxs{end+1} = actives;
analyzerHandles.data.onsmtxs{end+1} = actives;
analyzerHandles.data.chunkNames{end+1} = newactivesname;


%% update gui with new chunk info
newchunk = length(analyzerHandles.data.chunkNames);
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