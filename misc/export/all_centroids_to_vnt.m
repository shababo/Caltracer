function all_centroids_to_vnt(handles)

defaulttime = 5;
defaultpower = 0;%pockels cell voltage
defaulttype = 0;%imaging vs stimulation target
defaultexecution = 1;

%% set up for asking user about default values for targets
prompts = {'Target duration (ms)';'Pockels cell voltage (% of max)';...
    'Imaging (0) vs Stimuation (1) Type';'Execution: Yes(1) or No(0)'};
defans = [{num2str(defaulttime)};{num2str(defaultpower)};...
    {num2str(defaulttype)};{num2str(defaultexecution)}];
defaultfiller = inputdlg(prompts,'Default Target Values',1,defans);
if prod(size(defaultfiller))==0
    return
end

for didx = 1:size(defaultfiller,1);
    tempvar(didx,1) = str2num(defaultfiller{didx});
end
defaultfiller = tempvar;

%% create matrix to export to file
coords = handles.app.experiment.centroids;
targetsmatrix = reshape(cell2mat(coords),[2,size(coords,2)]);
defaultfiller = repmat(defaultfiller,[1, size(targetsmatrix,2)]);
targetsmatrix = [targetsmatrix;defaultfiller]; 

vntname = [handles.app.experiment.fileName(1:end-4),'.vnt'];
[FileName,PathName] = uiputfile('.vnt','Save .vnt file',vntname);

if FileName == 0 & PathName == 0
    return
end

ct_writevnt([PathName FileName],targetsmatrix);