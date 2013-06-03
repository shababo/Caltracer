function [handles] = manual_contour_delete(handles)
while uiget(handles, 'detectcells', 'btdelete', 'value')==1
% Delete a contour by selecting it.

%ridx = handles.app.data.currentRegionIdx;
maskidx = handles.app.data.currentMaskIdx;

% If "Circle" is selected.
if (uiget(handles, 'detectcells', 'shaperad1', 'value') == 1)
    x = [];
    y = [];
    %Let the user input one click which defines the contour selected.
    [x(1) y(1) butt] = ginput(1);
    % If the user clicks any button other than left, return.
    if (butt > 1)
        handles = uiset(handles,'detectcells','all','enable','on');
        handles = uiset(handles,'filterimage','all','enable','on');
        return;
    end   
    newcn = [x y];
    
% If "Freehand" is selected.    
elseif (uiget(handles, 'detectcells', 'shaperad2', 'value') == 1)	
     freehand=imfreehand;
     newcn = wait(freehand);  
     delete(freehand); 
else
% If "Custom" is selected.
[BW,xi,yi] = roipoly;
% Remove the last entry to avoid doubling of first point.
xi = xi(1:length(xi) - 1);
yi = yi(1:length(yi) - 1);
newcn = [xi,yi];

end

if isempty(newcn)
    break;
end

nregions = handles.app.experiment.numRegions;

% If only one click occured (ie. circle was selected).
if (length(newcn) == 2)			
    for r = 1:nregions
        didx = 1;
        cn = handles.app.experiment.regions.contours{r}{maskidx};
        ncontours = length(cn);
        deleted_contours{r} = [];
        for c = 1:ncontours
            % Find any contrours which contained the point selected and
            % mark them.
            if (find(inpolygon(newcn(1), newcn(2), cn{c}(:,1), cn{c}(:,2))))
                deleted_contours{r}(didx) = c;
                didx = didx + 1;
            end
        end
    end
% If numerous clicks occured (ie. custom region was defined).
else				
    for r = 1:nregions
        didx = 1;
        cn = handles.app.experiment.regions.contours{r}{maskidx};
        ncontours = length(cn);
        deleted_contours{r} = [];
        % For each contour.
        for c = 1:ncontours
            ps = round(cn{c});	
            [cmaskx cmasky] = meshgrid(min(ps(:,1)):max(ps(:,1)), ...
                           min(ps(:,2)):max(ps(:,2)));
            pix_in_con = inpolygon(cmaskx, cmasky, newcn(:,1), newcn(:,2));
            npix_in_con = size(pix_in_con,1)*size(pix_in_con,2);
            % Find and mark any contours which overlap with the custom shape.
            if (length(find(pix_in_con)) > 0.5*npix_in_con)
                deleted_contours{r}(didx) = c;
                didx = didx + 1;
            end
        end
    end
end

    % Now put it back together.
    for r = 1:nregions
        % If no contours were selected for deletion.
        if (isempty(deleted_contours{r}))
            continue;
        end
        cn = handles.app.experiment.regions.contours{r}{maskidx};
        ncontours = length(cn);
        saved_contour_idxs = setdiff(1:ncontours, deleted_contours{r});
        nsaved_contours = length(saved_contour_idxs);
        % Replace handles with only contours that were not marked for deletion.
        handles.app.experiment.regions.contours{r}{maskidx} = cell(1,nsaved_contours);
        for c = 1:nsaved_contours
        handles.app.experiment.regions.contours{r}{maskidx}{c} = ...
            cn{saved_contour_idxs(c)};
        end
    end

    % Make sure the colors are correct in case the addition is in a specific
    % mask.
    nmaps = length(handles.app.experiment.Image);
    mapcolors = hsv(nmaps);
    handles = draw_cell_contours(handles, ...
                     'ridx','all', ...
                     'color', mapcolors(maskidx,:));
%                  pause(2)
end 
handles = uiset(handles,'detectcells','btdelete','value',0);