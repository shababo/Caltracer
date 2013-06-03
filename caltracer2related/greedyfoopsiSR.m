%first find a typical spike transient, call it spike...
function [nhat, spikeidx, spiketimes]=greedyfoopsiSRstop(data)

clear MAP;
clear MAPcut;
clear baseline;
clear R_2;
clear low;
clear time;
clear F

F=data';
time=(1:1:length(F))';

%preprocessing options
artifactopt=1;%input('\n artifact remover: ');
filteropt=input('\n filter: ');
dfofopt=input('\n dfof: ');
detrendopt=1;%input('\n detrend: ');
normopt=input('\n normalize: ');

%remove artifacts
% if artifactopt==1
% Fdiff=diff(F);
% artifact=find(abs(Fdiff-mean(Fdiff)) > 5*std(Fdiff));
% F(artifact)=median(F);
% end

%filter
if filteropt==0
a=1;
F=filter(a, [1 a-1], F);
F(1:2)=median(F);
end

%dfof F
if dfofopt==1
fo=medfilt1(F,400);
F=(F-fo)./mean(fo);
F(1)=median(F);
F(1:200)=detrend(F(1:200),'linear');
F(length(F)-200:length(F))=detrend(F(length(F)-200:length(F)),'linear');
end

%detrend F
if detrendopt==1
% chnk=round(T/(fr*2));
% bp=[round(T/chnk):round(T/chnk):T];
% F=detrend(F,'linear',bp);
F=msbackadj(time,F)';
end

%normalize F
if normopt==1
F=(F-min(F))/(max(F)-min(F));
end

%define experimental parameters
fr=input('\nframe rate for the movie (in Hz): ');
dt=1/fr;
frNopt=input('\nsuper-resolution [0=n 1=y]?: ');
if frNopt==1
    frN=10;%input('\nframe rate of super-resolution (in Hz): ');
else
frN=fr;
end

conv=round(dt*frN);

%w=length(F);
%define likelihood parameters
low=F(abs(F)<(mean(F)+.6*std(F)));
b=median(low);
clength=300*conv;
F(length(F):length(F)+clength/conv)=b;
w=length(F);
sig=(median(abs(F(:)-median(F))))/1.4785;
tau = 40*conv/fr;
gam=(1-dt/tau);

wN=w*conv;

MAPinit=zeros(1,wN,w);
MAP=zeros(1,w);


holder = zeros(1,w);
const = -1/(2*(sig)^2);

location=0;

CF=zeros(1,w);


cholder=zeros(1,clength);
%------------------------------------------------------------
cholder(1)=(1-b)/4;
%C=(zeros(wN,wN));
Fbig=(repmat(F,wN,1));
nhat=zeros(wN,1);
for ccount=1:clength-1
    cholder(ccount+1)=gam*cholder(ccount);
end
spikeval=0;
vector=(0:length(cholder)-1);
cmat=repmat(cholder,wN,1);
C=full(spdiags(cmat,vector,wN,wN));
C=downsample(C',conv);
C=C';
CFbig=repmat(CF,wN,1);
checkwindow=6;
baseline(1:length(F))=b;
trackerval=zeros(checkwindow,1);
trackerloc=zeros(checkwindow,1);
h=2;
storedspikes=zeros(checkwindow,1);
while h ~= 1
    
    Ctemp=bsxfun(@plus,C,CF);
    
    MAPinit(1,:,:)=const*(Fbig-Ctemp-b).^2;
    
    MAP=sum(MAPinit,3);
    MAPcut(1,:)=MAP(1,1:length(MAP(1,:))-(clength+1));
    mcut1=MAPcut(1,:);
    
    [p o]=max(MAPcut);
    location=o;
    spikeval=1;
    
    
    location
    if sum(1+nhat)<checkwindow+1
        storedspikes(sum(nhat))=location+2;
    else
        storedspikes(1)=[];
        storedspikes(checkwindow)=location+2;
    end
    nhat(2+location)=nhat(2+location)+spikeval;
    
    Cwin=zeros(1,w);
    
    Cwin=C(location,:);
    
    CF=CF+Cwin;
    
    %sstot=sum(((F-CF)-mean(F-CF)).^2);
    %sserr=sum(((F-CF)-b).^2);
    CFsort=sort(F-CF);
    top=CFsort(round(length(CFsort)/2):length(CFsort));
    R_2(sum(nhat))=sum(abs(mcut1));%std(mcut1);%1-(sserr/sstot);
    
    [val loc]=min(R_2);
    
    if sum(nhat)<=6
        trackerval(sum(nhat))=val;
        trackerloc(sum(nhat))=loc;
    else
        trackerval(1)=[];
        trackerloc(1)=[];
        trackerval(6)=val;
        trackerloc(6)=loc;
    end
    
    [g h]=min(trackerval);
    
    
    
end

if sum(nhat)>6
for erase=1:length(storedspikes)
    nhat(storedspikes(erase))=0;
end
end
spikeidx=find(nhat);
spiketimes=spikeidx/frN;

disp('done');
