function handles = display_zstack_image(handles)
% function display_zstack_image(handles)
% Display the zstack image in the large axis in the middle of the
% GUI.  This is largely used for creating and handling contours.

% Maskidx is the mask that is currently being processed.
maskidx = handles.app.data.currentMaskIdx;
lidx = get_label_idx(handles, 'image');
axes(handles.uigroup{lidx}.imgax);
if isfield(handles.app.data,'mainImage');
    handles.app.data = rmfield(handles.app.data,'mainImage');
end
handles.app.data.mainImage = imagesc(handles.app.experiment.Image(maskidx).image);
hold on;
set(gca, 'xtick', [], 'ytick', []);
axis equal;
axis tight;
box on;
colormap gray;
handles.app.experiment.ImageTitle = title(texlabel(handles.app.experiment.Image(maskidx).title, 'literal'));

if ~isempty(handles.app.experiment.regions.bhand)
    c = get(handles.uigroup{lidx}.imgax, 'Children');    
    cch = find(strcmpi(get(c, 'Tag'), 'cellcontour'));
    delete(c(cch));
    
    %%% Delete the handles from the array. -DCS:2005/04/04
    c = get(handles.uigroup{lidx}.imgax, 'Children');
    ctag = get(c, 'Tag');
    rbh_idx = find(strcmpi(ctag, 'regionborder'));
    not_rbh_idx = find(~strcmpi(ctag, 'regionborder')); 
    newc = [c(rbh_idx); c(not_rbh_idx)];
    set(handles.uigroup{lidx}.imgax, 'Children', newc);
end
