clear all;clc;

testFiles=filename_list('C:\Users\ps\Desktop\HiddenNN\testSet','*.mat');
modelFiles=filename_list('C:\Users\ps\Desktop\HiddenNN\allModels','*.mat');
allCorrect=[];
for i=1:1:100
    load(testFiles{i});
    [testX,XX] = mapminmax(testX',0,1);
    testX=testX';
    
    load(modelFiles{i});
    [correctness,output]=annPredict(testX,testY,model);
    allCorrect=[allCorrect;mean(correctness)];
end