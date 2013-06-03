function delete_chunks(obj,ev);

analyzerHandles = guidata(obj);

chunknum = get(analyzerHandles.handles.chunksListBox,'value');
liststring = get(analyzerHandles.handles.chunksListBox,'String');
if length(chunknum) == length(liststring); %if tring to delete all chunks
    errordlg('Can''t delete last chunks');
    return
end
for chidx = length(chunknum):-1:1;
    ch = chunknum(chidx);
    analyzerHandles.data.activitymtxs(ch) = [];
    analyzerHandles.data.onsmtxs(ch) = [];
    analyzerHandles.data.chunkNames(ch) = [];
    liststring(ch) = [];
end
set(analyzerHandles.handles.chunksListBox,'String',liststring);

%% taking care of making things look right after deletion
%don't let selection be below the bottom item in the list
if max(chunknum) > length(liststring);
    set(analyzerHandles.handles.chunksListBox,...
        'value',length(liststring));%set to last chunk;
end

guidata(analyzerHandles.handles.figure, analyzerHandles);


%% execute callback of newly selected chunk(s)... make gui look right
%do this after reassigning guidata so that data is not mixed wrong
callbackfunc = get(analyzerHandles.handles.chunksListBox,'callback');
feval(callbackfunc,obj,ev)