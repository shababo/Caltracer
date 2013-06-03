function aps=findaps1(data,varargin)
% function aps=findaps2(data,varargin);
%
%finds action potentials in a current clamp (Vm) trace

if nargin==2;
    mode=varargin{1};
else
    mode='points';
end

thresh = -20;

aps=[];
data=reshape(data,[1 numel(data)]);
% if mean(data)>-50 | mean(data)<-85;
%     disp('Cell appears to have been unhealthy, mean of trace is not between -55mV and -85.');
% end


trash=find(data>thresh);
if ~isempty(trash);
    aboveperiods=continuousabove(data,zeros(size(data)),thresh,2,200);%find series
        %of points above -20mV (must be between 2 and 200 points long);
    switch lower(mode)
        case 'points'
            for b=1:size(aboveperiods,1);%for each ap found
                [trash,d]=max(data(aboveperiods(b,1):aboveperiods(b,2)));%find max value
                d=aboveperiods(b,1)+d-1;
                aps(b)=d;
            end
        case 'durations'
            aps=aboveperiods;
    end
end