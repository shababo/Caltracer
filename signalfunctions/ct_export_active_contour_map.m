function handles = ct_export_active_contour_map(handles);
% function handles = ct_export_active_contour_map(handles);
% Creates a figure which has just a set of contours, the ones representing
% active cells are filled in with red, while the inactive cells have no
% filling.  The coordinates of the contours and which cells are active are
% put into the userdata of the figure.

f = figure;
axis;
% axis square
axis ij
hold on

activecells = handles.app.data.activeCells;
contoursstruct = handles.app.experiment.contours;
for cidx = 1:size(contoursstruct,2);
    contours{cidx} = contoursstruct(cidx).contour;
%     contours{cidx}(end+1,:) = contours{cidx}(end,:);
    plot(contours{cidx}(:,1),contours{cidx}(:,2),'k');
    if ~isempty(find(activecells == cidx))
        patch(contours{cidx}(:,1),contours{cidx}(:,2),'red','edgecolor','red');
    end
end
xlim([1 size(handles.app.experiment.Image.image,2)]);
ylim([1 size(handles.app.experiment.Image.image,1)]);
axis off
name = get(handles.fig,'Name');
name = name(8:end);
name = ['Active cells in ',name];
set(f,'Name',name);
title('Note: ''contours'', ''ons'' and ''active cells'' in figure userdata')

ons = zeros(1,cidx);
ons(activecells) = 1;
usefuldata.contours = contours;
usefuldata.ons = ons;
usefuldata.activecells = activecells;
set(f,'userdata',usefuldata);