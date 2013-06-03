%% preprocessing options
function Fprocess = preprocessdata(traces)
Ncells=size(traces,1);
artifactopt=0;%input('\n artifact remover: ');
detrendopt=1;%input('\n detrend: ');
filteropt=0;%input('\n filter: ');
dfofopt=1;%input('\n dfof: ');
normopt=0;%input('\n normalize: ');

for i=1:Ncells
F=traces(i,:);

%remove artifacts
if artifactopt==1
Fdiff=diff(F);
artifact=find(abs(Fdiff-mean(Fdiff)) > 3*std(Fdiff)); %was artifact=find(abs(Fdiff-mean(Fdiff)) > 5*std(Fdiff));
F(artifact)=median(F);
end

%filter
if filteropt==1
    sr = 3;%sr is sample frequency
    fc=0.02;% cut off frequency
    fn=sr/2; %nyquivst frequency = sample frequency/2;
    order = 6; %6th order filter, high pass
    [b14 a14]=butter(order,(fc/fn),'high');
    F = filtfilt(b14, a14, F);

% a=1; %1;
% F=filter([1-a a-1], [1 a-1], F);  %F=filter(a, [1 a-1], F);
% F(1:2)=median(F);
end

%detrend F
if detrendopt==1
F=F';
time=(1:1:length(F))';
F=msbackadj(time,F)';
end

%dfof F
if dfofopt==1
fo=medfilt1(F,51);
F=(F-fo)./mean(fo);
% F(process1)=median(F);
% F(1:200)=detrend(F(1:200),'linear');
% F(length(F)-200:length(F))=detrend(F(length(F)-200:length(F)),'linear');
end
%normalize F
if normopt==1
F=(F-min(F))/(max(F)-min(F));
end

Fprocess(i,:)=F;

end
end