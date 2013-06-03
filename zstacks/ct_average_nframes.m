function [zstack, param] = ct_average_nframes(filename, pathname,sequential)
% function [zstack, param] = ct_average_nframes(filename, pathname)
% Average the first n frames.

param.frameType = 'average_nframes';
fnm = [pathname filename];
prompt = {'How many frames should be averaged (starting from 1):'};
def = {'100'};
dlgTitle = 'Average N frames.';
lineNo = 1;
answer = inputdlg(prompt,dlgTitle,lineNo,def);
if isempty(answer)
    errordlg('You must enter a valid number.');
    return;
end
nframes = str2num(answer{1});
if (nframes < 1)
    errordlg('You must enter a valid number.');
    return;
end

if sequential==0
    % If single multipage tiff file is opened.
    info = ct_tifinfo(fnm);
    if (nframes > info.numframes)
        nframes = info.numframes;
    end

    zstack = zeros(info.height,info.width);
    h = waitbar(0, 'Creating average zstack.  Please wait.');
    for c = 1:nframes
        zstack = zstack + double(imread(fnm,c));
        waitbar(c/nframes);
    end
    close(h);
    zstack = zstack / nframes;

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
    totalnumfiles=length(folderinfo);
    if (nframes > totalnumfiles)
        nframes = totalnumfiles;
    end

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