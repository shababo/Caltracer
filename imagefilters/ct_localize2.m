function [image, param] = ct_localize2(experiment, maskidx, param)
% This function does the same thing as Dmitriy Aronov's "epo_localize" function
% but it is faster.  Each pixel in the original image is divided by the mean
% value of a square of pixels surrounding it.  The area of the square is 
% specified by the "filt", which gives the "radius" of a square surrounding
% each point.  The square will be (2 x filt) + 1 in width.
% Here by mean filtering is used to create a second image, and then doing pixel-wise
% division of the original image by the mean filtered image.



%% Get object radius
cond1 = isstruct(param);
cond2 = isfield(param,'radius');
if cond1 & cond2;
    rad = param.radius;
    %nothing
else
    answer = inputdlg('Cell diameter (um):','Input for the localization filter',1,{'10'});
    if isempty(answer)
        loca = experiment.Image(maskidx).image;
        %param = [];
        param.status = 'error';
        return
    end
    rad = str2num(answer{1});
    rad = round(rad./experiment.spaceRes);
    param.radius = rad;
end
h = msgbox({'Busy: Filtering';'(This window will close when finished)'});
%% Gather and setup basic variables
filt = param.radius;
image = double(experiment.Image(maskidx).image);
image = adjustbadpixels(image,experiment.Image(maskidx).badpixels);
image = padarray(image,[filt filt],'replicate','both');


filt=2*filt+1;%width of square (must be an odd number)
filt=ones(filt)./(filt^2);%making a square filter;
image2=filter2(filt,image);
image=image./(image2+eps);%divide original pixels by their local mean
image([1:rad end-(rad-1):end],:)=[];
image(:,[1:rad end-(rad-1):end])=[];%correct for x and y filtering artifacts (pads)

[x y] = meshgrid(-rad:rad);
gs = exp(-(x.^2+y.^2)/rad);
image = xcorr2(image,gs);
image = image(rad+1:end-rad,rad+1:end-rad);

param.status = 'ok';
try %in case user closed it
    close (h)
end


%%
function image = adjustbadpixels(image,badpixels);

imsz = size(image);
if ~isempty(badpixels.leftcols);
    numcols = length(badpixels.leftcols);
    stopval = max(badpixels.leftcols);
    image(:,1:stopval)=mean(mean(image));
end
if ~isempty(badpixels.rightcols);
    numcols = length(badpixels.rightcols);
    startval = min(badpixels.rightcols);
    image(:,startval:end)=mean(mean(image));
end
if ~isempty(badpixels.upperrows);
    numcols = length(badpixels.upperrows);
    stopval = max(badpixels.upperrows);
    image(1:stopval,:)=mean(mean(image));
end
if ~isempty(badpixels.lowerrows);
    numcols = length(badpixels.lowerrows);
    startval = max(badpixels.lowerrows);
    image(startval:end,:)=mean(mean(image));
end