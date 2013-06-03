function [inference deltaF Fcell_all] = stim_spike_inference(rawF)

%inputs
%rawF  - fluorescence traces in a matrix (nNeurons x nFrames) imported
%directly as txt files from image J

%outputs
% inference - matrix (nNeurons x nFrames)

%% RUN FOOPSI

V.dt = .015;

%%convert rawF to a format usable by foopsi
d = 1;
delete(1) = 1;

%delete every other column which are just contour number
for dd = 2:size(rawF,2)-1
    delete(dd) = delete(dd-1) + 2;
end
delete = delete(find(delete<(size(rawF,2))));
rawF(:,delete) = [];

%find contours that were excluded and remove them so NaN entries are
%removed, and foopsi will work
Ni = 1;
for N = 1:size(rawF,2)
    if isnan(rawF(:,N))
        delete_NaN(Ni) = N;
        Ni = Ni + 1;
    end
end

if exist('delete_NaN', 'var') == 1;
rawF(:,delete_NaN) = [];
end

rawF(:,1) = [];

%create deltaF
for n = 1:size(rawF,2)
    baseline = mean(rawF(1:200,n));
    deltaF(:,n) = (rawF(:,n)-baseline)/baseline;
    baseline = [];
end

%reshape so in appropriate format for foopsi
rawF = rawF';
Ncells = size(rawF,1);

P.lam= 2;
tau=1;
P.gam = (1-V.dt/tau)';
P.a = 1.5; 

for i = 1:size(rawF, 1)
    Fcell = rawF(i,:);
    Fcell = -detrend(Fcell); %detrend and normalize rawF
    Fcell=Fcell-min(Fcell); Fcell=Fcell/max(Fcell); Fcell=Fcell+eps;
    P.b = median(Fcell);
    Fcell_all{i} = Fcell;
    n = fast_oopsi(Fcell, V, P);
    inference{i} = n;
end


%% draw the gui
handle = figure;
figure(handle);
k=1; kmin=1; kmax=Ncells;
indices = ones(Ncells,1);
plot_callback;
set(gcf,'Color','w','Toolbar','figure');
guidata(handle,indices);

hb = uicontrol(...
    'Style', 'togglebutton',...
    'String', 'Exclude',...
    'Units','normalized',...
    'Position', [0 0 .1 .04],...
    'Callback',@clicked_callback);
ha = uicontrol(gcf,...
    'Style','slider',...
    'Min' ,kmin,'Max',kmax,...
    'Units','normalized',...
    'Position',[.1 0 .9 .04],...
    'Value', k,...
    'SliderStep',[1/(kmax-kmin) 1/(kmax-kmin)],...
    'Callback',@plot_callback);
% wait until the window is closed before exiting
uiwait;


    function k=plot_callback(handle, eventdata, handles) %#ok<INUSD>

        % move the scroll bar
        if exist('ha','var')
            indices = guidata(gcbo);
            k = round(get(ha,'Value'));
        else
            k = 1;
        end

        % plot fluorescence
        ax(1) = subplot(2,1,1);
        cla; plot(-deltaF(:,k),'k');
        mstats = 0;


        % plot inference output
        ax(2) = subplot(2,1,2);
        cla; bar(inference{k},'k');


%         link the axes
        linkaxes(ax,'x');
    end

    function c=clicked_callback(handle, eventdata, handles) %#ok<INUSD>
        % flip the bit at the appropriate index
        c = get(hb,'Value');
        k = get(ha,'Value');
        % update the data
        indices = guidata(gcbo);
        % save out our modifications
        if indices(k), indices(k) = 0; else indices(k) = 1; end;
        guidata(gcbo,indices);
        plot_callback;
        assignin('base','indices', indices);
    end
end
