

%This function will go through the files in correlation and pick out the r2
%values in each experiment. It will then plot them with a line graph on one
%plot. y-axis will be corr coef x axis either 0,V or -70mV

folders = dir('C:\Tanya_Data\Physiology\workspace\correlation');

for i = 1:length(folders)
    if (strcmp(folders(i).name, '.') == 0);
        if (strcmp(folders(i).name, '..') == 0);
        Thisfolder = fullfile('C:\Tanya_Data\Physiology\workspace\correlation', folders(i).name);
        exc = fullfile(Thisfolder, '-70mV');
        inh = fullfile(Thisfolder, '0mV');
        
        %for sf
        exc_sf = fullfile(exc, 'sf');
        sf70 = open([exc_sf '.' 'mat']);
        inh_sf = fullfile(inh, 'sf');
        sf0 = open([inh_sf '.' 'mat']);
        meanr2_70sf(i-2) = sf70.meanr2;
        meanr2_0sf(i-2) = sf0.meanr2;
        varr2_70sf(i-2) = sf70.varr2;
        varr2_0sf(i-2) = sf0.varr2;
        
       
        %for snf
        exc_snf = fullfile(exc, 'snf');
        snf70 = open([exc_snf '.' 'mat']);
        inh_snf = fullfile(inh, 'snf');
        snf0 = open([inh_snf '.' 'mat']);
        meanr2_70snf(i-2) = snf70.meanr2;
        meanr2_0snf(i-2) = snf0.meanr2;
        varr2_70snf(i-2) = snf70.varr2;
        varr2_0snf(i-2) = snf0.varr2;
        
        %for nsf
        exc_nsf = fullfile(exc, 'nsf');
        nsf70 = open([exc_nsf '.' 'mat']);
        inh_nsf = fullfile(inh, 'nsf');
        nsf0 = open([inh_nsf '.' 'mat']);
        meanr2_70nsf(i-2) = nsf70.meanr2;
        meanr2_0nsf(i-2) = nsf0.meanr2;
        varr2_70nsf(i-2) = nsf70.varr2;
        varr2_0nsf(i-2) = nsf0.varr2;
        
        %for nsnf
        exc_nsnf = fullfile(exc, 'nsnf');
        nsnf70 = open([exc_nsnf '.' 'mat']);
        inh_nsnf = fullfile(inh, 'nsnf');
        nsnf0 = open([inh_nsnf '.' 'mat']);
        meanr2_70nsnf(i-2) = nsnf70.meanr2;
        meanr2_0nsnf(i-2) = nsnf0.meanr2;
        varr2_70nsnf(i-2) = nsnf70.varr2;
        varr2_0nsnf(i-2) = nsnf0.varr2;
        
        
        %for asf
        exc_asf = fullfile(exc, 'asf');
        asf70 = open([exc_asf '.' 'mat']);
        inh_asf = fullfile(inh, 'asf');
        asf0 = open([inh_asf '.' 'mat']);
        meanr2_70asf(i-2) = asf70.meanr2;
        meanr2_0asf(i-2) = asf0.meanr2;
        varr2_70asf(i-2) = asf70.varr2;
        varr2_0asf(i-2) = asf0.varr2;
        
        % for asnf
        exc_asnf = fullfile(exc, 'asnf');
        asnf70 = open([exc_asnf '.' 'mat']);
        inh_asnf = fullfile(inh, 'asnf');
        asnf0 = open([inh_asnf '.' 'mat']);
        meanr2_70asnf(i-2) = asnf70.meanr2;
        meanr2_0asnf(i-2) = asnf0.meanr2;
        varr2_70asnf(i-2) = asnf70.varr2;
        varr2_0asnf(i-2) = asnf0.varr2;
        
        end    
    end
end

figure;
hold on;

colors = 'rgbmcykrgbmcyk';
for j = 1:length(meanr2_70sf);
    errorbar([meanr2_70sf(1,j), meanr2_0sf(1,j)], [varr2_70sf(1,j), varr2_0sf(1,j)], colors(j));
end


% figure;
% hold on;
% 
% colors = 'rgbmcykrgbmcyk';
% for k = 1:length(meanr2_70snf);
%     errorbar([meanr2_70snf(1,k), meanr2_0snf(1,k)], [varr2_70snf(1,k), varr2_0snf(1,k)], colors(k));
% end
% 
% figure;
% hold on;
% 
% for l = 1:length(meanr2_70snf);
%     errorbar([meanr2_70snf(1,l), meanr2_0sf(1,l)], [varr2_70snf(1,l), varr2_0sf(1,l)], colors(l));
% end
% 
% % colors = 'rgbmcykrgbmcyk';
% % for l = 1:length(meanr2_70nsnf);
% %     errorbar([meanr2_70nsnf(1,l), meanr2_0nsnf(1,l)], [varr2_70nsnf(1,l), varr2_0nsnf(1,l)], colors(l));
% % end
% % 
% % figure;
% % hold on;
% % 
% % colors = 'rgbmcykrgbmcyk';
% % for m = 1:length(meanr2_70nsf);
% %     errorbar([meanr2_70nsf(1,m), meanr2_0nsf(1,m)], [varr2_70nsf(1,m), varr2_0nsf(1,m)], colors(m));
% % end
% 
% figure;
% hold on;
% 
% colors = 'rgbmcykrgbmcyk';
% for n = 1:length(meanr2_70asf);
%     errorbar([meanr2_70asf(1,n), meanr2_0asf(1,n)], [varr2_70asf(1,n), varr2_0asf(1,n)], colors(n));
% end
% 
% figure;
% hold on;
% 
% colors = 'rgbmcykrgbmcyk';
% for p = 1:length(meanr2_70asnf);
%     errorbar([meanr2_70asnf(1,p), meanr2_0asnf(1,p)], [varr2_70asnf(1,p), varr2_0asnf(1,p)], colors(p));
% end
% 
