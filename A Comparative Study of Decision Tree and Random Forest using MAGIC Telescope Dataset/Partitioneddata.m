%% Loading the 
% Installed - Statistics and Machine Learning toolbox
% Installed - Parallel Computing Toolbox
% Loading the data after performing EDA in python
df = readtable('Magic_df.csv','ReadVariableNames',true);
VarNames = {'fLength','fWidth', 'fSize', 'fConc','fConc1','fAsym','fM3Long','fM3Trans','fAlpha','fDist','class'};
df.Properties.VariableNames = VarNames;

%% Partitioning the dataset
% Dividing the data into training and test data
rng(1);
cv_par = cvpartition(df.class,'Holdout',0.2);
train_Data = df(training(cv_par),:);
test_Data = df(test(cv_par),:);
 
%% 
% Export the partitioned training and test sets of data. %

writetable(train_Data,'Partitiontrainset.csv');
writetable(test_Data,'Partitiontestset.csv');
