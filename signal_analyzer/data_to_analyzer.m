function data_to_analyzer(analyzerFigure, handles, activitymtx, onsmtx, chunkname);

warning off

analyzerHandles = guidata(analyzerFigure);
analyzerHandles.data.activitymtxs{end+1} = activitymtx;
analyzerHandles.data.onsmtxs{end+1} = onsmtx;
analyzerHandles.data.chunkNames{end+1} = chunkname;
if isempty (analyzerHandles.data.contours)
    contours = handles.app.experiment.contourLines;
    analyzerHandles.data.contours = handles.app.experiment.contourLines;
    analyzerHandles.data.imageSize = size(handles.app.experiment.Image(1).image);
    analyzerHandles.data.nullContours = zeros(1,size(contours,2));
    for cidx = 1:size(contours,2);
        analyzerHandles.handles.axesChildren.contours(cidx) = patch...%note patch, so can fill
            (contours{cidx}(:,1),contours{cidx}(:,2),...
            'red',...
            'edgecolor','black',...
            'parent',analyzerHandles.handles.axes);
        set(analyzerHandles.handles.axesChildren.contours(cidx),...
            'facecolor','none')
    
        %go thru each contour and record whether it's null
        if size(contours{cidx},1) == 10 && size(contours{cidx},2)==2;
            if contours{cidx} == (Inf*ones(10,2));%if a dummy out of frame coordinate
                analyzerHandles.data.nullContours(cidx) = 1;
            end
        end
    end
    
    axis ij
    axis equal
    xlim([-5 analyzerHandles.data.imageSize(2)+5]);
    ylim([-5 analyzerHandles.data.imageSize(1)+5]);
    analyzerHandles.handles.axesChildren.frameOutline = line...
        ([0 0 analyzerHandles.data.imageSize(2) analyzerHandles.data.imageSize(2) 0],...
        [0 analyzerHandles.data.imageSize(1) analyzerHandles.data.imageSize(1) 0 0],...
        'color','black');
end

textboxtext = [num2str(length(analyzerHandles.data.contours)),' contours.  ',...
    num2str(sum(logical(sum(onsmtx,2)))),' active cells.'];

set(analyzerHandles.handles.textBox,'string',textboxtext);
set(analyzerHandles.handles.chunksListBox,...
    'string',analyzerHandles.data.chunkNames);
set(analyzerHandles.handles.chunksListBox,...
    'value',length(analyzerHandles.data.chunkNames));
guidata(analyzerHandles.handles.figure, analyzerHandles);


%% execute callback of newly selected chunk(s)... make gui look right
%do this after reassigning guidata so that data is not mixed wrong
callbackfunc = get(analyzerHandles.handles.chunksListBox,'callback');
feval(callbackfunc,analyzerHandles.handles.figure,[])