function [onsets, offsets, params] = ...
    epo_detectspikesintegrals(rastermap, handles, ridxs, clustered_contour_ids, options);


%% Gather some parameters and set some variables
%NEED TO ADJUST THESE INTEGRAL CONSTANTS BY time!!
% rawintegralthreshconsthi = .15;%if above this then definite signal
% rawintegralthreshconstlo = .04;
% maxsmoothvalsthreshconst = .01;%if above this then definite signal
% meansmoothvalsthreshconst = .01;%assumes good baselining
%RATIO OF WIDTH TO HEIGHT... MEANHEIGHT/NUMSECS TO GET RID OF TALL NARROW
%FALSE POSITIVES... MAYBE IN SMOOTHED SIGNAL... maybe easier just min duration
% % diffintegralthreshconsthi = .025;
% diffintegralthreshconstlo = .008;
%
% rawintegraltimessdhi = 5;
% rawintegraltimessdlo = 4;
% % maxsmoothvalstimessd = 2;
% % meansmoothvalstimessd = 2;
% % diffintegraltimessdhi = 10;
% diffintegraltimessdlo = 3;
numcells = size(rastermap,1);
% numframes = size(rastermap,2);
fps = handles.app.experiment.fs;
% framedur = 1/fps;
% lagtime = .300;%(sec)
% lagframes = round(lagtime/framedur);%number of frames
% baselineframes = 5;


rawintegralthreshconsthi = options.RawIntegralHardThreshHi.value;
rawintegraltimessdhi = options.RawIntegralTimesNoiseHi.value;
rawintegralthreshconstlo = options.RawIntegralHardThreshLo.value;
rawintegraltimessdlo = options.RawIntegralTimesNoiseLo.value;

diffintegralthreshconstlo = options.RiseIntegralHardThresh.value;
diffintegraltimessdlo = options.RiseIntegralTimesNoise.value;
basicfiltlen = round(fps*options.BasicFiltLenInSec.value);


params.RawIntegralHardThreshHi = options.RawIntegralHardThreshHi.value;
params.RawIntegralTimesNoiseHi = options.RawIntegralTimesNoiseHi.value;
params.RawIntegralHardThreshLo = options.RawIntegralHardThreshLo.value;
params.RawIntegralTimesNoiseLo = options.RawIntegralTimesNoiseLo.value;
params.RiseIntegralHardThresh = options.RiseIntegralHardThresh.value;
params.RiseIntegralTimesNoise = options.RiseIntegralTimesNoise.value;
params.BasicFiltLenInSec =  options.BasicFiltLenInSec.value;



%% get noise (SD) per cell based on how many pixels in each cell assumes median
%% of cell noises represents silent cells
noisepercell = getnoisepercell(handles,rastermap,numcells,clustered_contour_ids);    

onsets = {};
offsets = {};
h = waitbar(0, 'Finding Events.');

%% Go through each cell and analyze the signals in a few ways for both
%% noise and signal readings
for cidx = 1:numcells
%% Preprocessing for later   
%     if cidx == 136;
%         1;
%     end

% %if mode is below zero, subtract the mode
%     modesig = mode(round(rastermap(cidx,:)*1000));
%     if modesig < 0;%check for overbaselining with median
%         rastermap(cidx,:) = rastermap(cidx,:) - (modesig/1000);
%     end
        
    sig = rastermap(cidx,:);%signal
%     figure;plot(sig)
    if basicfiltlen > 1;
        smoothsig(cidx,:) = filtfilt(1/basicfiltlen*ones(1,basicfiltlen),1,sig);%smoothed so can look for peaks
    else
        smoothsig(cidx,:) = sig;
    end   
%     baseline = filtfilt(1/baselineframes*ones(1,baselineframes),1,sig);
%     baseline=[zeros(1,lagframes),baseline(1:end-lagframes)];
%     nobasesig(cidx,:) = sig-baseline;%sig w/ baseline of value lagframes ago removed
    nobasesig(cidx,:) = sig;%unchanged
%% Find above-zero areas calc integrals
    [rawup{cidx},rawdown{cidx}] = ct_continuousabove(nobasesig(cidx,:),zeros(size(nobasesig(cidx,:))),0,1,inf);
    %rawup will be potential "signals", rawdown will serve as to measure
    %noise
    if isempty(rawup{cidx})%if no upswings at all, skip all steps involving finding signals
        onsets{cidx} = [];%assign values to variables that are needed for next run of loop
        offsets{cidx} = [];
    else
        for uidx = 1:size(rawup{cidx},1);
            rawintegrals{cidx}(uidx) = sum(nobasesig(cidx,(rawup{cidx}(uidx,1):rawup{cidx}(uidx,2))));
            %sum in line above to calculate actual integral... area under curve
%% From same above-zero frame areas, calc max and mean in smoothed signal
            maxsmoothvals{cidx}(uidx) = max(smoothsig(cidx,(rawup{cidx}(uidx,1):rawup{cidx}(uidx,2))));
                %get max of smoothed signal within the above-zero area
            meansmoothvals{cidx}(uidx) = mean(smoothsig(cidx,(rawup{cidx}(uidx,1):rawup{cidx}(uidx,2))));
                %get mean of smoothed signal within the above-zero area
        end

%% Measure noise as downward deflections, get equivalent measures as above
        noiserawintegrals{cidx} = [];%initiate noise matrix for each cell
        noisemaxsmoothvals{cidx} = [];
        noisemeansmoothvals{cidx} = [];
        for didx = 1:size(rawdown{cidx},1);%for each down signal... go through and collect info
            noiserawintegrals{cidx}(didx) = -sum(nobasesig(cidx,...
                (rawdown{cidx}(didx,1):rawdown{cidx}(didx,2))));
            noisemaxsmoothvals{cidx}(didx) = -max(smoothsig(cidx,...
                (rawdown{cidx}(didx,1):rawdown{cidx}(didx,2))));
            noisemeansmoothvals{cidx}(didx) = -mean(smoothsig(cidx,...
                (rawdown{cidx}(didx,1):rawdown{cidx}(didx,2))));
        end


%% Find areas of monotonic increase and calculate the total increase over
%% them
        diffsig(cidx,:) = diff(smoothsig(cidx,:));
        [diffup{cidx},diffdown{cidx}] = ct_continuousabove(diffsig(cidx,:),...
            zeros(size(diffsig(cidx,:))),0,1,inf);
        %diffup is potential signal-related rises, diffdown is downward - noise

        %find which of those up periods is in region to be used to measure noise
    %     afterstart = diffup{cidx}(:,1)>noiseframes(1);
    %     beforestop = diffup{cidx}(:,2)<noiseframes(end);
    %     noiseup = afterstart.*beforestop;
        noisediffintegrals{cidx} = [];%initiate noise matrix for each cell

        % measure actual amount of rise
        for uidx = 1:size(diffup{cidx},1);
            diffintegrals{cidx}(uidx) = sum(diffsig(cidx,(diffup{cidx}(uidx,1):...
                diffup{cidx}(uidx,2))));
        end
        % measure amount of fall, for noise
        for didx = 1:size(diffdown{cidx},1);
            noisediffintegrals{cidx}(didx) = -sum(diffsig(cidx,(diffdown{cidx}(didx,1):...
                diffdown{cidx}(didx,2))));
        end



%% Find thresholds
        % calculate threshold based on noise times constants specified above
        rawintegralsnoisehi = rawintegraltimessdhi*mean(noiserawintegrals{cidx});
        rawintegralsnoiselo = rawintegraltimessdlo*mean(noiserawintegrals{cidx});
    %     maxsmoothvalsnoise = mean(noisemaxsmoothvals{cidx})+...
    %         (maxsmoothvalstimessd*std(noisemaxsmoothvals{cidx}));
    %     meansmoothvalsnoise = mean(noisemeansmoothvals{cidx})+...
    %         (meansmoothvalstimessd*std(noisemaxsmoothvals{cidx}));
    %     diffintegralsnoisehi =  mean(noisediffintegrals{cidx})+...
    %         (diffintegraltimessdhi*std(noisediffintegrals{cidx}));

    % top option below uses sized-based estimates of fluctuations per cell,
    % bottom is measured downward constant steps
        diffintegralsnoiselo = noisepercell(cidx)*diffintegraltimessdlo;%noise * constant
    %     diffintegralsnoiselo =  diffintegraltimessdlo*mean(noisediffintegrals{cidx});

        %take more stringent of above vs absolute thresh's set at beginning
        rawintegralthreshhi = max([rawintegralthreshconsthi,rawintegralsnoisehi]);
        rawintegralthreshlo = max([rawintegralthreshconstlo,rawintegralsnoiselo]);
    %     maxsmoothvalsthresh = max([maxsmoothvalsthreshconst,maxsmoothvalsnoise]);
    %     meansmoothvalsthresh = max([meansmoothvalsthreshconst,meansmoothvalsnoise]);
    %     diffintegralthreshhi = max([diffintegralthreshconsthi,diffintegralsnoisehi]);
        diffintegralthreshlo = max([diffintegralthreshconstlo,diffintegralsnoiselo]);

    %     tempidxs1 = find(rawintegrals{cidx}>rawintegralthresh);
    %     tempidxs2 = find(maxsmoothvals{cidx}>maxsmoothvalsthresh);
    %     tempidxs3 = find(meansmoothvals{cidx}>meansmoothvalsthresh);
    %     rawidxs = intersect(tempidxs1,tempidxs2);
    %     rawidxs = intersect(rawidxs,tempidxs3);

%% Find epochs above each threshold
        rawidxshi = find(rawintegrals{cidx}>rawintegralthreshhi);
        rawidxslo = find(rawintegrals{cidx}>rawintegralthreshlo);    
        rawidxslo(ismember(rawidxslo,rawidxshi))=[];%elim low matchers that were found in high

        %record the beginning and end of each epoch meeting threshold
        %requirements
        rawstartstopshi = rawup{cidx}(rawidxshi,:);
        rawstartshi = rawstartstopshi(:,1);
        rawstopshi = rawstartstopshi(:,2);

        if cidx == 90;
            1;
        end
        
        rawstartstopslo = rawup{cidx}(rawidxslo,:);
        rawstartslo = rawstartstopslo(:,1);
        rawstopslo = rawstartstopslo(:,2);    

        %adjust diffthresh percell... add a minimum if cell is really noisy
    %     diffidxshi = find(diffintegrals{cidx}>diffintegralthreshhi);
    %     diffstartstopshi = diffup{cidx}(diffidxshi,:);
    %     diffstartstopshi(:,2) = diffstartstopshi(:,2)+1;
    %     diffstartshi = diffstartstopshi(:,1);
    %     diffstopshi = diffstartstopshi(:,2);

        diffidxslo = find(diffintegrals{cidx}>diffintegralthreshlo);
    %     diffidxslo(ismember(diffidxslo,diffidxshi))=[];
        diffstartstopslo = diffup{cidx}(diffidxslo,:);
        diffstartstopslo(:,2) = diffstartstopslo(:,2)+1;
        diffstartslo = diffstartstopslo(:,1);
        diffstopslo = diffstartstopslo(:,2);

%% combine the rawintegral signals with the increases
    %     rawintegonoff = zeros(size(sig));
        onsets{cidx}=[];
        offsets{cidx}=[];
        %if anything above one of the high thresholds, immediately call signal
        for ridx = 1:size(rawstartstopshi,1);%keep all highthresh integrals
            onsets{cidx}(end+1,1) = rawstartshi(ridx);
            offsets{cidx}(end+1,1) = rawstopshi(ridx);
        end
    %     for didx = 1:size(diffstartstopshi,1);%keep all highthresh diff integrals
    %         keepidx = 1;
    %         for oidx = 1:size(onsets{cidx},1);%make sure no overlap with previous
    %             operiod = onsets{cidx}(oidx):offsets{cidx}(oidx);
    %             dperiod = diffstartshi(didx):diffstopshi(didx);
    %             if ~isempty(intersect(operiod,dperiod));
    %                 keepidx=0;
    %             end
    %         end
    %         if keepidx==1;
    %             onsets{cidx}(end+1,1) = diffstartshi(didx);
    %             offsets{cidx}(end+1,1) = diffstopshi(didx);
    %         end
    %     end
        for ridx = 1:size(rawstartstopslo,1);
            keepidx = 0;
            thisraw = rawstartslo(ridx):rawstopslo(ridx);%keep indices of points in this epoch
            thisstart = rawstartslo(ridx);
            thisstop = rawstopslo(ridx);
            intersects = intersect(thisraw,diffstopslo);%see which epochs also have above-thresh monotonic increases
            if ~isempty(intersects)%ie only go on if there was a big monotonic increase during this epoch
                    %finishing during this high-integral period
                didx = find(diffstopslo==intersects(1));
                if diffstartslo(didx)<=rawstartslo(ridx)%if the rising straddled or
                    %or started concomitant with the beginning of the high
                    %integral area, count this as an event
                    keepidx = 1;
                else%if rising was after start of integral
                    newstart = diffstartslo(didx);%shift the start point to the start of rise to reeval
                    if sum(nobasesig(newstart:rawstopslo(ridx)))>rawintegralthreshlo;%if
                        %still have sufficiently large integral
                        %now start of the rise, count this as an event
                        thisstart = newstart;
                        keepidx = 1;%record that this should be kept
                    end
                end
            end
            if keepidx%if to be kept
    %             theseonsets = rawstarts(ridx);
    %             theseoffsets = rawstops(ridx);
    %             onsets{cidx} = cat(1,onsets{cidx},theseonsets);
    %             offsets{cidx} = cat(1,offsets{cidx},theseoffsets);
                onsets{cidx}(end+1,1) = thisstart;%record epoch as a signal
                offsets{cidx}(end+1,1) = thisstop;
                %ELIM usedup diffstarts/stops so intersect (above) is
                %faster
            end
        end%end per rawintegral
%% try to subdivide by using above threshold diffintegal rises

        if ~isempty(onsets{cidx}) %if a signal, subdivide it

            oldonsets = onsets{cidx};
            oldoffsets = offsets{cidx};
            newonsets = [];
            newoffsets = [];

            %get above rises in non-filtered signal
            nfdiffsig(cidx,:) = diff(rastermap(cidx,:));
            nfdiffup{cidx} = ct_continuousabove(nfdiffsig(cidx,:),...
                zeros(size(nfdiffsig(cidx,:))),0,1,inf);
            for uidx = 1:size(nfdiffup{cidx},1);
                nfdiffintegrals{cidx}(uidx) = sum(nfdiffsig(cidx,(nfdiffup{cidx}(uidx,1):...
                    nfdiffup{cidx}(uidx,2))));
            end
            nfdiffidxslo = find(nfdiffintegrals{cidx}>diffintegralthreshlo);
            nfdiffstartstopslo = nfdiffup{cidx}(nfdiffidxslo,:);
            nfdiffstartslo = nfdiffstartstopslo(:,1);
            nfdiffstopslo = nfdiffstartstopslo(:,2);

            for eidx = 1:size(oldonsets);
                thisevent = [oldonsets(eidx):oldoffsets(eidx)];
    %             intersects = intersect(thisevent,nfdiffstopslo);%see which epochs also have above-low thresh monotonic increases
    %             if ~isempty(intersects)%ie only go on if there was a big monotonic increase during this epoch
    %                     %FINISHING during this high-integral period
    %                 for iidx = 1:length(intersects);
    %                     didx = find(nfdiffstopslo==intersects(iidx));
    %                     if iidx == 1;
    %                         newonsets(end+1) = min([thisevent(1) nfdiffstartslo(didx)]);
    %                     else
    %                         newonsets(end+1) = nfdiffstartslo(didx);
    %                     end                
    %                     if iidx == length(intersects)
    %                         newoffsets(end+1) = max([thisevent(end) nfdiffstopslo(didx)]);
    %                     else
    %                         tdidx = find(nfdiffstopslo==intersects(iidx+1));
    %                         newoffsets(end+1)  = nfdiffstartslo(tdidx)-1;
    %                     end
    %                 end
    %             else
                intersects = intersect(thisevent,diffstopslo);%see which epochs also have above-low thresh monotonic increases
                if ~isempty(intersects)%ie only go on if there was a big monotonic increase during this epoch
                        %FINISHING during this high-integral period
                    for iidx = 1:length(intersects);
                        didx = find(diffstopslo==intersects(iidx));
                        if iidx == 1;
                            newonsets(end+1) = min([thisevent(1) diffstartslo(didx)]);
                        else
                            newonsets(end+1) = diffstartslo(didx);
                        end                
                        if iidx == length(intersects)
                            newoffsets(end+1) = max([thisevent(end) diffstopslo(didx)]);
                        else
                            tdidx = find(diffstopslo==intersects(iidx+1));
                            newoffsets(end+1)  = diffstartslo(tdidx)-1;
                        end
                    end
                else
                    newonsets = oldonsets;
                    newoffsets = oldoffsets;
                end
            end
            onsets{cidx} = newonsets;
            offsets{cidx} = newoffsets;
        end
%% address start and stop times of signals
    %starts should be above 0, above noise (=?), and more than .2*max 
    %should be before the end of the rise at the start
        for eidx = length(onsets{cidx}):-1:1;%since we will be eliminating bad events,
        % go through backwards for safety
            %note, "old" stuff was created in the last loop and is only
            %"old" as compared to what WILL be created in this loop.
            oldstart = onsets{cidx}(eidx); 
            oldstop = offsets{cidx}(eidx);
            
            %find max value of event by finding max of smoothsig then
            %looking nearby for the closest max in the original 
            %("nearby" based on the filterlength).  Hopefully this gives a
            %value that is less suceptible to noise and yet is a true max
            %in the original data.
            thisevent = sig(oldstart:oldstop);
            thiseventsmoothed = smoothsig(cidx,oldstart:oldstop);
            [trash, maxframeofsmoothevent] = max(thiseventsmoothed);%max of smoothed
            
            beginframe = max([1 maxframeofsmoothevent-ceil(basicfiltlen/2)]);
            endframe = min([length(thisevent) maxframeofsmoothevent+ceil(basicfiltlen/2)]);
            [maxvalueofevent] = max(thisevent(beginframe:endframe));
            %max of real data within the filter range of the max found in smoothed

            startthresh = max([0 2*noisepercell(cidx) maxvalueofevent*.2]);
            %find first value in event above this.
            newstart = find(thisevent>startthresh,1,'first');
            newstart = newstart + oldstart-1;

            [trash, maxframeofevent] = max(thisevent);%max of event
            maxframeofevent = maxframeofevent+oldstart-1;
            newstop = maxframeofevent;
            
            %sometimes assignment of a zero by one empty matrix isn't the
            %same as assignment of []...?
            if isempty(newstart)
                onsets{cidx}(eidx) = [];
                offsets{cidx}(eidx) = [];
            else                
                onsets{cidx}(eidx) = newstart;
                offsets{cidx}(eidx) = newstop;
            end
        end
    end
    
    onsets{cidx} = sort(onsets{cidx});
    offsets{cidx} = sort(offsets{cidx});
    
%     figure;subplot(2,1,1)
%     plot(rastermap(cidx,:));
%     hold on
%     for ridx = 1:size(rawstartstopslo,1);
%         plot([rawstartslo(ridx) rawstopslo(ridx)],zeros(1,2),'.-r')
%     end
%     for didx = 1:size(diffstartstopslo,1);
%         plot([diffstartslo(didx) diffstopslo(didx)],zeros(1,2)-.01,'.-g')
%     end
%     subplot(2,1,2);
%     plot(rastermap(cidx,:));
%     hold on
%     for oidx = 1:size(onsets{cidx},1);
%         plot([onsets{cidx}(oidx) offsets{cidx}(oidx)],zeros(1,2),'.-r')
%     end
% 
% %     figure;subplot(2,1,1)
% %     plot(rastermap(cidx,:));
% %     hold on
% %     for rhidx = 1:size(rawstartstopshi,1);
% %         plot([rawstartshi(rhidx) rawstopshi(rhidx)],zeros(1,2)+.01,'.-r')
% %         text(rawstopshi(rhidx),.01,num2str(rawintegrals{cidx}(rawidxshi(rhidx))),'color','k');
% %     end
% %     for rlidx = 1:size(rawstartstopslo,1);
% %         plot([rawstartslo(rlidx) rawstopslo(rlidx)],zeros(1,2)-.01,'.-g')
% %         text(rawstopslo(rlidx),-.01,num2str(rawintegrals{cidx}(rawidxslo(rlidx))),'color','k');
% %     end
% %     title(['HiConst=',num2str(rawintegralthreshconsthi),' HiNoise=',num2str(rawintegralsnoisehi),...
% %         '. | LoConst=',num2str(rawintegralthreshconstlo),' LoNoise=',num2str(rawintegralsnoiselo)]);    
% % 
% %     subplot(2,1,2);
% %     plot(diffsig(cidx,:));
% %     hold on
% % %     for dhidx = 1:size(diffstartstopshi,1);
% % %         plot([diffstartshi(dhidx) diffstopshi(dhidx)],zeros(1,2)+.005,'.-r')
% % %         text(diffstopshi(dhidx),.005,num2str(diffintegrals{cidx}(diffidxshi(dhidx))),'color','k');
% % %     end
% %     for dlidx = 1:size(diffstartstopslo,1);
% %         plot([diffstartslo(dlidx) diffstopslo(dlidx)],zeros(1,2)-.005,'.-g')
% %         text(diffstopslo(dlidx),-.005,num2str(diffintegrals{cidx}(diffidxslo(dlidx))),'color','k');
% %     end
% %     title(['LoConst=',num2str(diffintegralthreshconstlo),' LoNoise=',num2str(diffintegralsnoiselo)]);    
    waitbar(cidx/numcells);
end
close(h);

%%
function noisepercell = getnoisepercell(handles,rastermap,numcells,clustered_contour_ids);
% Gives an estimated standard deviation expected for each cell based on the 
% size of the cell using the measured relationship between size and noise
% in this particular dataset.  
% It is both predicted and empirically clear that the square root of the
% number of pixels (size) is proportional to the noise of the brightness
% when averaged over the pixels.  This is used to remove the contribution
% of size to the noise of the cells, which then allows measurement of the
% general noisiness of pixels in this movie using the median, since this is
% reltively robust to outliers.  Size is then reintroduced with the 
% relationship described above to calculate the noise each cell will have 
% based on it's size.  This method largely eliminates error resulting from 
% highly active cells changing the pixel-wise noise estimates.

contours = handles.app.experiment.contourLines(clustered_contour_ids);
midx = 1;
nx = handles.app.experiment.Image(midx).nX;
ny = handles.app.experiment.Image(midx).nY;
contourpixels = cell(1,numcells);
pixpercell = zeros(1,numcells);

h = waitbar(0, 'Calculating masks from contours.  Please wait.');

for cidx = 1:numcells    %for each cell
    %%%%INSIDE LOOP... GET RID OF LOOP?
%get the pixels in that cell
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
    %indices in image.
    %cidx{c} = sub2ind(size(image), cidxy, cidxx);% contour indices in image.
end
close(h);

% stdpercell = std(smoothsig(cidx,:),1,2);
stdpercell = std(rastermap,1,2);%standard dev over time for each cell
% figure;
% subplot(5,1,1);
% plot(pixpercell,stdpercell,'.');
% subplot(5,1,5);
% plot(pixpercell,stdpercell,'.');

noiseconst = stdpercell'.*pixpercell.^.5;
% subplot(5,1,2);
% plot(pixpercell,noiseconst,'.');
% subplot(5,1,4);
% plot(pixpercell,noiseconst,'.');
% hold on
% plot([min(pixpercell) max(pixpercell)],[median(noiseconst) median(noiseconst)],'r')
% subplot(5,1,3);
% hold on;
% numbins = 1+3.332*log10(length(noiseconst));%Sturge's Rule
% hist(noiseconst,numbins);
% [y,x]=hist(noiseconst,numbins);%
noiseconst = median(noiseconst);
% plot([noiseconst noiseconst],[0 max(y)],'r');

%other ways of getting central tendency possible 
%1) bin and take value of max bin
%2) bin then max of cubic spline-interpolated bin fcn
% [y,x]=hist(noiseconst,numbins);%
% xx = 0:.1:max(noiseconst)+1;
% yy = spline(x,y,xx);
% plot(xx,yy,'r')
%3) remove outliers in systematic and iterative way

noiseconst = noiseconst*ones(size(stdpercell));
noisepercell = noiseconst'./(pixpercell.^0.5);%derive a noise expected for each cell, based on num of pixels
% subplot(5,1,5);
% hold on;
% plot(pixpercell,noisepercell,'.','color','r')
