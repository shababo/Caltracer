function write_chunk_sequence_to_vnt(obj,ev);

analyzerHandles = guidata(obj);

chunknum = get(analyzerHandles.handles.chunksListBox,'value');
if length(chunknum) ~= 1
    errormsg('Must have exactly one chunk selected');
    return
end
chunk = analyzerHandles.data.onsmtxs{chunknum};

%% reorder chunk by when each cell first fires

chunk = local_keepfirstonevent(chunk);%ELIM ALL AFTER FIRST ON
framemtx = repmat(1:size(chunk,2),[size(chunk,1),1]);%each column has framenum
chunk = chunk .* framemtx;%make so each on has which frame it's in
chunk =  sum(chunk,2);%zero if cell never fired, otherwise, framenum of when fired
actives = find(sum(chunk,2));%find active cells
[framenums,idxs] = sort(chunk(actives));%sort active cells by framenum, this gives ordered frames
seqactives = actives(idxs);%convert to cellnums ordered by frames

%sequence of cells in targets file is determined by when they're called in
%loop below (so rearranged order of cells to loop thru)
allcontours = analyzerHandles.data.contours;%get contours
activecoords = cell(1,1);%blank for later - list of coordinates in order
for saidx = 1:length(seqactives);%for each active cell
    thiscell = seqactives(saidx);
    thiscont = allcontours{thiscell};
    if size(thiscont,1) == 10 && size(thiscont,2)==2;%skip dummies
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


%%
function ons=local_keepfirstonevent(ons);
%Eliminates anytime a cell that does not come on in consecutive frames...
%ie if a cell is on then off then on again, it eliminates the 2nd on again.
%It keeps the first event, even if that includes consecutive frames of "on"
%in a row.

summed = cumsum(ons,2);
keep = summed.*ons;
ons(keep~=1) = 0;%keep only first on of first event


% a=diff(ons,1);%find on/off events
% a(end+1,1)=0;%add a frame of zeros to make this the same length as ons
% a=(a==-1);%find all "off" events, set them equal to 1... a matrix of offs now
% 
% a=cumsum(a);%all on events
% a=a>0;%tells you all points at or after first off event
% a(end,:)=0;
% a=circshift(a,1);%past two steps were to shift all points down by one frame... so that we can find all points after first off, not including first off
% % b=b.*aaa;%keep only ons that are after the first off
% 
% ons(a)=0;
