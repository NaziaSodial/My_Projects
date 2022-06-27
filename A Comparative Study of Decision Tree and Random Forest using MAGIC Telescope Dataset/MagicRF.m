close all;
clear all;
clc;
%% Random Forest
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
%% Creating a new table to normalize the data
X_TrainN = X_Train;
X_TrainN.fLength = (X_TrainN.fLength-min(X_TrainN.fLength))/(max(X_TrainN.fLength)-min(X_TrainN.fLength));
X_TrainN.fWidth = (X_TrainN.fWidth-min(X_TrainN.fWidth))/(max(X_TrainN.fWidth)-min(X_TrainN.fWidth));
X_TrainN.fSize = (X_TrainN.fSize-min(X_TrainN.fSize))/(max(X_TrainN.fSize)-min(X_TrainN.fSize));
X_TrainN.fConc = (X_TrainN.fConc-min(X_TrainN.fConc))/(max(X_TrainN.fConc)-min(X_TrainN.fConc));
X_TrainN.fConc1 = (X_TrainN.fConc1-min(X_TrainN.fConc1))/(max(X_TrainN.fConc1)-min(X_TrainN.fConc1));
X_TrainN.fAsym = (X_TrainN.fAsym-min(X_TrainN.fAsym))/(max(X_TrainN.fAsym)-min(X_TrainN.fAsym));
X_TrainN.fM3Long = (X_TrainN.fM3Long-min(X_TrainN.fM3Long))/(max(X_TrainN.fM3Long)-min(X_TrainN.fM3Long));
X_TrainN.fM3Trans = (X_TrainN.fM3Trans-min(X_TrainN.fM3Trans))/(max(X_TrainN.fM3Trans)-min(X_TrainN.fM3Trans));
X_TrainN.fAlpha = (X_TrainN.fAlpha-min(X_TrainN.fAlpha))/(max(X_TrainN.fAlpha)-min(X_TrainN.fAlpha));
X_TrainN.fDist = (X_TrainN.fDist-min(X_TrainN.fDist))/(max(X_TrainN.fDist)-min(X_TrainN.fDist));
%% Creating model with normalized data
% Bagging 
rng(1);
tic
MagicForestN = fitcensemble(X_TrainN,Y_Train,'Method','Bag');
toc
% Calculating the out of bag error
ooblossFN = oobLoss(MagicForestN);
oobAccFN = (1-ooblossFN)*100
%% Creating a model without any preprocessing
% Bagging 
rng(1);
tic
MagicForest0 = fitcensemble(train_Data,'class','Method','Bag');
toc
% Calculating the out of bag error
ooblossF0 = oobLoss(MagicForest0);
oobAccF0 = (1-ooblossF0)*100;
% Calculating classification loss
CEF0 = loss(MagicForest0,test_Data,'class');
AccF0 = (1-CEF0)*100
%% Binning to reduce the time
rng(1);
tic
MagicForest1 = fitcensemble(train_Data,'class','Method','Bag','NumBins',50);
toc
% A significant decrease in time is observed

%% Using plot of errors to determine the best number of trees
rng(1);
trees = [10,50,80,100,150];
N = numel(trees);
erroob = zeros(N,1);
for i=1:N
    R3 = templateTree('Reproducible',true);
    MagicForest3 = fitcensemble(X_Train,Y_Train,'NumLearningCycles',trees(i),'Method','Bag','Learners',R3);
    erroob(i) = oobLoss(MagicForest3);
    errcross(i) = loss(MagicForest3, test_Data,'class');
end
plot(trees,erroob)
axis tight
hold on
h = gca;
plot(trees,errcross,'--k')
legend(["oob Loss","Classification Loss"]);
xlabel('Number  of trees');
ylabel('Error');
 
%% Finding the important predictors
rng(1);
PImp = predictorImportance(MagicForest1);
figure;
bar(PImp);
title('Predictor Importance Estimates');
ylabel('Estimates');
xlabel('Predictors');
h = gca;
h.XTickLabel = MagicForest1.PredictorNames;
h.XTickLabelRotation = 45;
h.TickLabelInterpreter = 'none';
%% Checking through scatterplot if fLength and fAlpha can together alone help in classification
figure
gscatter(train_Data.fLength,train_Data.fAlpha,train_Data.class)
h = gca;
lims = [h.XLim h.YLim]; % Extract the x and y axis limits
title('{\bf Scatter Diagram of Telescope image Measurements}');
xlabel('fLength');
ylabel('fAlpha');
legend('g - 1','h - 0');

%% Creating model with just important predictors
rng(1);
R4 = templateTree('Reproducible',true);
tic
MagicForest4 = fitcensemble(train_Data,'class ~ fLength + fAlpha','Method','Bag','NumLearningCycles',50,'Learners',R4);
toc
% Calculating out of bag loss
oobloss4 = oobLoss(MagicForest4)
oobAcc4 = (1-oobloss4)*100
%% Creating a model using Bayesian optimization.
rng(1);
tic
MagicForestBayesopt = fitcensemble(X_Train,Y_Train,'OptimizeHyperparameters','all','Method','Bag')
toc
% Calculating Classification error
CEOp = loss(MagicForestBayesopt,test_Data,'class');
AccFOp = (1-CEOp)*100;
% Calculating out of bag loss - Uncomment if the method is Bag
%ooblossOp = oobLoss(MagicForestBayesopt);
%oobAccFOp = (1-ooblossOp)*100
%% Random results of Bayesian optimization were used to create models and analyze the errors
rng(1);
MaxSplit = [3434, 4486];
M = numel(MaxSplit);
erroobM = zeros(M,1);
for i=1:M
    RMx = templateTree('MaxNumSplits',MaxSplit(i));
    MagicForestMx = fitcensemble(X_Train,Y_Train,'NumLearningCycles',50,'Method','Bag','Learners',RMx);
    erroobM(i) = oobLoss(MagicForestMx);
    errcrossM(i) = kfoldLoss(crossval(MagicForestMx));
end
plot(MaxSplit,erroobM)
axis tight
hold on
h = gca;
plot(MaxSplit,errcrossM,'--k')
legend(["oob Loss","kfold Loss"]);
xlabel('Maximum number of splits');
ylabel('Error');

%% Creating final model tuning the number of trees and considering the rest default parameters
rng(1);
R5 = templateTree('Reproducible',true);
tic
MagicForest5 = fitcensemble(X_Train,Y_Train,'NumLearningCycles',50,'NumBins',50,'Method','Bag','Learners',R5);
toc
% Calculating classification error
CE5 = loss(MagicForest5,test_Data,'class')
AccF5 = (1-CE5)*100
% Calculating out of bag error
oobPredict5 = oobPredict(MagicForest5);
oobLoss5 = oobLoss(MagicForest5)
oobAcc5 = (1 - oobLoss5)*100
% Calculating resubstitution error
Resubloss5 = resubLoss(MagicForest5)
ResubAcc5 = (1-Resubloss5)*100
% Kfold crossvalidation error
kfoldloss5 = kfoldLoss(fitcensemble(X_Train,Y_Train,'NumLearningCycles',50,'NumBins',50,'Method','Bag','Learners',R5,'kfold',10))
kfoldAcc5 = (1 - kfoldloss5)*100
% Predicting
Magic_Pred5 = predict(MagicForest5, X_Test);
AccP5 = ((sum(Magic_Pred5 == table2array(Y_Test)))/size(Y_Test,1))*100
%% Ploting the losses
rng(1);
figure
plot(oobLoss(MagicForest5,'mode','cumulative'),'k--')
hold on
plot(kfoldLoss(crossval(MagicForest5),'mode','cumulative'),'r-')
plot(loss(MagicForest5,X_Test,Y_Test,'mode','cumulative'))
hold off
xlabel('Number of trees')
ylabel('Classification error')
legend('Out of Bag','Cross-validation','Classification error')

%% Evaluation Metrics
% Creating confusion matrix
confMatMagic = confusionmat(test_Data.class, Magic_Pred5)
confMagic = confusionchart(test_Data.class, Magic_Pred5)

% For calculating precision
confMatMagicT = confMatMagic';
diagonal = diag(confMatMagicT);
sumofrows = sum(confMatMagicT,2);
precisionMagic = diagonal./sumofrows;
overallprecisionMagic = mean(precisionMagic)

% For calculating recall
sumofcol = sum(confMatMagicT,1);
recallMagic = diagonal./sumofcol';
overallrecall = mean(recallMagic)

% Calculating F1 score
f1Magicscore = 2*((overallrecall*overallprecisionMagic)/(overallrecall+overallprecisionMagic))

% Calculating AUC
[RF_test_predicted_class, RF_test_scores] = predict(MagicForest5,X_Test);
[RF_X,RF_Y,RF_T,RF_AUC] = perfcurve(table2array(Y_Test),RF_test_scores(:,2),1);
RF_AUC

% Calculating ROC
plot(RF_X,RF_Y,'LineWidth',2)
xlabel('False positive rate');
ylabel('True positive rate');
title('ROC for Classification using Random Forest');


