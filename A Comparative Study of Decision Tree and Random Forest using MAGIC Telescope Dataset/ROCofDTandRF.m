%% Comparing the ROC
close all;
clear all;
clc;
%% Loading the data which was partitioned using holdout validation
% Importing the training and test data. %
train_Data = readtable("Partitiontrainset.csv");
test_Data = readtable("Partitiontestset.csv");
%% Slicing the training and test data
% Dividing the predictors and response variables in train and test data.
X_Train = train_Data (:,1:10);
Y_Train = train_Data (:,11);
X_Test = test_Data (:,1:10);
Y_Test = test_Data (:,11);
%% Random Forest
% Final Model
rng(1);
R5 = templateTree('Reproducible',true);
tic
MagicForest5 = fitcensemble(X_Train,Y_Train,'NumLearningCycles',50,'NumBins',50,'Method','Bag','Learners',R5);
toc
[RF_test_predicted_class, RF_test_scores] = predict(MagicForest5,X_Test);
[RF_X,RF_Y,RF_T,RF_AUC] = perfcurve(table2array(Y_Test),RF_test_scores(:,2),1);
RF_AUC
%% Decision Tree
% Final Model
rng(1);
tic
MagictreeMT = fitctree(X_Train,Y_Train,'MinLeafSize',20,'MaxNumSplits',870,'SplitCriterion','gdi','PredictorSelection','allsplits');
toc
[DT_test_predicted_class, DT_test_scores] = predict(MagictreeMT,X_Test);
[DT_X,DT_Y,DT_T,DT_AUC] = perfcurve(table2array(Y_Test),DT_test_scores(:,2),1);
DT_AUC
%% Plotting ROC
rng(1);
hold on
plot(DT_X,DT_Y,'LineWidth',2,'DisplayName',strcat('TestDT-AUC=',num2str(DT_AUC)))
plot(RF_X,RF_Y,'LineWidth',2,'DisplayName',strcat('TestRF-AUC=',num2str(RF_AUC)))
hold off
lgd = legend('Location','southeast');
lgd.NumColumns = 2;
xlabel('False positive rate');
ylabel('True positive rate');
title('ROC for Classification');