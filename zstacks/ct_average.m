function [zstack, param] = ct_average(filename, pathname,sequential)
param.frameType = 'average';
% Updated 7/15/11. -MD

fnm = [pathname filename];
if sequential==0
    info = ct_tifinfo(fnm);
    zstack = zeros(info.height,info.width);
    h = waitbar(0, 'Creating average zstack.  Please wait.');
    for c = 1:info.numframes;
        zstack = zstack + double(imread(fnm,c));
        waitbar(c/info.numframes);
    end
    close(h);
    zstack = zstack / info.numframes;
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
    nframes=length(folderinfo);
    h = waitbar(0, 'Creating average zstack.  Please wait.');
    for i=1:nframes
        filetoavg= [pathname folderinfo(i).name];
        if i==1
            zstack=double(imread(filetoavg));
        else
            zstack = zstack + double(imread(filetoavg));
        end
        waitbar(i/nframes);
    end
    close(h);
    zstack = zstack / nframes;
end