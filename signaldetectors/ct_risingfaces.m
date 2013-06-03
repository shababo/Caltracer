function [onsets, offsets, params] = ...
    ct_risingfaces(rastermap, handles, ridxs, clustered_contour_ids, options)

% [onsets offsets] = detectspikesintegrals(rastermap)


%% Gather some parameters and set some variables
%NEED TO ADJUST THESE INTEGRAL CONSTANTS BY time!!
%RATIO OF WIDTH TO HEIGHT... MEANHEIGHT/NUMSECS TO GET RID OF TALL NARROW
%FALSE POSITIVES... MAYBE IN SMOOTHED SIGNAL... maybe easier just min duration
numcells = size(rastermap,1);
numframes = size(rastermap,2);
fps = handles.app.experiment.fs;
framedur = 1/fps;
diffintegralthreshconstlo = options.RiseIntegralHardThreshLo.value;
diffintegraltimessdlo = options.RiseIntegralTimesNoise.value;
basicfiltlen = round(fps*options.BasicFiltLenInSec.value);

params.RiseIntegralHardThreshLo = options.RiseIntegralHardThreshLo.value;
params.RiseIntegralTimesNoise = options.RiseIntegralTimesNoise.value;
params.BasicFiltLenInSec = options.BasicFiltLenInSec.value;

%% get noise per cell based on how many pixels in each cell assumes median
%% of cell noises represents silent cells
noisepercell = getnoisepercell(handles,rastermap,numcells,clustered_contour_ids);
onsets = {};
offsets = {};

%% Go through each cell and analyze the signals in a few ways for both
%% noise and signal readings
for cidx = 1:numcells
%% Preprocessing for later    
    sig = rastermap(cidx,:);%signal
    if basicfiltlen > 1;
        smoothsig(cidx,:) = filtfilt(1/basicfiltlen*ones(1,basicfiltlen),1,sig);%smoothed so can look for peaks
    else
        smoothsig(cidx,:) = sig;
    end   


%% Find areas of monotonic increase and calculate the total increase over
%% them
    diffsig(cidx,:) = diff(smoothsig(cidx,:));
    [diffup{cidx},diffdown{cidx}] = ct_continuousabove(diffsig(cidx,:),...
        zeros(size(diffsig(cidx,:))),0,1,inf);
    %diffup is potential signal-related rises, diffdown is downward - noise
    % measure actual amount of rise
    for uidx = 1:size(diffup{cidx},1);
        diffintegrals{cidx}(uidx) = sum(diffsig(cidx,(diffup{cidx}(uidx,1):...
            diffup{cidx}(uidx,2))));
    end

%% Find thresholds based on number of pixels-based noise
    noisethiscell = mean(smoothsig(cidx,:))+noisepercell(cidx)*diffintegraltimessdlo;%mean + XSD
    diffintegralthreshlo = max([diffintegralthreshconstlo,noisethiscell]);%thresh for cell

%% Find epochs above each threshold    
    diffidxslo = find(diffintegrals{cidx}>diffintegralthreshlo);
    diffstartstopslo = diffup{cidx}(diffidxslo,:);
    diffstartstopslo(:,2) = diffstartstopslo(:,2)+1;
    diffstartslo = diffstartstopslo(:,1);
    diffstopslo = diffstartstopslo(:,2);
    if ~isempty(diffstartslo);
        onsets{cidx} = diffstartslo;
        offsets{cidx} = diffstopslo;
    elseif isempty(diffstartslo);
        onsets{cidx}=[];
        offsets{cidx}=[];
    end    
end


%%
function noisepercell = getnoisepercell(handles,rastermap,numcells,clustered_contour_ids);

contours = handles.app.experiment.contourLines(clustered_contour_ids);
midx = 1;
nx = handles.app.experiment.Image(midx).nX;
ny = handles.app.experiment.Image(midx).nY;
contourpixels = cell(1,numcells);
pixpercell = zeros(1,numcells);

h = waitbar(0, 'Calculating masks from contours.  Please wait.');
for cidx = 1:numcells    
    waitbar(cidx/numcells);
    ps = round(contours{cidx});
    [subx suby] = meshgrid(min(ps(:,1)):max(ps(:,1)), ...
			   min(ps(:,2)):max(ps(:,2)));
    inp = inpolygon(subx, suby, ...
		    contours{cidx}(:,1), ...
		    contours{cidx}(:,2));
    cidxx = subx(inp == 1);
    cidxy = suby(inp == 1);
    outsideim=cidxx<1|cidxx>nx;%find x-axis components that are less than 1
    cidxx(outsideim)=[];%delete them 
    cidxy(outsideim)=[];%and the y coords for the corresponding points
    outsideim=cidxy<1|cidxy>ny;    %repeat with y's that are too low
    cidxx(outsideim)=[];
    cidxy(outsideim)=[];
    contourpixels{cidx} = sub2ind([nx ny], cidxx, cidxy);% contour masks
    pixpercell(cidx) = length(contourpixels{cidx});
end
close(h);

stdpercell = std(rastermap,1,2);
noiseconst = stdpercell'.*pixpercell.^.5;
numbins = 1+3.332*log10(length(noiseconst));%Sturge's Rule
[y,x]=hist(noiseconst,numbins);%
noiseconst = median(noiseconst);
noiseconst = noiseconst*ones(size(stdpercell));
noisepercell = noiseconst'./(pixpercell.^0.5);%derive a noise expected for each cell, based on num of pixels