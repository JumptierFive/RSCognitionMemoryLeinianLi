%% estimation energy landscape for each subject

clear all;
clc;
threshold =0.0; %for binarization, above (below) which ROI activity is defined to be +1 (-1).
rootDir=['D:\Work\dataN\timeSeriesS01\'];
allFiles=filename_list(rootDir,'sub_*.mat');
load(allFiles{1})
roiN=length(subTS(1,:));
values=[-1,1];
allStates=getAllCombs(values,roiN);
stateNet=getNetStates(allStates);
G = graph(stateNet);
allPaths={};
% for i=1:1:length(stateNet(1,:))
%     i
%     for j=1:1:length(stateNet(1,:))
%         path = pathof(G,i,j);
%         allPaths{i,j}=path;
%     end
% end
% save('allPaths.mat','allPaths');
% aaaaaa
load('allPaths.mat');
allSubMEM={};
allSubMEM.states=allStates;
allSubMEM.statesNet=stateNet;
allSubMEM.subjects={};
allSubMEM.netpath=allPaths;
allBin=[];
for subid=1:1:length(allFiles)
    subid
    load(allFiles{subid});
    subTS=subTS';
    binarizedData = pfunc_01_Binarizer(subTS,threshold);
    allBin=[allBin,binarizedData];
end

rootDir=['D:\Work\dataN\timeSeriesS02\'];
allFiles=filename_list(rootDir,'sub_*.mat');
for subid=1:1:length(allFiles)
    subid
    load(allFiles{subid});
    subTS=subTS';
    binarizedData = pfunc_01_Binarizer(subTS,threshold);
    allBin=[allBin,binarizedData];
end



[h,J] = pfunc_02_Inferrer_ML(allBin);
[probN, prob1, prob2, rD, r] = pfunc_03_Accuracy(h, J, binarizedData);
tempEnergy=[];
allstatesN=length(allStates(:,1));
for i=1:1:allstatesN
    energy = energyCalculate(h,J,allStates(i,:));
    tempEnergy=[tempEnergy;energy];
end
costEnergy=zeros(allstatesN,allstatesN);
for i=1:1:allstatesN
    for j=1:1:allstatesN
        if i==j
            continue
        end
        tempCostEnergy=[];
        for ki=1:1:length(allPaths{i,j})
            if ~isempty(allPaths{i,j}{ki})
                changeE=tempEnergy(allPaths{i,j}{ki});
                tempCostEnergy=[tempCostEnergy,max(changeE)];
            end
        end
        aaaaa
        costEnergy(i,j)=min(tempCostEnergy);
    end
end
allSubMEM.subjects.h=h;
allSubMEM.subjects.J=J;
allSubMEM.subjects.Energy=tempEnergy;
allSubMEM.subjects.r=r;
allSubMEM.subjects.rD=rD;
allSubMEM.subjects.costEnergy=costEnergy;

save('subjectsMEM.mat','allSubMEM');





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
interEnergy=-1*sum(sum(state'*state.*J))/2;
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