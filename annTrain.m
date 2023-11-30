function model=annTrain(X,Y,W,b,l_rate,epoches,minibatch)
%% a function procedure for hidden layers ann learning
% Li leinian Written in Jinan, 2023,09.09
correct_rates=[];
trainduration=0;
tic
for i=1:1:epoches
    tp_order=randperm(length(Y));
    temp_X=X(tp_order,:);
    temp_Y=Y(tp_order);
    
    temp_X=temp_X(1:1:minibatch,:);
    temp_Y=temp_Y(1:1:minibatch,:);
    
    temp_correct=[];
    for ti=1:1:length(temp_Y)
        ct_Y=zeros(1,max(temp_Y))';
        ct_Y(temp_Y(ti))=1;
        [W_grad,b_grad,correctness] = backProp(temp_X(ti,:)',ct_Y,W,b);
        for ki=1:1:length(W)
            W{ki}=W{ki}+W_grad{ki}.*l_rate;
        end
        b=b_grad;
        temp_correct=[temp_correct;correctness];
    end
    temp_correct=mean(temp_correct);
    correct_rates=[correct_rates;temp_correct];
    tempModel.W=W;tempModel.b=b;
    save(['models\annModel',dec2base(i,10,3),'.mat'],'tempModel');
end
train_duration=toc;
model.W=W;
model.b=b;
model.correct=correct_rates;
model.epoches=epoches;
model.train_time=train_duration;

end