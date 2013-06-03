function handles = draw_cell_contours(handles, varargin)
% Draw the contours around the cells that are detected in a given
% region, in a given map.  The defaults are the current map and the
% current region.

%maskidx is the mask that is currently being processed.
maskidx = handles.app.data.currentMaskIdx;
ridx = handles.app.data.currentRegionIdx;
handles = uiset(handles, 'detectcells', 'bthide', 'String','Hide');
face = handles.guiOptions.face;
nargs = length(varargin);
do_save_handles = 0;
do_special_color = 0;			% Usually we color by region.
if (nargs > 0)
    for i = 1:2:nargs
        switch varargin{i}
         case 'ridx'
          ridx = varargin{i+1};
         case 'maskidx'
          maskidx = varargin{i+1};
         case 'color'
          do_special_color = 1;
          special_cl = varargin{i+1};
         case 'savehandles'
          do_save_handles = varargin{i+1};
        end
    end
end

if (~do_save_handles)
    handles = delete_contour_handles(handles, 'ridx', ridx, 'maskidx', maskidx);
end

nregions = handles.app.experiment.numRegions;
if (strcmpi(ridx, 'all'))
    regions_to_draw = 1:nregions;
else
    regions_to_draw = ridx;
end

% Draw the regions.
for r = regions_to_draw
    if (isempty(handles.app.experiment.regions.contours{r}))
        continue;
    end
    if (length(handles.app.experiment.regions.contours{r}) < maskidx)
        continue;
    end    
    region_cn = handles.app.experiment.regions.contours{r}{maskidx};        
    % Redraw the contours.
    lidx = get_label_idx(handles, 'image');
    axes(handles.uigroup{lidx}.imgax);
    
    children_handles = get(handles.uigroup{lidx}.imgax, 'Children');

    
    face.handl{r}{maskidx} = [];		% kill handles since redoing.
    if (do_special_color)
        cl = special_cl;
    else
        cl = handles.app.experiment.regions.cl(r,:);
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
    handles = uiset(handles, 'detectcells', 'bteditcontours', 'enable', 'on');
    handles = uiset(handles, 'detectcells', 'btnextscr', 'enable','on');
end

numcells = size(handles.app.experiment.regions.contours{handles.app.data.currentRegionIdx}{handles.app.data.currentMaskIdx},2);
set(handles.app.experiment.ImageTitle,'string',[handles.app.experiment.fileName,'.  ',num2str(numcells),' cells.'])
%zoom on;

