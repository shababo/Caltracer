function handles = adjust_overlap(handles)
% This function adjusts the countours based on overlap.
% It will delete certain contours based on the selections in the
% consolidate maps gui.

% Updated 7/30/09 -MD


% % Find out what action the user would like.
do_delete_rest = uiget(handles, 'consolidatemaps', 'eliminateoverlap', 'value');
do_delete_overlap = uiget(handles, 'consolidatemaps', 'eliminaterest', 'value');
adjust_action = 'keep';
if (do_delete_rest)||(do_delete_overlap)
    adjust_action = 'delete';
end

switch adjust_action 
    case 'keep'			
        %do nothing (bw)
    case 'delete'			
        nregions = handles.app.experiment.numRegions;
        nummasks = handles.app.experiment.numMasks;

        for r = 1:nregions
            nmovie_contours = length(handles.app.experiment.regions.contours{r}{1});
            if (nmovie_contours < 1) % no movie contours in this region.
                continue;
            end
            for n= 1:nummasks
                tokill{n} = find (handles.app.experiment.overlapsInfo{r}{n}(:,1));
                handles.app.experiment.regions.contours{r}{n}(tokill{n}) = [];
                if n==1
                handles.app.experiment.contourMaskIdx{r}(tokill{n}) = [];
                end
            end
        end 
    otherwise
        errordlg('Case not implemented yet.');
end 