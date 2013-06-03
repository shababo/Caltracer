function handles = find_bad_cells(handles)
% Find and highlight the cells that don't look like circles.  This
% is done by computing pi and determining how far the contour is
% from this value.

ridx = handles.app.data.currentRegionIdx;
maskidx = handles.app.data.currentMaskIdx;

pi_limit = str2num(uiget(handles, 'detectcells', 'txpilim', 'string'));
handles.guiOptions.face.piLimit(ridx) = pi_limit;
cn = handles.app.experiment.regions.contours{ridx}{maskidx};
ncontours = length(handles.app.experiment.regions.contours{ridx}{maskidx});
for c = 1:ncontours
    cnc = cn{c};
    p = sum(sqrt(sum((cnc([2:end 1],:)-cnc(:,:)).^2,2)));
    ar = polyarea(cnc(:,1),cnc(:,2));
    api = p^2/(4*ar);
    if (api > pi_limit)
        set(handles.guiOptions.face.handl{ridx}{maskidx}(c), 'linewidth', 2);
    else
        set(handles.guiOptions.face.handl{ridx}{maskidx}(c), 'linewidth', 1);
    end
end
refresh;
