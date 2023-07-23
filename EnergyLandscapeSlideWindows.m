%% estimation fluctuations of a system
clear all;
clc;
threshold =0.0; %for binarization, above (below) which ROI activity is defined to be +1 (-1).
rootDir=['D:\Work\dataN\timeSeriesS02\'];
allFiles=filename_list(rootDir,'sub_*Left.mat');
load('subjectsMEMRestleftS02.mat');

allSubEnergyChange={};
for subid=1:1:24
    subid
    load(allFiles{subid});
    subTS=subTS';
    binData = pfunc_01_Binarizer(subTS,threshold);
    cgEnergy=[];
    tpEnergy=[];
    for i=2:1:length(binData(1,:))
        ctStateOrder=sum(abs(binData(:,i-1)-allSubMEM.states'));x1=find(ctStateOrder==0);
        ctStateOrder=sum(abs(binData(:,i)-allSubMEM.states'));x2=find(ctStateOrder==0);
        tpEnergy=[tpEnergy;allSubMEM.subjects{subid}.Energy(x2)];
        cgEnergy=[cgEnergy,allSubMEM.subjects{subid}.Energy(x2)-allSubMEM.subjects{subid}.Energy(x1)];
    end
    allSubEnergyChange{subid}.cgEnergy=cgEnergy;
    allSubEnergyChange{subid}.tpEnergy=tpEnergy;
end
save('subjectEnergyChangeRestS02AALL.mat','allSubEnergyChange');








function combsAll = getAllCombs(values,roiN)
% calculate possible combinaiton of neural network states
combs = unique(sort(nchoosek(repmat(values,1,roiN),roiN),2),'rows');
combsAll=[];
for i=1:1:length(combs(:,1))
    V=perms(combs(i,:));
    combsAll=[combsAll;V];
end
combsAll=unique(combsAll,'rows');
end

function energy = energyCalculate(h,J,state)
% Ising model canculate energy
fieldEnergy=-1*sum(state.*h');
interEnergy=-1*sum(sum(state*state'.*J))/2;
energy=fieldEnergy+interEnergy;
end

function [statesNet] = getNetStates(States)
netN=length(States(:,1));
statesNet=zeros(netN,netN);
for i=1:1:netN
    diffState=sum(abs(States-States(i,:)),2);
    xx=find(diffState==2);
    statesNet(i,xx)=1;
end
end


function pth=pathof(graph,startn,endn)
stop=0;
n=0;
while stop~=1
    n=n+1;
    Temp=shortestpath(graph,startn,endn);
    eidx=findedge(graph,Temp(1:end-1),Temp(2:end));
    if n~=1
        if length(Temp)==length(pth{n-1,1})
            if Temp==pth{n-1,1}
                stop=1;
            else
                pth{n,1}=Temp;
                graph.Edges.Weight(eidx)=100;
            end
        else
            pth{n,1}=Temp;
            graph.Edges.Weight(eidx)=100;
        end
    else
        pth{n,1}=Temp;
        graph.Edges.Weight(eidx)=100;
    end
    clear Temp eidx;
end
end