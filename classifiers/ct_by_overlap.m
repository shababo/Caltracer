function [result, data, param] = ct_by_overlap(data, handles, clustered_contour_ids,cluster_sizes,options)

% This function clustes the cells by the tags created if overlap was found
% when in combination with mask contours.
experiment = handles.app.experiment;
param = [];
param.clusterValidity.value = 0;
nregions = experiment.numRegions;
result.data.f = zeros(size(data,1),2);

for r = 1:nregions
    nmovie_contours = length(handles.app.experiment.regions.contours{r}{1});
    for mc = 1:nmovie_contours
        tag = get(handles.guiOptions.face.handl{r}{1}(mc), 'Tag');
        if strcmp( tag, 'cellcontour-overlap')
          
        
                result.data.f(mc,1) = 1;
        else
                result.data.f(mc,2) = 1;
         

            
            
        end
        
    end 
end