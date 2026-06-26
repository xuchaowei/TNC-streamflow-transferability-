warning off
close all
clear
clc

total_start_time = tic;
fprintf('Start processing all files...\n');

pred_col = 2;           % ()
kim = 10;
zim = 1;                % zim
SearchAgents_no = 10;
Max_iteration = 2;      % (2,)
dim = 3;
lb = [1e-3,10,1e-4];
ub = [1e-2,30,1e-1];

%% csv
file_list = dir('*.csv');
result_files = {};
for i = 1:length(file_list)
    if ~strcmp(file_list(i).name, 'results.csv') && ~strcmp(file_list(i).name, 'results.xlsx')
        result_files{end+1} = file_list(i).name;
    end
end

result_table = table();
%result_table. = result_files';
result_table.D = zeros(length(result_files), 1);
result_table.DC = zeros(length(result_files), 1);
result_table.lxiangguanxishuz = zeros(length(result_files), 1);
result_table.lxajkge = zeros(length(result_files), 1);
result_table.D2 = zeros(length(result_files), 1);
result_table.DC2 = zeros(length(result_files), 1);
result_table.xiangguanxishuz = zeros(length(result_files), 1);
result_table.xajkge = zeros(length(result_files), 1);

for file_idx = 1:length(result_files)
    filename = result_files{file_idx};
    fprintf('Processing file: %s (%d/%d)\n', filename, file_idx, length(result_files));

    try
        %% CSV
        % readtableCSV,
        try
            data_table = readtable(filename);
            result = table2array(data_table);
        catch
            % ,
            result = readmatrix(filename);
        end

        %% :NaN-99.99
        % (pred_col)NaN-99.99
        % valid_rows = ~isnan(result(:, pred_col)) & (result(:, pred_col) ~= -999) & ...
        %      ~isnan(result(:, 4)) & (result(:, 4) ~= -999) & ...
        %      ~isnan(result(:, 8)) & (result(:, 8) ~= -999) & ...
        %      ~isnan(result(:, 20)) & (result(:, 20) ~= -999);
        valid_rows = ~isnan(result(:, pred_col)) & (result(:, pred_col) ~= -999);
        %valid_rows = all(~isnan(result) & (result ~= -999), 2);
        % result = result(valid_rows, :);
        % num_cols = size(result, 2);
        % % (14820)
        % cols_to_check = setdiff(1:num_cols, [1]);
        % valid_rows = true(size(result, 1), 1);
        % % ,
        % for col = cols_to_check
        %     valid_rows = valid_rows & ~isnan(result(:, col)) & (result(:, col) ~= -999);
        % end

        result = result(valid_rows, :);





        % % (pred_col)NaN
        % valid_rows = ~isnan(result(:, pred_col));
        % result = result(valid_rows, :);
        % %% :-99.99
        % % (pred_col)NaN
        % valid_rows = ~isnan(result(:, pred_col));
        % result = result(valid_rows, :);

        num_samples = length(result);

        % ()
        all_cols = 1:size(result, 2);
        exclude_cols = [1,pred_col];

        input_cols = setdiff(all_cols, exclude_cols);
        %input_cols=all_cols;
        nim = length(input_cols);

        if num_samples < kim + zim
            fprintf(' %s has insufficient data and is skipped\n', filename);
            continue;
        end

        res = [];
        valid_samples = 0;

        for i = 1:num_samples - kim - zim + 1
            % % NaN
            % has_invalid = false;
            % for j = 1:length(input_cols)
            %     current_data = result(i:i + kim - 1 + zim, input_cols(j));
            %     if any(isnan(current_data)) || any(current_data == -999)
            %         has_invalid = true;
            %         fprintf('NaN-99.99 %f %f', i,j);
            %         break;
            %     end
            % end
            % % NaN,
            % output_datamy = result(i + kim + zim - 1, pred_col);
            % if has_invalid || isnan(output_datamy) || output_datamy == -999
            %     fprintf('NaN-99.99');
            %     continue;
            % end

            % :()
            input_data = [];
            for j = 1:length(input_cols)
                col_data = result(i:i + kim - 1 + zim, input_cols(j));
                input_data = [input_data, col_data'];
            end

            % :
            output_data = result(i + kim + zim - 1, pred_col);

            valid_samples = valid_samples + 1;
            res(valid_samples, :) = [input_data, output_data];
        end

        outdim = 1;
        num_size = 0.7;

        if valid_samples < 10
            fprintf(' %s has too few valid samples and is skipped\n', filename);
            continue;
        end

        num_train_s = round(num_size * valid_samples);
        f_ = size(res, 2) - outdim;

        P_train = res(1:num_train_s, 1:f_)';
        T_train = res(1:num_train_s, f_ + 1:end)';
        M = size(P_train, 2);

        P_test = res(num_train_s + 1:end, 1:f_)';
        T_test = res(num_train_s + 1:end, f_ + 1:end)';
        N = size(P_test, 2);

        if N == 0
            fprintf(' %s has an empty test set; adjusting the split ratio\n', filename);
            num_train_s = max(1, valid_samples - 5); % 5
            P_train = res(1:num_train_s, 1:f_)';
            T_train = res(1:num_train_s, f_ + 1:end)';
            M = size(P_train, 2);

            P_test = res(num_train_s + 1:end, 1:f_)';
            T_test = res(num_train_s + 1:end, f_ + 1:end)';
            N = size(P_test, 2);
        end

        [p_train, ps_input] = mapminmax(P_train, 0, 1);
        p_test = mapminmax('apply', P_test, ps_input);

        [t_train, ps_output] = mapminmax(T_train, 0, 1);
        t_test = mapminmax('apply', T_test, ps_output);

        p_train = double(reshape(p_train, f_, 1, 1, M));
        p_test = double(reshape(p_test, f_, 1, 1, N));
        t_train = double(t_train)';
        t_test = double(t_test)';

        Lp_train = cell(M, 1);
        for i = 1:M
            Lp_train{i, 1} = p_train(:, :, 1, i);
        end

        Lp_test = cell(N, 1);
        for i = 1:N
            Lp_test{i, 1} = p_test(:, :, 1, i);
        end

        %% ()
        best_hd = 20;
        best_lr = 0.01;
        best_l2 = 0.0001;

        lgraph = layerGraph();

        tempLayers = [
            sequenceInputLayer([f_, 1, 1], "Name", "sequence")
            sequenceFoldingLayer("Name", "seqfold")];
        lgraph = addLayers(lgraph, tempLayers);

        tempLayers = convolution2dLayer([3, 1], 32, "Name", "conv_1");
        lgraph = addLayers(lgraph, tempLayers);

        tempLayers = [
            reluLayer("Name", "relu_1")
            convolution2dLayer([3, 1], 64, "Name", "conv_2")
            reluLayer("Name", "relu_2")];
        lgraph = addLayers(lgraph, tempLayers);

        tempLayers = [
            globalAveragePooling2dLayer("Name", "gapool")
            fullyConnectedLayer(16, "Name", "fc_2")
            reluLayer("Name", "relu_3")
            fullyConnectedLayer(64, "Name", "fc_3")
            sigmoidLayer("Name", "sigmoid")];
        lgraph = addLayers(lgraph, tempLayers);

        tempLayers = multiplicationLayer(2, "Name", "multiplication");
        lgraph = addLayers(lgraph, tempLayers);

        tempLayers = [
            sequenceUnfoldingLayer("Name", "sequnfold")
            flattenLayer("Name", "flatten")
            bilstmLayer(best_hd, "Name", "bilstm", "OutputMode", "last")
            fullyConnectedLayer(1, "Name", "fc")
            regressionLayer("Name", "regressionoutput")];
        lgraph = addLayers(lgraph, tempLayers);

        lgraph = connectLayers(lgraph, "seqfold/out", "conv_1");
        lgraph = connectLayers(lgraph, "seqfold/miniBatchSize", "sequnfold/miniBatchSize");
        lgraph = connectLayers(lgraph, "conv_1", "relu_1");
        lgraph = connectLayers(lgraph, "conv_1", "gapool");
        lgraph = connectLayers(lgraph, "relu_2", "multiplication/in2");
        lgraph = connectLayers(lgraph, "sigmoid", "multiplication/in1");
        lgraph = connectLayers(lgraph, "multiplication", "sequnfold/in");

        options = trainingOptions('adam', ...
            'MaxEpochs', 100, ...
            'InitialLearnRate', best_lr, ...
            'LearnRateSchedule', 'piecewise', ...
            'LearnRateDropFactor', 0.1, ...
            'L2Regularization', best_l2, ...
            'LearnRateDropPeriod', 50, ...
            'Plots', 'none', ...  % 'none'
            'Verbose', false);

        net = trainNetwork(Lp_train, t_train, lgraph, options);

        t_sim1 = predict(net, Lp_train);
        t_sim2 = predict(net, Lp_test);

        T_sim1 = mapminmax('reverse', t_sim1', ps_output);
        T_sim2 = mapminmax('reverse', t_sim2', ps_output);
        T_sim1 = double(T_sim1);
        T_sim2 = double(T_sim2);

        len_train = length(T_train);
        lxajmean = mean(T_sim1);
        lxajstd = std(T_sim1);
        lxajsum = sum(T_sim1);
        obqmean = mean(T_train);
        obqstd = std(T_train);
        obqsum = sum(T_train);

        D = (lxajsum - obqsum) / obqsum * 100;
        c = sum((T_sim1 - T_train).^2);
        dc = sum((T_train - obqsum/len_train).^2);
        DC = 1 - c/dc;

        try
            lxajxiangguanxishu = corrcoef(T_sim1, T_train);
            lxiangguanxishuz = lxajxiangguanxishu(1,2);
        catch
            lxiangguanxishuz = NaN;
        end

        if ~isnan(lxiangguanxishuz)
            a = (lxiangguanxishuz - 1)^2 + (lxajstd/obqstd - 1)^2 + (lxajmean/obqmean - 1)^2;
            lxajkge = 1 - sqrt(a);
        else
            lxajkge = NaN;
        end

        len_test = length(T_test);
        xajmean = mean(T_sim2);
        xajstd = std(T_sim2);
        xajsum = sum(T_sim2);
        obqmean_test = mean(T_test);
        obqstd_test = std(T_test);
        obqsum_test = sum(T_test);

        D2 = (xajsum - obqsum_test) / obqsum_test * 100;
        c2 = sum((T_sim2 - T_test).^2);
        dc2 = sum((T_test - obqsum_test/len_test).^2);
        DC2 = 1 - c2/dc2;

        try
            xajxiangguanxishu = corrcoef(T_sim2, T_test);
            xiangguanxishuz = xajxiangguanxishu(1,2);
        catch
            xiangguanxishuz = NaN;
        end

        if ~isnan(xiangguanxishuz)
            a2 = (xiangguanxishuz - 1)^2 + (xajstd/obqstd_test - 1)^2 + (xajmean/obqmean_test - 1)^2;
            xajkge = 1 - sqrt(a2);
        else
            xajkge = NaN;
        end

        result_table.D(file_idx) = D;
        result_table.DC(file_idx) = DC;
        result_table.lxiangguanxishuz(file_idx) = lxiangguanxishuz;
        result_table.lxajkge(file_idx) = lxajkge;
        result_table.D2(file_idx) = D2;
        result_table.DC2(file_idx) = DC2;
        result_table.xiangguanxishuz(file_idx) = xiangguanxishuz;
        result_table.xajkge(file_idx) = xajkge;

        fprintf(' %s processed successfully,number of valid samples: %d\n', filename, valid_samples);

    catch ME
        fprintf(' %s failed with error: %s\n', filename, ME.message);
        % NaN
        result_table.D(file_idx) = NaN;
        result_table.DC(file_idx) = NaN;
        result_table.lxiangguanxishuz(file_idx) = NaN;
        result_table.lxajkge(file_idx) = NaN;
        result_table.D2(file_idx) = NaN;
        result_table.DC2(file_idx) = NaN;
        result_table.xiangguanxishuz(file_idx) = NaN;
        result_table.xajkge(file_idx) = NaN;
    end
end

%% CSV
writetable(result_table, 'results.csv');
fprintf('processed successfully,results have been saved to results.csv\n');

%% Total runtime
total_elapsed_time = toc(total_start_time);
fprintf('=== Total runtime: %.2f s ( %.2f min) ===\n', total_elapsed_time, total_elapsed_time/60);

%% Results summary
disp('Results summary:');
disp(result_table);
