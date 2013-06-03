function [x, y, h] = draw_region(width, height, varargin)
% function [x, y, h] = draw_region(width, height, tag)
% 
% Abstract a general drawing facility for E-Po.  This was originally
% used to draw regions but it's now used for other things as well.
use_nclicks = 0;
nclicks = 1e10;				% explicitly large.
is_enclosed_space = 0;
tag = '';
user_data = '';
do_time = 0;
do_pixels = 1;				% round data for pixels.
color = 'y';
nargs = length(varargin);
for i = 1:2:nargs
    switch varargin{i},
     case 'nclicks'     
      use_nclicks = 1;
      nclicks = varargin{i+1};
     case 'enclosedspace'
      is_enclosed_space = varargin{i+1};
     case 'tag'
      tag = varargin{i+1};
     case 'userdata'
      user_data = varargin{i+1};
     case 'color'
      color = varargin{i+1};
     case 'pixels'
      do_pixels = varargin{i+1};
     case 'time'
      do_time = varargin{i+1};
    end
end

continue_collecting = 1;
c = 1;
x = [];
y = [];
isb = 0;
click_counter = 0;
while continue_collecting
    [x(c) y(c) butt] = ginput(1);
    click_counter = click_counter + 1;
    if (do_pixels)
	x(c) = round(x(c));
	y(c) = round(y(c));
    end
    if (click_counter >= nclicks)
	continue_collecting = 0;
    end
    % left or right click are ok for first click only
    if (butt > 1 | continue_collecting == 0)
        if c == 1
            isb = 1;
        else
            continue_collecting = 0;
        end
        if isb == 1
            [mn i] = min([x(c) width-x(c)+1 y(c) height-y(c)+1]);
            switch i
	     case 1
	      x(c) = 1;
	     case 2
	      x(c) = width;
	     case 3
	      y(c) = 1;
	     case 4
	      y(c) = height;
            end
        end
	
	% Ignore the time dimension if we are drawing on a time plot.
	if (do_time & c > 1)
	    y(c) = y(1);
	end
    end

    if c == 1
	colormarker = [color 'o'];
        h = plot(x,y, colormarker);%first point is a yellow circle
    end
    if c == 2
        delete(h);
	colormarker = [color ':+'];
        h = plot(x,y,colormarker);%first non-one-point plot becomes a 
%         series of yellow crosses connected by yellow dotted lines
    end
    if c > 2 %later points...
        set(h,'xdata',x,'ydata',y);%just update x and y data...same line style
    end
    c = c+1;
end
if isb == 0
    if (is_enclosed_space)
        x = [x x(1)];
        y = [y y(1)];
    end
    set(h,'xdata',x,'ydata',y);
    if (~isempty(tag))
        set(h, 'Tag', tag);
    end
    if (~isempty(user_data))
        set(h, 'UserData', user_data);
    end
end
