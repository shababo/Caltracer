function x = ct_zscore(x, options)

% This stupid zscore function changed between version 6 and 7!.
if (version('-release') >= 14)
    x = zscore(x')';
else
    x = zscore(x);
end