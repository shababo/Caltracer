function analyzer_import_contours(obj,ev);

analyzerHandles = guidata(obj);

[FileName,PathName] = uigetfile('.mat','Choose a contours file');
if FileName == 0 & PathName == 0
    return
end

s = load([PathName,'\',FileName]);
fie = fieldnames(s);
if length(fie) == 2 && strcmp(fie{1},'E') && strcmp(fie{2},'A')
    analyzerHandles.data.contours = s.E.contourLines;
    analyzerHandles.data.imageSize = size(s.E.tcImage(1).image);
else 
    analyzerHandles.data.contours = s.outputcontours;
    analyzerHandles.data.imageSize = s.imagesize;
end

if ~isempty(analyzerHandles.handles.axesChildren);
%delete everything in axes
    fie = fieldnames(analyzerHandles.handles.axesChildren);
    for fidx = 1:length(fie);
        eval(['delete(analyzerHandles.handles.axesChildren.',fie{fidx},');'])
    end
% 
%     clear their handles
    analyzerHandles.handles.axesChildren = [];
end


contours = analyzerHandles.data.contours;
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
axis off
axis equal
xlim([-5 analyzerHandles.data.imageSize(2)+5]);
ylim([-5 analyzerHandles.data.imageSize(1)+5]);
analyzerHandles.handles.axesChildren.frameOutline = line...
    ([0 0 analyzerHandles.data.imageSize(2) analyzerHandles.data.imageSize(2) 0],...
    [0 analyzerHandles.data.imageSize(1) analyzerHandles.data.imageSize(1) 0 0],...
    'color','black');

guidata(analyzerHandles.handles.figure, analyzerHandles);

