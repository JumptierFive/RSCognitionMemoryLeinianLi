%% main scripts for hiddern layer network with a hopfiled network for offline memory processing
% Li Leinian In Jinan, 2023.09.01
clear all;close all;clc;
allCorrect=[];
allAct=[];

basinSAll={};
SubTSAll={};

for ki=1:1:36
    load(['Represent/sub_left',dec2base(ki,10,2),'.mat']);
    load(['Represent/anBasinS',dec2base(ki,10,2),'.mat']);
    basinSAll{ki}=basinS;
    SubTSAll{ki}=subTS;
end
allModels={};
for subid=1:1:36
    subid
    hiddenLayer=[100,50];
    input_num=146;output_num=2;
    [W,b]=initial_network(hiddenLayer,input_num,output_num);
    
    l_rate=0.005;
    epoches=500;
    
    
    y=basinSAll{subid};kx=find(y==2);mx=find(y==63);y=y([kx;mx]);y(y==2)=1;y(y==63)=2;
    X=SubTSAll{subid};X=X([kx;mx],:);
    [X,XX] = mapminmax(X,0,1);
    [X,XX] = mapminmax(X',0,1);
    X=X';
% 
    randY=randperm(length(y));
    y=y(randY);
    
    randP=randperm(length(kx));
    testN=randP(1:50);
    randP=randperm(length(mx));
    testN=[testN,randP(1:50)+length(kx)]';
    
    testN=sort(testN);
    testX=X(testN,:);X(testN,:)=[];
    testY=y(testN);y(testN)=[];
    
    kx=numel(kx)-50;mx=numel(mx)-50;
    if kx > mx
        an=kx-mx;
        anper=randperm(kx);
        X(anper(1:an),:)=[];
        y=[ones(mx,1);ones(mx,1).*2];
    elseif mx > kx
        an=mx-kx;
        anper=randperm(mx);
        toDelete=length(y)-anper(1:1:an)+1;
        X(toDelete,:)=[];
        y=[ones(kx,1);ones(kx,1).*2];
    end
    
    [model]=annTrain(X,y,W,b,l_rate,epoches,length(y));
    [correctness,output]=annPredict(testX,testY,model);
    allCorrect=[allCorrect;mean(correctness)];
    allModels{subid}=model;
end

models.subjectModels=allModels;
models.predictCorrect=allCorrect;
save('allModels2to63Perm.mat','models');