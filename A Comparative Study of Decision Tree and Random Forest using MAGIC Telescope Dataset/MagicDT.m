close all;
clear all;
clc;
%% Decision Tree %%
%% Loading the data which was partitioned using holdout validation
% Importing the training and test data.
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

%% Creating a simple model using normalized data
rng(1);
tic
MagictreeN = fitctree(X_TrainN,Y_Train);
toc
% Calculating the resubstitution error
ResublossN = resubLoss(MagictreeN);
ResubAccN = (1-ResublossN)*100;
% Calculating cross validation error
KfoldlossN = kfoldLoss(fitctree(train_Data,'class','Kfold',10));
KfoldAccN = (1-KfoldlossN)*100;
% Calculating classification error
CEN = loss(MagictreeN,test_Data,'class');
AccN = (1-CEN)*100;

%% Creating a simple model without normalized data
% Decision Tree
rng(1);
tic
Magictree1 = fitctree(train_Data,'class');
toc
% Calculating the resubstitution errors
Resubloss1 = resubLoss(Magictree1);
ResubAcc1 = (1-Resubloss1)*100;
% Calculating the cross validation errors
Kfoldloss1 = kfoldLoss(fitctree(train_Data,'class','Kfold',10));
KfoldAcc1 = (1-Kfoldloss1)*100;
% Calculating the classification errors
CE1 = loss(Magictree1,test_Data,'class');
Acc1 = (1-CE1)*100;

%% Adding noise to the data - Uncomment to check the results
%rng(1);
%train_Data.fLength = train_Data.fLength + 1*randn(size(train_Data.fLength));
%train_Data.fWidth = train_Data.fWidth + 1*randn(size(train_Data.fWidth));
%train_Data.fSize = train_Data.fSize + 1*randn(size(train_Data.fSize));
%train_Data.fConc = train_Data.fConc + 1*randn(size(train_Data.fConc));
%train_Data.fConc1 = train_Data.fConc1 + 1*randn(size(train_Data.fConc1));
%train_Data.fAsym = train_Data.fAsym + 1*randn(size(train_Data.fAsym));
%train_Data.fM3Long = train_Data.fM3Long + 1*randn(size(train_Data.fM3Long));
%train_Data.fM3Trans = train_Data.fM3Trans + 1*randn(size(train_Data.fM3Trans));
%train_Data.fAlpha = train_Data.fAlpha + 1*randn(size(train_Data.fAlpha));
%train_Data.fDist = train_Data.fDist + 1*randn(size(train_Data.fDist));

%% Making a model using noise dataset - Uncomment to check the results
% It drastically impacts the accuracy
%tic
%Magictreenoise = fitctree(train_Data,'class');
%toc
%Kfoldloss2 = kfoldLoss(fitctree(train_Data,'class','Kfold',10));
%KfoldAcc2 = (1-Kfoldloss1)*100
%RMSE2 = loss(Magictreenoise,test_Data,'class');
%Acc2 = (1-RMSE2)*100

%% Predicting the important predictors
% Checking if considering the important predictors (standard CART algorithm) can improve the
% performance
rng(1);
PImp = predictorImportance(Magictree1);
figure;
bar(PImp);
title('Predictor Importance Estimates');
ylabel('Estimates');
xlabel('Predictors');
h = gca;
h.XTickLabel = Magictree1.PredictorNames;
h.XTickLabelRotation = 45;
h.TickLabelInterpreter = 'none';
%% Creating a model with important predictors
rng(1);
tic
Magictree3 = fitctree(train_Data, 'class ~ fAlpha + fLength')
toc
% Calculating the crossvalidation error
Resubloss3 = resubLoss(Magictree3);
ResubAcc3 = (1-Resubloss3)*100;
% Calculating cross validation error
rng(1);
Kfoldloss3 = kfoldLoss(fitctree(train_Data,'class ~ fAlpha + fLength','Kfold',10));
Kfoldloss3_1 = kfoldLoss(fitctree(train_Data,'class ~ fAlpha + fLength + fWidth + fAsym + fM3Long + fM3Trans + fDist','Kfold',10));
KfoldAcc3 = (1-Kfoldloss3)*100;
KfoldAcc3_1 = (1-Kfoldloss3_1)*100;
% Calculating classification error
CE3 = loss(Magictree3,test_Data,'class');
Acc3 = (1-CE3)*100;
% The important predictors do not help in increasing the accuracy.
% Instead they drastically decrease it.
%% Understanding the significance of split
% Controling the depth [Ref: Statistics and Machine Learning Toolbox User's
% Guide]
rng(1);
MagictreeDefaultsplit = fitctree(X_Train,Y_Train,'kfold',10);
numBranches = @(X_Train)sum(X_Train.IsBranch);
DefaultNumSplits = cellfun(numBranches, MagictreeDefaultsplit.Trained);
figure;
histogram(DefaultNumSplits)
% Veiwing decision tree
view(MagictreeDefaultsplit.Trained{1},'Mode','graph') % A very messy tree is generated
% Checking if numner of splits can help to reduce complexity
Magictree9Split = fitctree(X_Train,Y_Train,'MaxNumSplits',870,'kfold',10);
view(Magictree9Split.Trained{1},'Mode','graph')
% Comapring the errors of the models
kfoldDefaultloss = kfoldLoss(Magictree9Split);
kfold9Splitloss = kfoldLoss(Magictree9Split);
kfoldDefaultAcc = (1-kfoldDefaultloss)*100;
kfold9SplitAcc = (1-kfold9Splitloss)*100;
% Although the error increases slightly the model complexity decreases
%% Pruning
% fitctree has by default pruning as on
% Trying pruning - uncomment to check decision tree using pruning
%[~,~,~,bestlevel] = cvLoss(Magictree1,...
 %'SubTrees','All','TreeSize','min')
%view(Magictree1,'Mode','Graph','Prune',43)
%Magic_Pred = predict(Magictree1, X_Test);
%% Understanding the significance of minimum leaf size
% Controling the depth [Ref: Statistics and Machine Learning Toolbox User's
% Guide]
rng(1);
leafs = logspace(1,2,10);
N = numel(leafs);
err = zeros(N,1);
for i=1:N
 MdlLeaf = fitctree(X_Train,Y_Train,'crossval','on','MinLeafSize',leafs(i));
 err(i) = kfoldLoss(MdlLeaf);
end
plot(leafs,err)
xlabel('Min Leaf Size');
ylabel('cross-validated error');
% Using the output of the graph to check the error generated after tuning
% leaf size
rng(1);
MagictreeLeaf30 = fitctree(X_Train,Y_Train,'MinLeafSize',20);
kfoldlossLeaf30 = kfoldLoss(fitctree(X_Train,Y_Train,'MinLeafSize',20,'kfold',10));
kfoldLeaf30Acc = (1-kfoldlossLeaf30)*100;
% This has increased the accuracy
%% Manually tuning the Hyperparameters
%
rng(1);
tic
MagictreeMT = fitctree(X_Train,Y_Train,'MinLeafSize',20,'MaxNumSplits',870,'SplitCriterion','gdi','PredictorSelection','allsplits');
toc
% Calculating the resubstitution error
Resubloss1 = resubLoss(MagictreeMT)
ResubAcc1 = (1-Resubloss1)*100
% Calculating kfold validation loss
rng(1);
kfoldlossMT = kfoldLoss(fitctree(X_Train,Y_Train,'MinLeafSize',20,'MaxNumSplits',870,'SplitCriterion','gdi','kfold',10))
kfoldAccMT = (1 - kfoldlossMT)*100
% Testing the model using test data
Magic_PredMT = predict(MagictreeMT, X_Test);
% Calculating classification loss
CEMT = loss(MagictreeMT,test_Data,'class')
AccMT = (1-CEMT)*100
% Manual calculation of accuracy
Acc = ((sum(Magic_PredMT == table2array(Y_Test)))/size(Y_Test,1))*100
%% Uncomment to check Optimization using Parallel Bayesian Algorithm 
% It will use Parallel Bayesian Algorithm
% Install - Parallel Computing tool box
%hypopts = struct('ShowPlots',true,'Verbose',1,'UseParallel',true);
%poolobj = gcp;
%MagicModelPB = fitctree(train_Data,'class','OptimizeHyperparameters','all','HyperparameterOptimizationOptions', hypopts)
%% Applying Bayesian optimization automatically
rng(1);
tic
MagictreeOp = fitctree(train_Data,'class','OptimizeHyperparameters','all')
toc
% Calculating the resubstitution error
ResublossOp = resubLoss(MagictreeOp);
ResubAccOp = (1-ResublossOp)*100;
% Testing the model using test data
rng(1);
Magic_PredOp = predict(MagictreeOp, X_Test);
% Calculating classification loss
CEOp = loss(MagictreeOp,test_Data,'class');
AccOp = (1-CEOp)*100;
% Manual calculation of accuracy
Acc = ((sum(Magic_PredOp == table2array(Y_Test)))/size(Y_Test,1))*100;

%% Evaluation Metrics
% Creating confusion matrix
confMatMagic = confusionmat(test_Data.class, Magic_PredMT)
confMagic = confusionchart(test_Data.class, Magic_PredMT)

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

% Calculating ROC and AUC
[DT_test_predicted_class, DT_test_scores] = predict(MagictreeMT,X_Test);
[DT_X,DT_Y,DT_T,DT_AUC] = perfcurve(table2array(Y_Test),DT_test_scores(:,2),1);
DT_AUC

plot(DT_X,DT_Y,'LineWidth',3);
xlabel('False positive rate');
ylabel('True positive rate');
title('ROC for Classification using Decision Tree');

%% End
