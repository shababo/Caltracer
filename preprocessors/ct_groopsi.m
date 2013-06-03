function x = ct_groopsi(x, handles, options)
% This function prepares and runs fast oopsi on the traces as a
% preprocessor in caltracer.

%Conrad's fast_oopsi code
F=x;
Ncells = size(F,1);
V.dt=handles.app.experiment.timeRes;
if ~isfield(V,'frSR'), V.frSR = input('\nat what frame rate would you like to resolve the inference (in Hz)?: ');end
P.lam=options.Plam.value;
idxlist=options.idxlist.value;

if ~isempty(idxlist)
    for i=1:length(idxlist)
        trace=F(idxlist(i),:);
        fprintf('\nneuron %d\n',i);
        fprintf('running spike inference...\n');
        [n test.P test.V]= fast_oopsi(trace,V,P);
        struct{i}.P = test.P;
        struct{i}.n = n;
        spikes{i}=struct{i}.n;
        spikes{i}=spikes{i}/max(spikes{i});
        x(i,:)=spikes{i};
        V.F{i}=F(1,:);
    end
else
    for i = 1:size(F,1)
        trace=F(i,:);
        fprintf('\nneuron %d\n',i);
        fprintf('running spike inference...\n');
        [n test.P test.V]= groopsi(trace,V,P);
        struct{i}.P = test.P;
        struct{i}.n = n;
        spikes{i}=struct{i}.n;
        spikes{i}=spikes{i}/max(spikes{i});
        x(i,:)=spikes{i};
        V.F{i}=F(1,:);
    end
end


% rawF=x;
% Ncells = size(rawF,1);
% 
% V.dt=handles.app.experiment.timeRes;
% P.lam=options.Plam.value;
% V.posspiketimes = 50:options.brpoints.value:size(rawF,2);
% tau=0.8; %1;
% P.gam = (1-V.dt/tau)';
% P.a = 1.5;
% 
% spikes = cell(size(rawF,1),1); % spike inference output vector
% struct = cell(size(rawF,1),1); % spike inference output struct
% indices = ones(size(rawF,1),1);
% n = zeros(size(rawF,2),1);
% x = zeros(size(rawF));
% for i = 1:size(rawF, 1)
%     fprintf('\nneuron %d\n',i);
%     Fcell = rawF(i,:);
%     Fcell = detrend(Fcell,'linear',V.posspiketimes);
%     Fcell=Fcell-min(Fcell); Fcell=Fcell/max(Fcell); Fcell=Fcell+eps;
%     P.b = median(Fcell);
%     fprintf('running spike inference...\n');
%     
%     [n test.P test.V]= fast_oopsi(Fcell,V,P);
%         
%         struct{i}.P = test.P;
%         struct{i}.n = n;
%         spikes{i}=struct{i}.n;
%         spikes{i}=spikes{i}/max(spikes{i});
%         x(i,:)=spikes{i};
%         V.F{i}=Fcell(1,:);   
% end