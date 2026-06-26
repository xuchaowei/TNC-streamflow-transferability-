function [mae,mape,rmse]=calc_error(x1,x2)
error = x2 - x1;
rmse = sqrt(mean(error.^2));
mae = mean(abs(error));
mape = mean(abs(error./x1));
R = corrcoef(x1,x2);
Rsq1 = R(1,2)^2 * 100;

disp(['1. Mean squared error (MSE): ', num2str(mse(x1-x2))])
disp(['2. Root mean squared error (RMSE): ', num2str(rmse)])
disp(['3. Mean absolute error (MAE): ', num2str(mae)])
disp(['4. Mean absolute percentage error (MAPE): ', num2str(mape*100), '%'])
disp(['5. Coefficient of determination (R2): ', num2str(Rsq1), '%'])
end
