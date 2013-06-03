function cta_find_core(analyzerHandles)

warning off
notnullcells = ~analyzerHandles.data.nullContours;
corename = ['CoreFrom_'];
noncorename = ['NonCoreFrom_'];
%get all chunks
chunknum = get(analyzerHandles.handles.chunksListBox,'value');
%% find core vs noncore cells
for chidx = 1:length(chunknum);
    chunks{chidx} = analyzerHandles.data.activitymtxs{chunknum(chidx)};
    actives(:,chidx) = sum(chunks{chidx},2);
    actives(:,chidx) = actives(:,chidx).*notnullcells';
    corename = [corename,analyzerHandles.data.chunkNames{chunknum(chidx)}];
    noncorename = [noncorename,analyzerHandles.data.chunkNames{chunknum(chidx)}];
    if chidx<length(chunknum);
        corename = [corename,'_&_'];
        noncorename = [noncorename,'_&_'];
    end
end       

core = logical(prod(actives,2));
noncore = logical(sum(actives,2));
noncore = noncore.*~core;

%% fill in activity for core and noncore.  Activity will be the mean start
%% time in all movies where each cell was active.
coreactivitymtx = zeros(size(analyzerHandles.data.onsmtxs{chunknum(1)}));
noncoreactivitymtx = zeros(size(analyzerHandles.data.onsmtxs{chunknum(1)}));

for chidx = 1:length(chunknum);
    ons = analyzerHandles.data.onsmtxs{chunknum(chidx)};%get times it comes on
    cons = ons;%make a matrix for core cells
    cons(find(noncore),:) = 0;%keep only core cells
    cons = local_keepfirstonevent(cons);%keep the start of the first activation
    [row,col] = find(cons);%row = cellnum, col = framenum
    contimes(row,chidx) = col;%record the start time for that chunk for that cell as col

    ncons = ons;%make a matrix for noncore cells
    ncons(find(core),:) = 0;%keep only noncore cells
    ncons = local_keepfirstonevent(ncons);%keep the start of the first activation
    [row,col] = find(ncons);%row = cellnum, col = framenum
    ncontimes(row,chidx) = col;%record the start time for that chunk for that cell as col
end
for cidx = 1:size(contimes,1);%once all start times for all events in all core cells have been saved
    idxs = find(contimes(cidx,:));
    if ~isempty(idxs);
        start = round(mean(contimes(cidx,idxs)));%get mean start time for movies where the cell fired (not an issue for core of course)
        coreactivitymtx(cidx,start) = 1;
    end
end
for cidx = 1:size(ncontimes,1);%once all start times for all events in all core cells have been saved
    idxs = find(ncontimes(cidx,:));
    if ~isempty(idxs);
        start = round(mean(ncontimes(cidx,idxs)));%get mean start time for movies where the cell fired (not an issue for core of course)
        noncoreactivitymtx(cidx,start) = 1;
    end
end


% for each cell size(ontimes,1)
% start = mean(find(row))
% core activitymtx(row,start) = 1;
% end

analyzerHandles.data.activitymtxs{end+1} = coreactivitymtx;
analyzerHandles.data.onsmtxs{end+1} = coreactivitymtx;
analyzerHandles.data.chunkNames{end+1} = corename;

analyzerHandles.data.activitymtxs{end+1} = noncoreactivitymtx;
analyzerHandles.data.onsmtxs{end+1} = noncoreactivitymtx;
analyzerHandles.data.chunkNames{end+1} = noncorename;


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




%%
function ons=local_keepfirstonevent(ons);
%Eliminates anytime a cell that does not come on in consecutive frames...
%ie if a cell is on then off then on again, it eliminates the 2nd on again.
%It keeps the first event, even if that includes consecutive frames of "on"
%in a row.

summed = cumsum(ons,2);
keep = summed.*ons;
ons(keep~=1) = 0;%keep only first on of first event