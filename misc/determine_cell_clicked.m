function [contouridx,outridx] = determine_cell_clicked(handles,maskidx,ridx,ox,oy)
% Finds which cell was clicked on within multiple regions.  Reports what
% cell was click on (contouridx) and which region the cell was in (outridx).

%Take contours from multiple regions and find which cell was clicked in
%those regions.  Also reports what region that was in with outridx.  Could
%index across regions too... but seems better to have that be fixed so
%cells aren't mixed up.

selcontours = {};
outridx = [];
for rridx = 1:length(ridx);
    selcontours = handles.app.experiment.regions.contours{ridx(rridx)}{maskidx};
    for a = 1:length(selcontours);
        contouridx(a) = inpolygon(ox,oy,selcontours{a}(:,1),selcontours{a}(:,2));
    end
    contouridx = find(contouridx);
    if ~isempty(contouridx);
        if isempty(outridx);
            outridx = ridx(rridx);
            break
        else
            msgbox('Error, multiple cells selected');
            return
        end
    end
end