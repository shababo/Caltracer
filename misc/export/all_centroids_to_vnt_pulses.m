function all_centroids_to_vnt_pulses(handles)

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

%% ask user about randomization/iteration options and do them
button=questdlg('Do you want to randomize the order of the base set of centroids or keep your current order?');
if isempty(button) || strcmp(button,'Cancel')
    return
end
if strcmp(button,'Yes')
    [trash,idx]=sort(rand(1,NumCells));
    targetsmatrix=targetsmatrix(:,idx);
end

NumPulsesQuestion1=sprintf('How many pulses per cell?\n(i.e. how many times do you want to list each target?)');
NumPulsesQuestion2=sprintf('\n(Remember - no need for Vovan Protocol in Vovan Fluoview!)');
NumPulsesQuestion=[NumPulsesQuestion1 NumPulsesQuestion2];
NumPulses=inputdlg({NumPulsesQuestion},'',1,{'3'});
if isempty(NumPulses)
    return
end
NumPulses=str2double(NumPulses);

NumIterations=inputdlg('Number of Iterations','',1,{'6'});
if isempty(NumIterations)
    return
end
NumIterations=str2double(NumIterations);

TargetsWithPulses=zeros(6,NumCells*NumPulses);
for i=0:NumCells-1
    for j=0:NumPulses-1
        TargetsWithPulses(:,i*NumPulses+j+1)=targetsmatrix(:,i+1);
    end
end

if NumIterations == 1
    targetsmatrixOUT=TargetsWithPulses;
else
    PromptStr='How to iterate the base set of centroids';
    ListStr={'Do not randomize each iteration differently' ...
        'Randomize each iteration differently' ...
        'Randomize each iteration differently EXCEPT the first and last'};
    [Selection,ok]=listdlg('PromptString',PromptStr,'SelectionMode','single', ...
        'ListSize',[320 300],'ListString',ListStr);
    if ok ==0
        return
    end

    TargetsWithPulsesAndIterations=[];
    switch Selection
        case 1
            TargetsWithPulsesAndIterations=repmat(TargetsWithPulses,1,NumIterations);
        case 2
            TempMatrixToRandomize=TargetsWithPulses;
            for i=1:NumIterations;
                input=TempMatrixToRandomize;
                columnspergroup=NumPulses;
                output=reshape(input,[size(input,1)*columnspergroup size(input,2)/columnspergroup]);
                cols=randperm(size(output,2));
                output=output(:,cols);
                output=reshape(output,size(input));
                TempMatrixToRandomize=output;
                TargetsWithPulsesAndIterations=[TargetsWithPulsesAndIterations TempMatrixToRandomize];
            end;
        case 3
            FirstSequence=TargetsWithPulses;
            LastSequence=TargetsWithPulses;
            TempMatrixToRandomize=TargetsWithPulses;
            for i=1:(NumIterations-2);
                input=TempMatrixToRandomize;
                columnspergroup=NumPulses;
                output=reshape(input,[size(input,1)*columnspergroup size(input,2)/columnspergroup]);
                cols=randperm(size(output,2));
                output=output(:,cols);
                output=reshape(output,size(input));
                TempMatrixToRandomize=output;
                if i==1
                    TargetsWithPulsesAndIterations=[FirstSequence TempMatrixToRandomize];
                else
                    TargetsWithPulsesAndIterations=[TargetsWithPulsesAndIterations TempMatrixToRandomize];
                end
            end
            TargetsWithPulsesAndIterations=[TargetsWithPulsesAndIterations LastSequence];
    end
    targetsmatrixOUT=TargetsWithPulsesAndIterations;
end
%% ask user about filename and write it
vntname = [handles.app.experiment.fileName(1:end-4),'.vnt'];
[FileName,PathName] = uiputfile('.vnt','Save .vnt file',vntname);

if FileName == 0 & PathName == 0
    return
end

ct_writevnt([PathName FileName],targetsmatrixOUT);