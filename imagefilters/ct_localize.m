function [loca, param] = ct_localize(experiment, maskidx, param)
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
a = experiment.Image(maskidx).image;
a = adjustbadpixels(a,experiment.Image(maskidx).badpixels);

aat=padarray(a,[rad rad],'replicate','both');
% aat = [repmat(a(:,1),1,rad) a repmat(a(:,end),1,rad)];
% aat = [repmat(aat(1,:),rad,1); aat; repmat(aat(end,:),rad,1)];
% %now have image padded with rad on each side
loca = zeros(size(a,1),size(a,2));
pr = zeros(1,2*rad+2);
h = waitbar(0, 'Localizing image.  Please wait.');
for c = -rad:rad
    for d = -rad:rad
        loca = loca+aat(1+rad+c:end-rad+c,1+rad+d:end-rad+d);	
    end
    waitbar((c+rad+1)/(2*rad));
end
loca = loca/(2*rad+1)^2;%normalize
loca = a./(loca+eps);
[x y] = meshgrid(-rad:rad);
gs = exp(-(x.^2+y.^2)/rad);
loca = xcorr2(loca,gs);
loca = loca(rad+1:end-rad,rad+1:end-rad);
close(h);
param.status = 'ok';


%%
function image = adjustbadpixels(image,badpixels);

imsz = size(image);
if ~isempty(badpixels.leftcols);
    numcols = length(badpixels.leftcols);
    stopval = max(badpixels.leftcols);
%     meanstart = stopval+1;
%     meanstop = imsz(2);
%     means = mean(image(:,meanstart:meanstop),2);
%     image(:,1:stopval)=repmat(means,[1 stopval]);
    image(:,1:stopval)=mean(mean(image));
end
if ~isempty(badpixels.rightcols);
    numcols = length(badpixels.rightcols);
    startval = min(badpixels.rightcols);
%     meanstart = 1;
%     meanstop = startval - 1;
%     means = mean(image(:,meanstart:meanstart),2);
%     image(:,startval:end)=repmat(means,[1 numcols]);
    image(:,startval:end)=mean(mean(image));
end
if ~isempty(badpixels.upperrows);
    numcols = length(badpixels.upperrows);
    stopval = max(badpixels.upperrows);
%     meanstart = stopval+1;
%     meanstop = imsz(1);
%     means = mean(image(meanstart:meanstop,:),1);
%     image(1:stopval,:)=repmat(means,[stopval 1]);
    image(1:stopval,:)=mean(mean(image));
end
if ~isempty(badpixels.lowerrows);
    numcols = length(badpixels.lowerrows);
    startval = max(badpixels.lowerrows);
%     meanstart = 1;
%     meanstop = startval-1;
%     means = mean(image(meanstart:meanstop,:),1);
%     image(1:stopval,:)=repmat(means,[stopval 1]);
    image(startval:end,:)=mean(mean(image));
end