function cta_color_by_overlap(obj,ev);
% Updated: 10/21/2009 by MD
warning off
analyzerHandles = guidata(obj);

%if something other than contours is currently in the axes, delete it and
%draw contours
if ~isfield(analyzerHandles.handles.axesChildren,'contours') ||...
        ~isfield(analyzerHandles.handles.axesChildren,'frameOutline')
%     delete children
    fie = fieldnames(analyzerHandles.handles.axesChildren);
    for fidx = 1:length(fie);
        eval(['delete(analyzerHandles.handles.axesChildren.',fie{fidx};])
    end
% 
%     clear handles
    analyzerHandles.handles.axesChildren = [];
    contours = analyzerHandles.data.contours;
    for cidx = 1:size(contours,2);
        analyzerHandles.handles.axesChildren.contours(cidx) = patch...%note patch, so can fill
            (contours{cidx}(:,1),contours{cidx}(:,2),...
            'red',...
            'edgecolor','black',...
            'parent',analyzerHandles.handles.axes);
        set(analyzerHandles.handles.axesChildren.contours(cidx),...
            'facecolor','none')
    end
    axis ij
    xlim([-5 analyzerHandles.data.imageSize(2)+5]);
    ylim([-5 analyzerHandles.data.imageSize(1)+5]);
    analyzerHandles.handles.axesChildren.frameOutline = line...
        ([0 0 analyzerHandles.data.imageSize(2) analyzerHandles.data.imageSize(2) 0],...
        [0 analyzerHandles.data.imageSize(1) analyzerHandles.data.imageSize(1) 0 0],...
        'color','black');
end

% gather data and find overlaps
chunknums = get(analyzerHandles.handles.chunksListBox,'Value');
tempchunks = analyzerHandles.data.onsmtxs(chunknums);
for chidx = 1:length(chunknums);
    chunks(:,chidx) = logical(sum(tempchunks{chidx},2));
end
chunks = double(chunks);
overlaps = sum(chunks,2);
cellClusterAssignments = overlaps;
overlapcl=bw_colormap(max(length(chunknums)),'bpr');%get a colorwheel for this number of chunks

%color each cell according to amount of overlap
for cidx = 1:length(overlaps);%for each cell
    if overlaps(cidx) == 0;
        set(analyzerHandles.handles.axesChildren.contours(cidx),...
            'facecolor','none');
    else 
        thiscolor = overlapcl(overlaps(cidx),:);
        set(analyzerHandles.handles.axesChildren.contours(cidx),...
            'facecolor',thiscolor);
    end
end

%% update textbox
denom = min(sum(chunks,1)); %min number of cells on in any single movie
corecells = sum(overlaps == size(chunks,2));
corepercent = 100*corecells/denom;
halfoverlapthresh = max([2 (size(chunks,2)/2)]);
halfoverlapcells = sum(overlaps >= halfoverlapthresh);
halfoverlappercent = 100*halfoverlapcells/denom;

textboxtext = {[num2str(length(analyzerHandles.data.contours)),' contours.  ',...
    num2str(sum(logical(overlaps))),' active cells.'];...
    [num2str(corecells),' core cells (',num2str(corepercent),'%).'];...
    [num2str(halfoverlapcells),' half overlap cells (',num2str(halfoverlappercent),'%).']};
set(analyzerHandles.handles.textBox,'string',textboxtext);