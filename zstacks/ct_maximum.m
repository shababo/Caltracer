function [zstack, param] = ct_maximum(filename, pathname, sequential)
param.frameType = 'maximum';

fnm = [pathname filename];


if sequential==0
info = ct_tifinfo(fnm);
zstack = uint16(zeros(info.height,info.width,2));
h = waitbar(0, 'Creating maximum zstack.  Please wait.');
for c = 1:info.numframes    
    waitbar(c/info.numframes);
    zstack(:,:,2) = imread(fnm,c);
    zstack(:,:,1) = max(zstack,[],3);    
end
close(h);
zstack = double(zstack(:,:,1));
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
    h = waitbar(0, 'Creating maximum zstack.  Please wait.');
    for c = 1:numframes    
        filetomax= [pathname folderinfo(c).name];
        waitbar(c/numframes);
        zstack(:,:,2) = imread(filetomax);
        zstack(:,:,1) = max(zstack,[],3);    
    end
    close(h);
    zstack = double(zstack(:,:,1));
end
