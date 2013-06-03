function handles = find_overlap(handles, notoverlap)
% function handles = find_overlap(handles)
% Find the contours that are overlapping in the various maps and
% highlight them.  

% The way overlaps are kept track of is with the tags of the 
% objects (and line thickness)(!).  Only the first mask ('movie contours')
% are highlighted or not.  -BW


h = msgbox({'Calculating Overlaps';'(This window will close when finished)'});
nmaps = handles.app.experiment.numMasks;
nregions = handles.app.experiment.numRegions;
cl = hsv(nmaps);

%set up a system to keep track of which movie contour each other contour overlaps with
%always within the same region
handles.app.experiment.contourMaskIdx={};
for ridx = 1:nregions;
    numcontours=length(handles.app.experiment.regions.contours{ridx}{1});
    handles.app.experiment.contourMaskIdx{ridx}=ones(1,numcontours);%default for which mask the 
%         movie contours overlapped with
    for maskidx = 1:nmaps;
        numcontours = length(handles.app.experiment.regions.contours{ridx}{maskidx});
        if notoverlap ==0
        handles.app.experiment.overlapsInfo{ridx}{maskidx} = zeros(numcontours, 2);
        else 
        handles.app.experiment.overlapsInfo{ridx}{maskidx} = ones(numcontours, 2);
        end
    end
end

% Reset all the overlap information as if it's already happened
% before.  This way the user can keep trying with various overlap %
% values.q
for n = 1:nmaps				
    for r = 1:nregions
        nmovie_contours = length(handles.app.experiment.regions.contours{r}{n});
            if notoverlap ==0
            set(handles.guiOptions.face.handl{r}{n}(:), ...
            'linewidth', 1, ...
            'Color', cl(n,:));		    
            set(handles.guiOptions.face.handl{r}{n}(:), ...
            'Tag', '');
            else
            set(handles.guiOptions.face.handl{r}{n}(:), ...
            'linewidth', 2, ...
            'Color', cl(n,:));		    
             set(handles.guiOptions.face.handl{r}{n}(:), ...
                        'linewidth', 2, ...
                        'Color', cl(n,:));
            end    
    end
end

% Collect all the contours for a given map.  Compare those contours to
% the contours in the FIRST map.  If the contours overlap then
% highlight them.  In order to optimize this, we can see if the
% centroid is in a certain radius, so that it's not completely N^2.
overlap_pct = str2num(uiget(handles, 'consolidatemaps','txoverlap', 'String'));
overlap_pct = overlap_pct/100;


%If Classify Overlap or Eliminate Overlap is selected, then highlight
%overlapping cells, but if Eliminate Rest is selected highlight only
%non-overlapping cells.
marked = {};

    for n = 2:nmaps
       
        for r = 1:nregions
            movie_contours = handles.app.experiment.regions.contours{r}{1};
            nmovie_contours = length(handles.app.experiment.regions.contours{r}{1});
            contours = handles.app.experiment.regions.contours{r}{n};
            ncontours = length(handles.app.experiment.regions.contours{r}{n});
            for mc = 1:nmovie_contours                
                overlapsfound = 1;
                ps = round(movie_contours{mc});
                [mcmaskx mcmasky] = meshgrid(min(ps(:,1)):max(ps(:,1)), ...
                           min(ps(:,2)):max(ps(:,2)));
                       maxx = max(mcmaskx(:));
                       maxy = max(mcmasky(:));
                       minx = min(mcmaskx(:));
                       miny = min(mcmasky(:));
                for c = 1:ncontours
                    if (maxx>min(contours{c}(:,1)))&&(minx<max(contours{c}(:,1)))&&(maxy>min(contours{c}(:,2)))&&(miny<max(contours{c}(:,2)))
                        pix_in_con = inpolygon(mcmaskx, mcmasky, ...
                                       contours{c}(:,1), ...
                                       contours{c}(:,2));

                        npix_in_con = prod(size(pix_in_con));
                        % Set the movie contour with informatoin so that we
                                % can delete it later.  If overlap_pct% of the map
                                % contour is in the movie contour we mark the movie
                                % contour.


                        if (length(find(pix_in_con)) > overlap_pct*npix_in_con)%if overlap is great enough
                            set(handles.guiOptions.face.handl{r}{1}(mc), ...%set line thickness
                            'linewidth', 2, ...
                            'Color', cl(1,:));
                            set(handles.guiOptions.face.handl{r}{n}(c), ...%set line thickness for mask
                            'linewidth', 2, ...
                            'Color', cl(n,:));
                            set(handles.guiOptions.face.handl{r}{1}(mc), ...%and change tag...
                                'Tag', 'cellcontour - overlap');


                            % This was added to return the ids of the mask
                            % contours which overlap with the contours of the
                            % original movie.
                            handles.app.experiment.overlapmaskids{r}{n-1}{mc}(overlapsfound) = c;
                            overlapsfound = overlapsfound+1;
                            if notoverlap == 0 %if looking for overlap
                            handles.app.experiment.overlapsInfo{r}{n}(c,:)=[mc r];
                            handles.app.experiment.overlapsInfo{r}{1}(mc,:)=[c r]; 
                            handles.app.experiment.contourMaskIdx{r}(mc)=n;
                            else %if eliminating the rest
                                set(handles.guiOptions.face.handl{r}{1}(mc), ...
                            'linewidth', 1, ...
                            'Color', cl(1,:));
                            handles.app.experiment.overlapsInfo{r}{n}(c,:)=[0 r];
                            handles.app.experiment.overlapsInfo{r}{1}(mc,:)=[0 r]; 
                            handles.app.experiment.contourMaskIdx{r}(mc)=n;
                            marked {length(marked)+1}= c;
                            end
                        end
                    end   
                end
            end
                for a=1:length(marked)
                    set(handles.guiOptions.face.handl{r}{n}(marked{a}), ...
                        'linewidth', 1, ...
                        'Color', cl(n,:));
                end
        end
    end
%make a vector ignoring regions for .contourMaskIdx
if length(handles.app.experiment.contourMaskIdx)>1
    new = [];
    for idx = 1:length(handles.app.experiment.contourMaskIdx);
        new = [new handles.app.experiment.contourMaskIdx{idx}];
    end
    handles.app.experiment.contourMaskIdx{1} = new;
end
try %in case user closed it
    close (h)
end
refresh;

%Enable option to export the mask ids which overlap with mc.
handles = menuset(handles,'Export','export',...
            'Export ids of overlapping masks' ,...
            'Enable','on');   