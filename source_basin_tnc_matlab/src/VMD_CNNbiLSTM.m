clc;
clear
close all
X = xlsread('dataset2.xlsx');
load vmd_data.mat
IMF = u;
disp('..........................................................................................................................................')
disp('VMD-CNN-BiLSTM prediction')
disp('..........................................................................................................................................')

for uu=1:size(IMF,2)
    X_imf=[X(:,1:end-1),IMF(:,uu)];

num_samples = length(X_imf);
kim = 7;                      % (kim)
zim =  2;                      % zim  --
or_dim = size(X_imf,2);

for i = 1: num_samples - kim - zim + 1
    res(i, :) = [reshape(X_imf(i: i + kim - 1,:), 1, kim*or_dim), X_imf(i + kim + zim - 1,:)];
end


outdim = 1;
num_size = 0.7;
num_train_s = round(num_size * num_samples);
f_ = size(res, 2) - outdim;


P_train = res(1: num_train_s, 1: f_)';
T_train = res(1: num_train_s, f_ + 1: end)';
M = size(P_train, 2);

P_test = res(num_train_s + 1: end, 1: f_)';
T_test = res(num_train_s + 1: end, f_ + 1: end)';
N = size(P_test, 2);

[p_train, ps_input] = mapminmax(P_train, 0, 1);
p_test = mapminmax('apply', P_test, ps_input);

[t_train, ps_output] = mapminmax(T_train, 0, 1);
t_test = mapminmax('apply', T_test, ps_output);


for i = 1:size(P_train,2)
    trainD{i,:} = (reshape(p_train(:,i),size(p_train,1),1,1));
end

for i = 1:size(p_test,2)
    testD{i,:} = (reshape(p_test(:,i),size(p_test,1),1,1));
end


targetD =  t_train;
targetD_test  =  t_test;

numFeatures = size(p_train,1);
numResponses = 35;

best_hd  = 57;
best_lr = 0.000393569777940371;
best_l2 = 0.00001;

layers0 = [ ...
    sequenceInputLayer([numFeatures,1,1],'name','sequence')   %?
    sequenceFoldingLayer('name','seqfold')         %?
    % CNN
    convolution2dLayer([3,1],16,'Stride',[1,1],'name','conv_1')  %64?10Stride?
    batchNormalizationLayer('name','batchnorm1')  % BN?
    reluLayer('name','relu_1')       % ReLU?
      % ?
    convolution2dLayer([3, 1], 64, "Name", "conv_2")                   % ?3, 1] [1, 1] ?64
    reluLayer("Name", "relu_2")
    maxPooling2dLayer([2,1],'Stride',2,'Padding','same','name','maxpool')   % ?x3o?ame
    fullyConnectedLayer(16, "Name", "fc_2")                            % SE1 / 4
    reluLayer("Name", "relu_3")
    fullyConnectedLayer(64, "Name", "fc_3")                            % SE?
    sigmoidLayer("Name", "sigmoid")
    multiplicationLayer(2, "Name", "multiplication");
    % ?
    sequenceUnfoldingLayer('name','sequnfold')       %?
    %?
    flattenLayer('name','flatten')

    bilstmLayer(best_hd,'Outputmode','last','name','bilstm')
    dropoutLayer(0.2,'name','dropout_1')        % Dropout0.2()

    fullyConnectedLayer(1,'name','fc')   % ell
    regressionLayer('Name','regressionoutput')
    ];
lgraph0 =  layerGraph(layers0);
lgraph0 = connectLayers(lgraph0, "seqfold/miniBatchSize", "sequnfold/miniBatchSize");
lgraph0 = connectLayers(lgraph0, "relu_2", "multiplication/in2");        %   ?

%% Set the hyper parameters for unet training
options0 = trainingOptions('adam', ...                 % Adam
    'MiniBatchSize',128, ...
    'MaxEpochs', 10, ...                            % ?
    'GradientThreshold', 1, ...                       % ?
    'InitialLearnRate', best_lr, ...         % ?
    'LearnRateSchedule', 'piecewise', ...             % ?
    'LearnRateDropPeriod',5, ...                   % 100
    'LearnRateDropFactor',0.01, ...                    % ?
    'L2Regularization', best_l2, ...         % e?
    'ExecutionEnvironment', 'gpu',...
    'Verbose', false, ...
    'Plots', 'training-progress', ...
     ValidationData={testD,targetD_test'}, ...
     ValidationFrequency=1, ...
    ObjectiveMetricName="loss", ...
    OutputNetwork="best-validation");
% % start training
[net,info] = trainNetwork(trainD,targetD',lgraph0,options0);
%analyzeNetwork(net);%
t_sim1 = predict(net, trainD);
t_sim2 = predict(net, testD);

T_sim1 = mapminmax('reverse', t_sim1, ps_output);
T_sim2 = mapminmax('reverse', t_sim2, ps_output);
T_train1 = T_train;
T_test2 = T_test;

imf_T_sim1(:,uu) = double(T_sim1);% cell2matcell
imf_T_sim2(:,uu) = double(T_sim2);



end


num_samples = length(X);
kim = 7;                      % (kim)
zim =  2;                      % zim
or_dim = size(X,2);
for i = 1: num_samples - kim - zim + 1
    res(i, :) = [reshape(X(i: i + kim - 1,:), 1, kim*or_dim), X(i + kim + zim - 1,:)];
end
T_train = res(1: num_train_s, f_ + 1: end)';
T_test = res(num_train_s + 1: end, f_ + 1: end)';


T_sim_a = sum(imf_T_sim1,2);
T_sim_b = sum(imf_T_sim2,2);




[kge,nse,re,r2] = calcansekge(T_train,T_sim_a');
fprintf('\n')


[kge,nse,re,r2] = calcansekge(T_test,T_sim_b');
fprintf('\n')

ResultTimeSeriTrain = [T_train' T_sim_a];
ResultTimeSeriTest = [T_test' T_sim_b];
