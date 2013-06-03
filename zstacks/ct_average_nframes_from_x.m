%allows user to select frames deeper into sequence without having
%to average from the beginning-CSA 9/23/11
function [zstack, param] = ct_average_nframes_from_x(filename, pathname,sequential)

% Average the first n frames from x.

param.frameType = 'average_nframes_from_x';

fnm = [pathname filename];

prompt = {'How many frames should be averaged:'};
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

promptx ={'From which frame would you like to begin:'};
defx ={'1'};
dlgTitlex = 'Xth frame';
lineNox = 1;
answerx = inputdlg(promptx,dlgTitlex,lineNox,defx);

if isempty(answer)
    errordlg('You must enter a valid number.');
    return;
end
xth_frame = str2num(answerx{1});

if (xth_frame < 1)
    errordlg('You must enter a valid number.');
    return;
end


if sequential==0
    % If single multipage tiff file is opened.
    info = ct_tifinfo(fnm);
    if (nframes+xth_frame > info.numframes)
        nframes = info.numframes-xth_frame;
    end

    zstack = zeros(info.height,info.width);
    h = waitbar(0, 'Creating average zstack.  Please wait.');
    for c = 1:nframes
        zstack = zstack + double(imread(fnm,c+xth_frame-1));
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
    if (nframes+xth_frame > totalnumfiles)
        nframes = totalnumfiles-xth_frame;
    end

    h = waitbar(0, 'Creating average zstack.  Please wait.');
    for i=1:nframes
        filetoavg= [pathname folderinfo(i+xth_frame-1).name];
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