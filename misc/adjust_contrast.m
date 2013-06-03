function handles = adjust_contrast(handles)
%function handles = adjust_contrast(handles)

%
% Adjust the contrast and brightness of the image based on user
% defined widget values.
maskidx = handles.app.data.currentMaskIdx;
brightness = uiget(handles, 'image', 'bbright', 'value');
contrast = uiget(handles, 'image', 'bcontrast', 'value');
climg = compute_contrast(brightness, contrast);
handles.app.experiment.Image(maskidx).colorMap = climg;
set(handles.fig,'colormap',climg);



%%% -DCS:2005/03/15
%%% Will this function break if there the movie values are > 255?
function climg = compute_contrast(brightness, contrast)
contrast = contrast^0.25;
if contrast < 0.5
    m = 2*contrast/255;
else
    m = 1/(510-510*contrast+eps);
end
if brightness < 0.5
    b = -255*m*(1-(2*brightness)^0.25);
else
    b = 2*brightness-1;
end

cc = (0:255)*m+b;
cc(cc<0)=0;
cc(cc>1)=1;
climg = repmat(cc',1,3);

