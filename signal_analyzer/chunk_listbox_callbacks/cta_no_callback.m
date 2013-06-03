function cta_no_callback(obj,ev);

%% get basic data
warning off
analyzerHandles = guidata(obj);

%% calculate total number of cells on across all selected chuks, for text box display
chunknums = get(analyzerHandles.handles.chunksListBox,'Value');
tempchunks = analyzerHandles.data.onsmtxs(chunknums);
for chidx = 1:length(chunknums);
    chunks(:,chidx) = logical(sum(tempchunks{chidx},2));
end
chunks = double(chunks);
chunks = sum(chunks,2);


%% update textbox
textboxtext = [num2str(length(analyzerHandles.data.contours)),' contours.  ',...
    num2str(sum(logical(sum(chunks,2)))),' active cells.'];
set(analyzerHandles.handles.textBox,'string',textboxtext);