function all_centroids_to_vnt_repeat(handles)

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
NumCells=size(targetsmatrix,2);

%% ask user about randomization options and do them
button=questdlg('Do you want to randomize the order of the base set of centroids or keep your current order?');
if isempty(button) || strcmp(button,'Cancel')
    return
end
if strcmp(button,'Yes')
    [trash,idx]=sort(rand(1,NumCells));
    targetsmatrix=targetsmatrix(:,idx);
end

NumIterations=inputdlg('Number of Iterations','',1,{'6'});
if isempty(NumIterations)
    return
end

PromptStr='How to iterate the base set of centroids';
ListStr={'Do not randomize each iteration differently' ...
    'Randomize each iteration differently' ...
    'Randomize each iteration differently EXCEPT the first and last'};
[Selection,ok]=listdlg('PromptString',PromptStr,'SelectionMode','single', ...
    'ListSize',[320 300],'ListString',ListStr);
if ok ==0
    return
end

NumCells=size(targetsmatrix,2);
NumIterations=str2num(NumIterations{1});
switch Selection
    case 1
        targetsmatrix=repmat(targetsmatrix,1,NumIterations);
    case 2
        for i=1:NumIterations-1
            [trash,idx]=sort(rand(1,NumCells));
            NewTargetOrder=targetsmatrix(:,idx);
            targetsmatrix=[targetsmatrix NewTargetOrder];
        end
    case 3
        FirstSequence=targetsmatrix;
        for i=1:NumIterations-2
            [trash,idx]=sort(rand(1,NumCells));
            NewTargetOrder=targetsmatrix(:,idx);
            targetsmatrix=[targetsmatrix NewTargetOrder];
        end
        targetsmatrix=[targetsmatrix FirstSequence];
end

%% ask user about filename and write it
vntname = [handles.app.experiment.fileName(1:end-4),'.vnt'];
[FileName,PathName] = uiputfile('.vnt','Save .vnt file',vntname);

if FileName == 0 & PathName == 0
    return
end

ct_writevnt([PathName FileName],targetsmatrix);