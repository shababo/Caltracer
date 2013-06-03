workspace=who;



% correlations within trials



s=1;

t=1;

mintime = 15000;
maxtime = 25000;
belowthresh = -15;
abovethresh = 20;

for i=1:length(workspace)

    channels=fieldnames(eval(workspace{i}));
    channels(end) = [];

    for j = 1:length(channels)
        cell = eval([workspace{i} '.' channels{j}]);
        stim_art= find(abs(diff(cell) > 20)); %find the stim artifacts
        not_stim1 = find(stim_art < 40000); %get rid of any sharp rise/fall that are not artifacts
        not_stim2 = find(stim_art > 43000);
        not_stim = union(not_stim1, not_stim2);
        stim_art(not_stim) = [];
        
        a = [find(diff(stim_art) > 50)]'; %find breaks between artifacts
        a = [a, length(stim_art)]; %add back last artifact
        for b = 1:length(a);
            c(b,:) = (stim_art(a(b))-8: stim_art(a(b)) + 2); %use indices
        end
        cell(c) = [];
        basemean(i,j) = findbasemean(cell);
        belowperiods = continuousbelow(cell(41280:60000), basemean(i,j), belowthresh, mintime, maxtime);
        aboveperiods = continuousabove(cell(41280:60000), basemean(i,j), abovethresh, mintime, maxtime);
        traces_detrended{i,j} = 'none';
        if ~isempty(belowperiods)
            cell = detrendTM(cell); %filter out low frequency garbage
            traces_detrended{i,j} = [workspace{i} '.' channels{j}];
        end
        if ~isempty(aboveperiods)
            cell = detrendTM(cell); %filter out low frequency garbage
            traces_detrended{i,j} = [workspace{i} '.' channels{j}];
        end
        cell_short = cell(40000:65000); %will correlate traces between 4s and 6s
                
        cell_noart_detrend(j,:) = cell(25000:85000);

        cell_noart_detrend_short(j,:) = cell_short;
        stim_art = [];
        belowperiods = [];
        aboveperiods = [];
    end
    
%     for k = 1:size(cell_noart_detrend,1) -1
%         
%         for m = k:size(cell_noart_detrend,1) -1
%             
%             [tempcorr pp] = corrcoef(cell_noart_detrend_short(k,:), cell_noart_detrend_short(m+1,:)); %correlating traces pairwise
%             r(s) = tempcorr(1,2);
%             corr_p(s) = pp(1,2);
%             s = s+1;
% 
%         end
%     end
    corr_range = 25000; %range of data to correlate after stim in samples
    
    for p = 1:size(cell_noart_detrend,1) -1
       
        for q = p:size(cell_noart_detrend,1) -1
           
            sc = circshift(cell_noart_detrend(p,:), [0 -corr_range]); %shift trace 1 by 2 seconds back
            rsc_temp = zeros(2*corr_range/10,1);
            for ss = 1:2*corr_range/10
                sc = circshift(sc, [0 10]); %shift trace forward by 1ms
                tempcorr_sc = corrcoef(cell_noart_detrend(q+1,15000:15000+corr_range), sc(15000:15000+corr_range)); %correlate 
                rsc_temp(ss) = tempcorr_sc(1,2);            
            end
            rsc(:,t) = rsc_temp; %add correlations to matrix rsc; each column is a correlation between a cell pair 
            t = t+1;
        end
    end
 
  for cc = 1: size(rsc,2)
      r_rsc(cc) = rsc(corr_range/10, cc);
  end
      
     
cell_noart_detrend = [];     
end

%plot correlation
for rr = 1:size(rsc,2)
    figure;
    plot(-corr_range/10 +1:corr_range/10, rsc(:,rr))
end




% r2=r.^2;
r2_rsc = r_rsc.^2;
% meanr2 = mean(r2);
% varr2 = var(r2);






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
