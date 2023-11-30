function [W_grad,b_grad,correctness] = backProp(X,Y,W,b)
%% a backprop neural network function to update Weights and bias
% written by Li leinian in Jinan, 2023.09.04

% X input sample, rows for the different features, one column
% Y labels in a column
% W a cell, weights between each layer, row numers = number of neurons in current
% layer, and column numbers = numbers of neurons in past layer
% b bias in each layer
% l_rate, learning rate

if nargin ~=4
    disp('incorrect inputs viriables');
end

% forward activations calculation
activations=cell(1,length(W)+1);
activations{1}=X;
inputs=cell(1,length(W));

for li=1:1:length(W)
    inputs{li}=W{li}*activations{li}+b{li};
    next_activation=sigmoid(inputs{li});
    activations{li+1}=next_activation;
end

% lost for the current strcuture
lost=Y-activations{end};
ctt=activations{end};
ctt(ctt>=0.5)=1;ctt(ctt<0.5)=0;
if sum(abs(Y-ctt))==0
    correctness=1;
else
    correctness=0;
end

% activation correction bias
b_activation=cell(1,length(W)+1);
b_activation{end}=lost;
for li=length(W):-1:2
    outputbias=W{li}'*b_activation{li+1};
    b_activation{li}=outputbias.*sigmoidGradient(inputs{li-1});
end
% weights for correction bias
dW=cell(1,length(W));
for li=1:1:length(W)
    dW{li}=b_activation{li+1}*activations{li}';
end

W_grad=dW;
b_grad=b_activation(2:end);




function sig = sigmoid(x)
    sig = 1 ./ (1 + exp(-x));
end

function sig_grad = sigmoidGradient(x)
    sig_grad = sigmoid(x) .* (1 - sigmoid(x));
end
end