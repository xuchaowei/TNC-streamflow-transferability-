warning off
close all
clear
clc

result = xlsread('dataset2.xlsx');

num_samples = length(result);  %  500
kim = 7;                      % ()
zim =  1;                      % zim
nim = size(result, 2) - 1;     %    5

%%  --?  488*66
for i = 1: num_samples - kim - zim + 1 % 1-488
    res(i, :) = [reshape(result(i: i + kim - 1 + zim, 1: end - 1)', 1, ...
        (kim + zim) * nim), result(i + kim + zim - 1, end)];
end

outdim = 1;
num_size = 0.7;
num_train_s = round(num_size * num_samples); %   350
f_ = size(res, 2) - outdim;                  %   65--13,5 13*5?--65

P_train = res(1: num_train_s, 1: f_)';
T_train = res(1: num_train_s, f_ + 1: end)';
M = size(P_train, 2);   %350  488  0.7

P_test = res(num_train_s + 1: end, 1: f_)';
T_test = res(num_train_s + 1: end, f_ + 1: end)';
N = size(P_test, 2);  %138  488 0.3

[p_train, ps_input] = mapminmax(P_train,0,1);
p_test = mapminmax('apply',P_test,ps_input);

[t_train, ps_output] = mapminmax(T_train,0,1);
t_test = mapminmax('apply',T_test,ps_output);

%%  ---,,
%   1
%   2,3,
%   --
p_train =  double(reshape(p_train, f_, 1, 1, M));
p_test  =  double(reshape(p_test , f_, 1, 1, N));
t_train =  double(t_train)';
t_test  =  double(t_test )';

%%  --,
%  p_train  p_test , Lp_train  Lp_test
% ,,
for i = 1 : M
    Lp_train{i, 1} = p_train(:, :, 1, i);
end

for i = 1 : N
    Lp_test{i, 1}  = p_test( :, :, 1, i);
end
%%  ---
% :The proposed NRBO is basically developed using the Newton-Raphson method to investigate the search space's best positions
% and find the best solution.
SearchAgents_no = 10;                  %   --
Max_iteration = 2;
dim = 3;
lb = [1e-3,10 1e-4];                 % (,,)
ub = [1e-2, 30,1e-1];                 % (,,)

% tic;
% fitness = @(x)fical(x,Lp_train,t_train,ps_output,T_train,f_);
% [Best_score,Best_pos,curve]=NRBO(SearchAgents_no,Max_iteration,lb ,ub,dim,fitness)
% elapsedTime = toc;
% disp(['NRBO-CNN-BiLSTM-Attention: ', num2str(elapsedTime), ' s']);

% best_hd  = round(Best_pos(1, 2));
% best_lr= Best_pos(1, 1);%
% best_l2 = Best_pos(1, 3);% L2
% Best_pos(1, 2) = round(Best_pos(1, 2));

best_hd  = 20;
best_lr= 0.01;%
best_l2 = 0.0001;% L2
lgraph = layerGraph();

tempLayers = [
    sequenceInputLayer([f_, 1, 1], "Name", "sequence")                 % ,[f_, 1, 1]
    sequenceFoldingLayer("Name", "seqfold")];
lgraph = addLayers(lgraph, tempLayers);

tempLayers = convolution2dLayer([3, 1], 32, "Name", "conv_1");         %  [3, 1] [1, 1]  32
lgraph = addLayers(lgraph,tempLayers);

tempLayers = [
    reluLayer("Name", "relu_1")
    convolution2dLayer([3, 1], 64, "Name", "conv_2")                   %  [3, 1] [1, 1]  64
    reluLayer("Name", "relu_2")];
lgraph = addLayers(lgraph, tempLayers);

tempLayers = [
    globalAveragePooling2dLayer("Name", "gapool")
    fullyConnectedLayer(16, "Name", "fc_2")                            % SE,1 / 4
    reluLayer("Name", "relu_3")
    fullyConnectedLayer(64, "Name", "fc_3")                            % SE,
    sigmoidLayer("Name", "sigmoid")];
lgraph = addLayers(lgraph, tempLayers);

tempLayers = multiplicationLayer(2, "Name", "multiplication");
lgraph = addLayers(lgraph, tempLayers);

tempLayers = [
    sequenceUnfoldingLayer("Name", "sequnfold")
    flattenLayer("Name", "flatten")
    bilstmLayer(best_hd, "Name", "bilstm", "OutputMode", "last")                 % BiLSTM
    fullyConnectedLayer(1, "Name", "fc")
    regressionLayer("Name", "regressionoutput")];
lgraph = addLayers(lgraph, tempLayers);

lgraph = connectLayers(lgraph, "seqfold/out", "conv_1");               %   ;
lgraph = connectLayers(lgraph, "seqfold/miniBatchSize", "sequnfold/miniBatchSize");
lgraph = connectLayers(lgraph, "conv_1", "relu_1");
lgraph = connectLayers(lgraph, "conv_1", "gapool");
lgraph = connectLayers(lgraph, "relu_2", "multiplication/in2");
lgraph = connectLayers(lgraph, "sigmoid", "multiplication/in1");
lgraph = connectLayers(lgraph, "multiplication", "sequnfold/in");

options = trainingOptions('adam', ...      % Adam
    'MaxEpochs', 100, ...
    'InitialLearnRate', best_lr, ...          % 0.01
    'LearnRateSchedule', 'piecewise', ...
    'LearnRateDropFactor', 0.1, ...        %  0.5
     'L2Regularization',best_l2,...
    'LearnRateDropPeriod', 50, ...        % 700  0.01 * 0.1
    'Shuffle', 'every-epoch', ...
    'Plots', 'training-progress', ...
    'Verbose', false);

net = trainNetwork(Lp_train, t_train, lgraph, options);



t_sim1 = predict(net, Lp_train);
t_sim2 = predict(net, Lp_test );

T_sim1 = mapminmax('reverse', t_sim1', ps_output);
T_sim2 = mapminmax('reverse', t_sim2', ps_output);
T_sim1=double(T_sim1);
T_sim2=double(T_sim2);
%analyzeNetwork(net)


%%   RMSE
error1 = sqrt(sum((T_sim1 - T_train).^2)./M);
error2 = sqrt(sum((T_test - T_sim2).^2)./N);

R1 = 1 - norm(T_train - T_sim1)^2 / norm(T_train - mean(T_train))^2;
R2 = 1 - norm(T_test -  T_sim2)^2 / norm(T_test -  mean(T_test ))^2;

% MSE
mse1 = sum((T_sim1 - T_train).^2)./M;
mse2 = sum((T_sim2 - T_test).^2)./N;

%% MAPE
MAPE1 = mean(abs((T_train - T_sim1)./T_train));
MAPE2 = mean(abs((T_test - T_sim2)./T_test));

T_test=T_test';
T_sim2=T_sim2'

len=length(T_train);
lxajmean=mean(T_sim1);
lxajstd=std(T_sim1);
lxajsum=sum(T_sim1);
obqmean=mean(T_train);
obqstd=std(T_train);
obqsum=sum(T_train);
D=(lxajsum-obqsum)/obqsum*100;
c = sum((T_sim1 - T_train).^2);
dc= sum((T_train - obqsum/len).^2);
DC=1-c/dc;
lxajxiangguanxishu=corrcoef(T_sim1,T_train);
lxiangguanxishuz=lxajxiangguanxishu(T_sim1);%XAJ-L
a=(lxiangguanxishuz-1)^2+(lxajstd/obqstd-1)^2+(lxajmean/obqmean-1)^2;
lxajkge=1-sqrt(a);  %kGE


len=length(T_test);
xajmean=mean(T_sim2);
xajstd=std(T_sim2);
xajsum=sum(T_sim2);
obqmean=mean(T_test);
obqstd=std(T_test);
obqsum=sum(T_test);
D2=(xajsum-obqsum)/obqsum*100;
c = sum((T_sim2 - T_test).^2);
dc= sum((T_test - obqsum/len).^2);
DC2=1-c/dc;
xajxiangguanxishu=corrcoef(T_sim2,T_test);
xiangguanxishuz=xajxiangguanxishu(T_sim2);%XAJ-L
a=(xiangguanxishuz-1)^2+(xajstd/obqstd-1)^2+(xajmean/obqmean-1)^2;
xajkge=1-sqrt(a);


%%  D  DC  lxiangguanxishuz lxajkge
%%  D2  DC2  xiangguanxishuz xajkge
