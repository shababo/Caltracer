
 

workspace=who;

 

%% correlations within trials

 

s=1;

for i=1:length(workspace)

    channels=fieldnames(eval(workspace{i}));

    for j=1:length(channels)-2

        for k=1:length(channels)-2

            tempname1=[workspace{i} '.' channels{j}];

            tempname2=[workspace{i} '.' channels{j+1}];

            tempcorr=corrcoef(eval(tempname1),eval(tempname2));

            r(s)=tempcorr(1,2);

            s=s+1;

        end

    end

end

 

r=unique(r)'; % code is stupid, and computes some things twice, so i remove them

r2=r.^2;

mean(r2)

var(r2)

 

% %% shuffled trials
% 
%  
% 
% s=1;
% 
% for i=1:length(workspace)-1
% 
%     channels1=fieldnames(eval(workspace{i}));
% 
%     for l=1:length(workspace)-1
% 
%         if ~strcmp(workspace{i},workspace{l})
% 
%             channels2=fieldnames(eval(workspace{l}));
% 
%             for j=1:length(channels1)-1
% 
%                 for k=1:length(channels2)-1
% 
%                     tempname1=[workspace{i} '.' channels1{j}]
% 
%                     tempname2=[workspace{l} '.' channels2{k}]
% 
%                     temp1=eval(tempname1);
% 
%                     temp2=eval(tempname2);
% 
%                     T=min(length(temp1),length(temp2));
% 
%                     tempcorr=corrcoef(temp1(1:T),temp2(1:T));
% 
%                     rshuff(s)=tempcorr(1,2);
% 
%                     s=s+1
% 
%                 end
% 
%             end
% 
%         end
% 
%     end
% 
% end
% 
%  
% 
% rshuff=unique(rshuff)'; % code is stupid, and computes some things twice, so i remove them
% 
% r2shuff=rshuff.^2;
% 
% mean(r2shuff)
% 
% var(r2shuff)
% 

