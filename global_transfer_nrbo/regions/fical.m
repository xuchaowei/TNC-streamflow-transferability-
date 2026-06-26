function fitness = fical(x,Lp_train,t_train,ps_output,T_train,f_);
% x,,x3,
    Lp_train = evalin('base', 'Lp_train');
    t_train = evalin('base', 't_train');
    ps_output = evalin('base', 'ps_output');
    T_train = evalin('base', 'T_train');
     f_ = evalin('base', 'f_');

best_hd  = round(x(1, 2));
best_lr= x(1, 1);%
best_l2 = x(1, 3);% L2
lgraph = layerGraph();


%, [height width channels],[f_, 1, 1]
%  height ,width ,channels
% ,, channels  1,1,[f_, 1, 1]
% [65 1 1] ,sequenceFoldingLayer ,
tempLayers = [
    %65*1 1
    sequenceInputLayer([f_, 1, 1], "Name", "sequence")                 % ,[f_, 1, 1]-13*5=65
    sequenceFoldingLayer("Name", "seqfold")];
lgraph = addLayers(lgraph, tempLayers);
% https://blog.51cto.com/u_16099347/10357725
%,,,
% ,,
%,
%featuremap,
%,Feature map,32feature
%65-3+1=63  32,32/
tempLayers = convolution2dLayer([3, 1], 32, "Name", "conv_1");         %  [3, 1-11] [1, 1]  3232
lgraph = addLayers(lgraph,tempLayers);

%,,ReLU
tempLayers = [
    reluLayer("Name", "relu_1")
     %63-3+1=61  64
    convolution2dLayer([3, 1], 64, "Name", "conv_2")                   %  [3, 1] [1, 1]  64
    reluLayer("Name", "relu_2")];
lgraph = addLayers(lgraph, tempLayers);


%%, https://blog.csdn.net/SmartDemo/article/details/123889624
%-featuremap,
tempLayers = [
    % 61*164,64 1*1
    globalAveragePooling2dLayer("Name", "gapool")
    %16;,64,,161*1
    fullyConnectedLayer(16, "Name", "fc_2")                            % SE,1 / 4
    reluLayer("Name", "relu_3")
    %64;,16,,641*1---
    fullyConnectedLayer(64, "Name", "fc_3")                            % SE,--
    % 0  1 ,,
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
    'Plots', 'none', ...
    'Verbose', false);


net = trainNetwork(Lp_train, t_train, lgraph, options);
t_sim1 = predict(net, Lp_train);
T_sim1 = mapminmax('reverse', t_sim1', ps_output);
fitness = sqrt(sum((T_sim1 - T_train).^2)./length(T_sim1));
disp([' Fitness = ' num2str(fitness)]);

end
