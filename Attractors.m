%% calcualte the attractors/local mins and their basins for energy landscape
clc;
clear all;
load('subjectsMEMRestrightS02.mat');
localMins={};
Energy=allSubMEM.subjects.Energy;
attractor=[];
for i=1:1:length(Energy(:,1))
    localMin=i;
    tempLocal=i;
    for ki=1:1:20000000
        state=allSubMEM.states(tempLocal,:);
        diff=sum(abs(state-allSubMEM.states),2);
        xx=find(diff<=2);
        nbEnergy=Energy(xx);
        minEnergy=min(nbEnergy);
        tempMin=find(Energy==minEnergy);
        localMin=tempMin;
        if tempMin==tempLocal
            break;
        else
            tempLocal=localMin;
        end
    end
    attractor=[attractor;localMin];
end
localMins.attractorLocation=sort(unique(attractor));
localMins.atrractor=attractor;
save('AttractorsAllRestRightS02.mat','localMins');


