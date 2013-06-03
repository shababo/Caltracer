function h = plotGauss(mu, R, cid, color, drawcov, varargin)
%function plotGauss(mu, R, i, color, drawcov)
%
%PLOT A 2D Gaussian
%This function plots the given 2D gaussian on the current plot.
% 
% Taken from 4771 class.
linewidth = 1;
nargs = length(varargin);
for i = 1:2:nargs
    
    switch(varargin{i})
     case 'linewidth'
      linewidth = varargin{i+1};
    end
end

t = -pi:.01:pi;
k = length(t);
x = sin(t);
y = cos(t);

%R = [var1 covar; covar var2];

[vv,dd] = eig(R);
A = real((vv*sqrt(dd))');
%A = real((vv*dd)');
z = [x' y']*A;

%hold on;
h1 = text(mu(1), mu(2), num2str(cid), ...
	  'FontSize', 22, ...
	  'Color', color, ...
	  'HitTest','off');
if (drawcov)
    h2 = line(z(:,1)+mu(1), z(:,2)+mu(2), ...
	      'LineWidth', linewidth, ...
	      'Color', color, ...
	      'HitTest','off') ;
end

h = [h1; h2];
%hold off;