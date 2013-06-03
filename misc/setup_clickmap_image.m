function handles = setup_clickmap_image(handles)
% Setup the click map image axis.
maskidx = get_mask_idx(handles, 'Image');
ncontours = length(handles.app.experiment.contours);
contourLines = handles.app.experiment.contourLines;
ratio = handles.app.experiment.Image(maskidx).nY/handles.app.experiment.Image(maskidx).nX;
if ratio <= 1
handles.guiOptions.face.clickMap = ...
    axes('position', [0.00 0.40+(0.50-ratio*0.50) 0.50 ratio*0.55]);
else 
    handles.guiOptions.face.clickMap = ...
        axes('position',[0.00 0.4 0.5 260*(1/handles.app.experiment.Image(maskidx).nY)]);
end
h = imagesc(handles.app.experiment.Image(maskidx).image);
colormap(handles.app.experiment.Image(maskidx).colorMap);
title('Cluster Map');

% Create the patches over the contours.  These ids set in UserData
% always stay the same. -DCS:2005/06/03
hold on;
cl = handles.app.experiment.regions.cl;
cridx = handles.app.experiment.contourRegionIdx;
cnt = zeros(1,ncontours);
for c = 1:ncontours
    cnt(c) = patch(contourLines{c}([1:end 1],1), contourLines{c}([1:end 1],2),[0 0 0]);
    set(cnt(c), 'edgecolor', cl(cridx(c),:));
    set(cnt(c), 'UserData', c);
    set(cnt(c), 'Clipping', 'off');
    set(cnt(c), 'ButtonDownFcn','caltracer2(''contour_buttondown_callback'',gcbo,guidata(gcbo))');

end
handles.guiOptions.face.cnt = cnt;
% Plot the clickmap.  Could be in another function... -DCS:2005/03/23
axis equal;
imagesize = size(handles.app.experiment.Image(maskidx).image);
xlim([0 imagesize(2)]);
ylim([0 imagesize(1)]);
set(handles.guiOptions.face.clickMap, 'ydir','reverse');
box on;
set(handles.guiOptions.face.clickMap, 'color',[0 0 0]);
set(handles.guiOptions.face.clickMap, 'xtick',[],'ytick',[]);
%
