function contours = keepbrightestcontours(contours,numcells,im);

h = waitbar(0, 'Calculating contour brightnesses.');
nx = size(im,1);
ny = size(im,2);
contourslen = size(contours,2);
for c = 1:contourslen;    
    ps = round(contours{c});
    [subx suby] = meshgrid(min(ps(:,1)):max(ps(:,1)), ...
			   min(ps(:,2)):max(ps(:,2)));
    inp = inpolygon(subx, suby, ...
		    contours{c}(:,1), ...
		    contours{c}(:,2));
    cidxx = subx(find(inp == 1));
    cidxy = suby(find(inp == 1));
    indices = sub2ind([nx ny], cidxy, cidxx);% contour indices in im.
    cbrightness(c) = mean(im(indices));
%     figure;imagesc(im);colormap(gray);
%     plotfromcontours(contours(c));ylim([0 ny]);xlim([0 nx])
%     fake = zeros(nx,ny);fake(indices) = 1;
%     figure;imagesc(fake);colormap gray;title(num2str(c))
%     title(cbrightness(c))
    waitbar(c/contourslen);
end
close(h);

[trash,cinds] = sort(cbrightness);
cinds = cinds(end-(numcells-1):end);
contours = contours(cinds);