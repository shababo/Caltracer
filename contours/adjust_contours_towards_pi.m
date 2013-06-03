function handles = adjust_contours_towards_pi(handles)
% Adjusts the countours towards pi

% maskidx is the mask that is currently being processed.
maskidx = handles.app.data.currentMaskIdx;

% Ridx is the region currently being processed.
ridx = handles.app.data.currentRegionIdx;

% nhandlr is the number of handles for the contours within a region.
nhandlr = length(handles.guiOptions.face.handl{ridx}{maskidx});

% handlr is the handles for the contours within a region
handlr = handles.guiOptions.face.handl{ridx}{maskidx};

%contours is the contours in the current region.
contour = handles.app.experiment.regions.contours{ridx}{maskidx};

% Original and filtered image.
image = handles.app.experiment.Image(maskidx).image;
filtered_image = handles.app.experiment.Image(maskidx).filteredImage;

% clr is the color for each region.
clr = handles.app.experiment.regions.cl(ridx,:);

% Initialize the line width.
linewidth = zeros(1,length(handlr));

% Detecting which contours to adjust is based on the line width.
for counter = 1:nhandlr
    linewidth(counter)= get(handlr(counter),'linewidth');
end
contourtoadjust = find(linewidth==2);

tempcn = [];
spl = [];
for counter = 1:length(contour)
    if isempty(find(contourtoadjust==counter))
        tempcn{length(tempcn)+1} = contour{counter};
    else
        newcn = {};
        crd = contour{counter};
        x = max([fix(min(crd(:,1)))-2 1]):min([fix(max(crd(:,1)))+2 ...
		    size(image,2)]);
        y = max([fix(min(crd(:,2)))-2 1]):min([fix(max(crd(:,2)))+2 ...
		    size(image,1)]);
        vls = filtered_image(y,x);
        [xs ys] = meshgrid(x,y);
        in = inpolygon(xs,ys,crd(:,1),crd(:,2));
        vls = vls.*in;
        
        mx = zeros(size(vls));
        for xf = -1:1
            for yf = -1:1
                mx(2:end-1,2:end-1) = max(cat(3,mx(2:end-1,2:end-1),vls((2:end-1)+yf,(2:end-1)+xf)),[],3);
            end
        end
        
        [j i] = find(vls>=mx & vls~=0);
        i = x(1)+i-1;
        j = y(1)+j-1;
        
        dst = [];
        for d = 1:length(i)
            dst(:,d) = sum((crd-repmat([i(d) j(d)],size(crd,1),1)).^2,2);
        end
        [mn bestcell] = min(dst,[],2);
        set(handlr(counter),'visible','off');
        for d = 1:length(i)
            newcn{d} = crd(find(bestcell==d),:);
            if ~isempty(newcn{d})
                v1 = newcn{d}([2:end 1],:)-newcn{d};
                v2 = newcn{d}([end 1:end-1],:)-newcn{d};
                angl = sum(v1.*v2,2)./(sum(v1.^2,2).*sum(v2.^2,2)+eps);
                newcn{d} = newcn{d}(find(angl<0),:);
                if ~isempty(newcn{d})
                    spl = [spl plot(newcn{d}([1:end 1],1),newcn{d}([1:end 1],2),'linewidth',2,'Color',1-clr)];
                end
            end
            tempcn{length(tempcn)+1} = newcn{d};
        end
        drawnow;
        refresh;
    end
end

contour = [];


% Check to make sure that the new contours are still greater than
% the min area. -DCS:2005/03/30
min_area = handles.guiOptions.face.minArea;
for counter = 1:length(tempcn)
    if (polyarea(tempcn{counter}(:,1),tempcn{counter}(:,2))*(handles.app.experiment.mpp^2) >= min_area)
        contour{size(contour,2)+1} = tempcn{counter};
    end
end

handles.guiOptions.face.handl{ridx}{maskidx} = handlr;
handles.app.experiment.regions.contours{ridx}{maskidx} = contour;
handles.guiOptions.face.isAdjusted(ridx) = 1;

delete(spl);

