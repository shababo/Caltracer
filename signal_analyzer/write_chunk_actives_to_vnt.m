function write_chunk_actives_to_vnt(obj,ev);

analyzerHandles = guidata(obj);

chunknum = get(analyzerHandles.handles.chunksListBox,'value');
if length(chunknum) ~= 1
    errordlg('Must have exactly one chunk selected');
    return
end
chunk = analyzerHandles.data.activitymtxs{chunknum};
actives = find(sum(chunk,2));

allcontours = analyzerHandles.data.contours;
activecoords = cell(1,1);
for aidx = 1:length(actives);
    thiscell = actives(aidx);
    thiscont = allcontours{thiscell};
    if size(thiscont,1) == 10 && size(thiscont,2)==2;
        if thiscont == (Inf*ones(10,2));%if a dummy out of frame coordinate
            %(ie from conversion to parallel image)...
            continue%then skip it
        end
    end
    activecoords{1,end+1} = ct_centroid(thiscont);
end
activecoords(1) = [];
targetsmatrix = reshape(cell2mat(activecoords),[2,length(activecoords)]);


%% set up for asking user about default values for targets
defaulttime = 1;
defaultpower = 100;%pockels cell voltage
defaulttype = 0;%imaging vs stimulation target
defaultexecution = 1;

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
defaultfiller = repmat(defaultfiller,[1, size(targetsmatrix,2)]);
targetsmatrix = [targetsmatrix;defaultfiller]; 

vntname = [analyzerHandles.data.chunkNames{chunknum},'.vnt'];
[FileName,PathName] = uiputfile('.vnt','Save .vnt file',vntname);

if FileName == 0 & PathName == 0
    return
end

ct_writevnt([PathName FileName],targetsmatrix);