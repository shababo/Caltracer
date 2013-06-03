function [loca, param] = ct__no_filter(experiment, maskidx,param)
loca = experiment.Image(maskidx).image;
param.status = 'ok';