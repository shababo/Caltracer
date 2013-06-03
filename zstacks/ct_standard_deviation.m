function [zstack, param] = ct_standard_deviation(filename, pathname,sequential)
param.frameType = 'standard_deviation';
% Fixed and updated with new Matlab 2008b (and newer) friendly version 7/28/09. -MD
% Updated for sequential use - 7/15/11.

fnm = [pathname filename];
info = ct_tifinfo(fnm);
zstack = zeros(info.height, info.width);
zsum = zeros(info.height, info.width);
zsumsquared = zeros(info.height, info.width);

h = waitbar(0, 'Creating standard deviation zstack.  Please wait.');
if sequential==0

    for c = 1:info.numframes;
        I = double(imread(fnm,c));
        zsum = zsum + I;
        zsumsquared = zsumsquared + I.^2;
        waitbar(c/info.numframes);
    end


else
    %If sequential stack is opened.
    zstack=[];
    folderinfo=dir(pathname);
    folderinfo=folderinfo(3:end);
    % if thumbs.db exists, ignore it in filecount.
    for s=1:length(folderinfo)
       if strcmp(folderinfo(s).name,'Thumbs.db')
           if s==length(folderinfo)
               folderinfo=folderinfo(1:end-1);
           else
               if s==1
               folderinfo=folderinfo(2:end);
               else
                   folderinfotemp=folderinfo(s+1:end);
                   folderinfo(s:end-1)=folderinfotemp;
                   folderinfo(end)=[];
               end
           end
       end
    end
    numframes=length(folderinfo);
    
    for c = 1:numframes;
        filetostd= [pathname folderinfo(c).name];
        I = double(imread(filetostd));
        zsum = zsum + I;
        zsumsquared = zsumsquared + I.^2;
        waitbar(c/numframes);
    end
    
    
end

    close(h);
    zstack = sqrt(1/info.numframes*zsumsquared-1/info.numframes^2*zsum.*zsum);
    zstack = real(zstack);