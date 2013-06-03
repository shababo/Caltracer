function handles = draw_movie_cell_contours(handles,varargin)
% function handles = draw_movie_cell_contours(handles, varargin) 
%
% Draw the contours around the cells that are detected in a given
% region, in a given map.  The defaults are the current map and the
% current region.


ridx = handles.app.data.currentRegionIdx;
maskidx = 1;
handles = uiset(handles, 'detectcells', 'bthide', 'String','Hide');
face = handles.guiOptions.face;
nargs = length(varargin);
do_special_color = 0;			% Usually we color by region.
if (nargs > 0)
    for i = 1:2:nargs
        switch varargin{i}
         case 'color'
          do_special_color = 1;
          special_cl = varargin{i+1};
        end
    end
end

for r=1:length(face.handl)
    
    region_cn = handles.app.experiment.regions.contours{r}{maskidx};  
    
    if length(face.handl{r}{1}) ~= length (region_cn) 
    
        %delete all old
        for m=1:length(face.handl{r});
            delete(face.handl{r}{m});		%delete objects.
            face.handl{r}{m} = [];		% kill handles since redoing.
        end
        %draw only from mask 1
        if (isempty(handles.app.experiment.regions.contours{r}))
            continue;
        end
        if (length(handles.app.experiment.regions.contours{r}) < maskidx)
            continue;
        end    

        % Redraw the contours.
        lidx = get_label_idx(handles, 'image');
        axes(handles.uigroup{lidx}.imgax);
        if (do_special_color)
            cl = special_cl;
        else
            cl = [1 0 0];
        end
        for c = 1:length(region_cn)
            h = plot(region_cn{c}([1:end 1],1),...
                 region_cn{c}([1:end 1],2), ...
                     'color', cl, ...
                 'LineWidth', 1, ...
                 'Tag', 'cellcontour');
            set(h, 'UserData', [r maskidx c]);	% region, map, contour
            face.handl{r}{maskidx}(c) = h;
        end
    else
       
        %delete all old
        for m=1:length(face.handl{r});
            delete(face.handl{r}{m});		%delete objects.
            face.handl{r}{m} = [];		% kill handles since redoing.
        end
        %draw only from mask 1
        if (isempty(handles.app.experiment.regions.contours{r}))
            continue;
        end
        if (length(handles.app.experiment.regions.contours{r}) < maskidx)
            continue;
        end    

        % Redraw the contours.
        lidx = get_label_idx(handles, 'image');
        axes(handles.uigroup{lidx}.imgax);
        if (do_special_color)
            cl = special_cl;
        else
            cl = [1 0 0];
        end
        for c = 1:length(region_cn)
            if handles.app.experiment.overlapsInfo{r}{1}(c) ~= 0 % if this is an overlapping contour
                h = plot(region_cn{c}([1:end 1],1),...
                 region_cn{c}([1:end 1],2), ...
                     'color', cl, ...
                 'LineWidth', 1, ...
                 'Tag', 'cellcontour-overlap');
            else
                h = plot(region_cn{c}([1:end 1],1),...
                     region_cn{c}([1:end 1],2), ...
                         'color', cl, ...
                     'LineWidth', 1, ...
                     'Tag', 'cellcontour');
            end
            set(h, 'UserData', [r maskidx c]);	% region, map, contour
            face.handl{r}{maskidx}(c) = h;
        end
        
    end
end
handles.guiOptions.face = face;

%%% This breaks because there are other types of line objects aside
%from contour line objects (region lines). -DCS:2005/03/18
f = findobj('Type', 'line', 'Visible', 'on');
if isempty(f)
    handles = uiset(handles, 'detectcells', 'btdelete', 'enable', 'off');
    handles = uiset(handles, 'detectcells', 'btnextscr', 'enable', 'off');
else
    handles = uiset(handles, 'detectcells', 'btdelete', 'enable', 'on');
    handles = uiset(handles, 'detectcells', 'btnextscr', 'enable','on');
end
%zoom on;