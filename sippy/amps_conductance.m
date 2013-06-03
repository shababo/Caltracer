workspace = who;

Vm = 0; %membrane potential  
Erev = -70; %

%This function will calculate the conductance of a synaptic input given the
%amplitude (in pA). Data should be organized in vectors in the workspace,
%each vector specific for a given cell/data class.

for i=1:length(workspace)
    conductance{i,1} = workspace(i);
    amps = eval(workspace(i));
    for j = 1:length(amps);
        g(j) = amps(j)/(Vm - Erev);
    end
    conductance{i,2} = g;
    g = [];
end

