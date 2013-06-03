function [basemean]=findbasemean(reading)
%this function finds a baseline for a vector (reading).  It finds the most
%common value in the reading to within .5 (mV) accuracy and all values within 3(mV) of that value and
%takes the mean.  That mean value is one output, "basemean".  It also takes
%all points outside that 3mV range of the most common value and sets them
%equal to the basemean.  A line is then fit to the resulting reading to give
%a baseline... which is the output "baseline"


range1=sort(reading);
range=[range1(end)-range1(1)];%find the range of all values in the reading
range=round(range/.5);%determine how many divisions of the range to make such that each division is .5 in width
[n,xout] = hist(reading,range);%determine how many points have value in each division of the range
[c,d]=max(n);%find the number of points in the max division as well as the index number of division
bone=xout(d);%find the numerical (mV) value in which there are the most points
btwo=reading(find(reading>=(bone-3) & reading<=(bone+3)));%find all points within 3 (mV) of that max value
basemean=mean(btwo);%find mean of all those points