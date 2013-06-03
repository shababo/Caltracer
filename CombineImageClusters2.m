function CombineImageClusters2
% MD - Written on 4/30/10
% The whole point of this function is to get rid of the stupid separation
% of tiff files into numerous folders when taking a long movie.  It saves
% all the clusters together in one folder called "allclusters" and then runs
% ImageJ (using Java) and runs the commands to open the image sequence and 
% save the stack into the appropriate folder. 

% To Install - Step 1 - Add this file to the matlab path.  
% Step 2 - Download and install the Matlab/ImageJ plugin from here:
% http://bigwww.epfl.ch/sage/soft/mij/
% Step 3 - Place the MD_ConvertImageSequencetoTIFF.txt file in your imageJ
% plugins\macros folder (you may still need to change the path in this
% program for it to run correctly depending on your imageJ installation
% location.

% To Use - select the folder of the movie you want to be combined (ie.
% LowLight_003) and hit ok, the program will automatically move the 
% files in the to a folder called "allclusters".  It will then call imagej
% and have it convert the sequential files into one file.  

% The final - single file - tif is saved in the "data" folder and is called
% "allclusters.tif"

%% Warning, this was made for a very specific directory structure, if it does
%% not match yours, you MAY need to change the code below (and the imageJ macro) 
%% to get it to work properly.
destination = uigetdir('D:\PiperData\Movies\110803');
if destination == 0
    return;
end
destination = [destination '\Data'];
allclusters = [destination '\allclusters'];
allfolders = dir(destination);
allfolders = allfolders(3:end);
if allfolders(1).isdir == 0
   errordlg('There is already only one folder.','Single folder');
   return;    
end
mkdir(allclusters);

h = waitbar(0,['Moving Files from: ' destination]);
for s = 1:length(allfolders)
  folderpath = [destination '\' allfolders(s).name '\'];
  allfiles = dir(folderpath);
  allfiles = allfiles(3:end);
  waitbar(s/(length(allfolders)));
  for i = 1:length(allfiles)
      filepath = [folderpath allfiles(i).name];
      finaldestination = [allclusters '\' allfiles(i).name];
      movefile(filepath,finaldestination);
  end
  rmdir(folderpath);
end
close(h);

% openpath = ['open=[' finaldestination ']'];
% javaaddpath ('C:\Program Files\MATLAB\R2007b\java\ij.jar');
% javaaddpath ('C:\Program Files\MATLAB\R2007b\java\mij.jar');
% MIJ.start('C:\Program Files\ImageJ\plugins');
% MIJ.run('Image Sequence...',openpath);
% MIJ.run('Run...','run=[c:\\Program Files\\ImageJ\\plugins\\Macros\\MD_ConvertImageSequencetoTIFF.txt]');
% MIJ.exit;
% rmdir(allclusters,'s');