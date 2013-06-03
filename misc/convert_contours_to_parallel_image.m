function convert_contours_to_parallel_image(handles)

inputcontours = handles.app.experiment.contourLines;
currentim = handles.app.experiment.Image.image;
high = median(currentim(:)) + 3*std(currentim(:));
currentim(currentim>high) = high;
currentim = currentim - min(currentim(:));
currentim = currentim / max(currentim(:));


[FileName,PathName] = uigetfile('.tif','Choose Parallel Image of same Field');
if FileName==0 & ~PathName==0
    return
end
parallelim = double(imread([PathName,'\',FileName]));
high = median(parallelim(:)) + 3*std(parallelim(:));
parallelim(parallelim>high) = high;
parallelim = parallelim - min(parallelim(:));
parallelim = parallelim / max(parallelim(:));
heightpi = size(parallelim,1);
widthpi = size(parallelim,2);

h = cpselect(currentim,parallelim);
% set(h,'WindowClosedCallback','delete(findobj(''visible'',''off'',''type'',''figure''))')
% 
% hi = figure('visible','off');%make an invisible figure so the closing
%     %of the other fig will close it
waitfor(h);%only progress once the invisible fig is closed... by that time points
% "input_points" and "base_points" should be in the base work space

input_points = evalin('base','input_points');
base_points = evalin('base','base_points');

input_points_corr = cpcorr(input_points,base_points,...
                           currentim,parallelim);
mytform = cp2tform(input_points_corr,base_points,'linear conformal');

h = waitbar(0, 'Converting individual contours.');
for icidx = 1:length(inputcontours);
    contourimage = imagefromcontours(inputcontours(icidx),size(handles.app.experiment.Image.image));
    registered = imtransform(contourimage,mytform,...
        'VData',[1 size(currentim,1)],'UData',[1 size(currentim,2)],...
        'YData',[1 heightpi],'XData',[1 widthpi],...
        'XYScale',[1 1]);
    if max(registered(:))<1
        outputcontours{icidx} = Inf * ones(10,2);%make dummy
            %contour to fill in
    else
        registeredcontour = findfrommatrix(registered, eps , 1 ,Inf);
        if ~isempty(registeredcontour);
            outputcontours(icidx) = registeredcontour;
        else
            outputcontours{icidx} = Inf * ones(10,2);%make dummy
                %contour to fill in
        end
    end
    waitbar(icidx/length(inputcontours));
end
close(h);

[FileName,PathName] = uiputfile('*.mat','Save Contours File');
if FileName==0 & ~PathName==0
    return
end
imagesize = [heightpi widthpi];
save([PathName,'\',FileName],'outputcontours','imagesize');


%%
function outputim = imagefromcontours(contours,imagesize);

outputim = zeros(imagesize);
for contnumb = 1:(length(contours));%for each contour
    temp=zeros(imagesize(1),imagesize(2));%a blank template frame of zeros, for each contour... will be used later to generate a list of pixels
    max1=min([imagesize(2),...%setting up a box of pixels to look in, so don't look through every pixel in the image
        ceil(max(contours{contnumb}(:,1)))]);%this is max in dim1, can't be larger than the image in that dimension
    max2=min([imagesize(1),...
        ceil(max(contours{contnumb}(:,2)))]);%max value in dim2... can't be larger than the image in that dimension
    min1=max([1,...
        floor(min(contours{contnumb}(:,1)))]);%min in dim1, can't be less than 1
    min2=max([1,...
        floor(min(contours{contnumb}(:,2)))]);%min in dim2, can't be less than 1
    
    v1=repmat(min1:max1,[(max2-min2+1) 1]);
    v1=reshape(v1,[1 prod(size(v1))]);%a vector of all dim1 coords in bounding box, repeated to match with oppositely indexed dim2 points
    v2=repmat(min2:max2,[(max1-min1+1) 1])';
    v2=reshape(v2,[1 prod(size(v2))]);%a vector of all dim2 coords in bounding box
    
    in=inpolygon(v1,v2,contours{contnumb}(:,1),contours{contnumb}(:,2));%find out which 
    in=reshape(in,[max2-min2+1 max1-min1+1]);%reshape into a rectangle, for insertion into the blank template
    temp(min2:max2,min1:max1)=in;%putting cell pixels in the context of the whole image
    mask=find(temp);

    outputim(mask)=contnumb;
end

%%
function conts = findfrommatrix(image,cutoff,minarea,maxarea)
% function conts = findfrommatrix(a,cutoff,areath,maxarea)
%conts = findcells(fin, cutoff,areath)
%   takes image data from matrix input (a), detects cells with a given
%   cutoff, and
%   outputs a cell array containing coordinates of all contours

list = contourc(image,[cutoff cutoff]);%list is a list of coordinates, but the
% coordinates for each contour are preceded by a 1x2 descriptor row where
% column 1 is cutoff level and column 2 is number of points for this
% contour.  v is that here
ind = 1;
conts = [];
while 1%run until break
    numpoints = list(2,ind);
    coords = [list(1,ind+1:ind+numpoints)' list(2,ind+1:ind+numpoints)']; % temp
    if polyarea(coords(1:end-1,1),coords(1:end-1,2)) > minarea  &&...
            polyarea(coords(1:end-1,1),coords(1:end-1,2)) < maxarea
        conts{end+1} = coords(1:end-1,:);
    end
    
    ind = ind+numpoints+1;
    if ind > size(list,2)
        break
    end
end


%%
function a = poly_area(coords)

%a = poly_area(coords)
%   calculates the area of a polygon with given vertices
if prod(size(coords))==0
   a = 0;
else
   m = [coords; coords(1,:)];
   x = m(:,1);
   y = m(:,2);
   a = abs(sum(x(1:end-1).*y(2:end)) - sum(x(2:end).*y(1:end-1)))/2;
end

%%
function masks = masksfromcontours(contours,imagesize);

masks = cell(1,length(contours));
for contnumb = 1:(length(contours));%for each contour
    temp=zeros(imagesize(1),imagesize(2));%a blank template frame of zeros, for each contour... will be used later to generate a list of pixels
    max1=min([imagesize(2),...%setting up a box of pixels to look in, so don't look through every pixel in the image
        ceil(max(contours{contnumb}(:,1)))]);%this is max in dim1, can't be larger than the image in that dimension
    max2=min([imagesize(1),...
        ceil(max(contours{contnumb}(:,2)))]);%max value in dim2... can't be larger than the image in that dimension
    min1=max([1,...
        floor(min(contours{contnumb}(:,1)))]);%min in dim1, can't be less than 1
    min2=max([1,...
        floor(min(contours{contnumb}(:,2)))]);%min in dim2, can't be less than 1
    
    v1=repmat(min1:max1,[(max2-min2+1) 1]);
    v1=reshape(v1,[1 prod(size(v1))]);%a vector of all dim1 coords in bounding box, repeated to match with oppositely indexed dim2 points
    v2=repmat(min2:max2,[(max1-min1+1) 1])';
    v2=reshape(v2,[1 prod(size(v2))]);%a vector of all dim2 coords in bounding box
    
    in=inpolygon(v1,v2,contours{contnumb}(:,1),contours{contnumb}(:,2));%find out which 
    in=reshape(in,[max2-min2+1 max1-min1+1]);%reshape into a rectangle, for insertion into the blank template
    temp(min2:max2,min1:max1)=in;%putting cell pixels in the context of the whole image
    masks{1,contnumb}=find(temp);
end
