---
title: "ROC Analysis for binary and 3 classes classification"
author: "Melih Agraz"
output: R documents
---

# Description

This is the ROC Analysis of in R. 

```base_ML_.main.R```, ```self_ML_.main.R``` and ```CO_ML_.main.R``` are the main part of the conventional, self training and co-training machine learning of code, respectively. 

## Conventional Machine Learning (base_.R)

```base_ML.main.R``` is the main code of the conventional machine learning. You can run Logisctic Regression, Naive Bayes, XGBoost, Support Vector Machine and Random Forest conventional Machine Learning models. You must type ```method="Logisctic Regression"``` or ```method="Naive Bayes"``` or ```method="SVM"``` or ```method="Xgboost"``` or ```method="Random Forest"``` to run conventional machine learning models.  If your data is imbalanced, you can balance your data with ```imbalanced=TRUE```. You can choose the number of folds by ```n_fold```, default is 5.  We have already done the feature selection algorithm for ACCORD dataset and specified the selected features. For this reason, you can select these specified features by typing ```feature_sel =  "Boruta"``` or ```feature_sel =  "Lasso"``` or ```feature_sel =  "MRMR"``` OR if you want to work on only the full ACCORD data, you can type ```feature_sel =  "NO FS"```.

!!Column name of your response variable must be  ```out```.


### Requirements

You must install the related packages below.

```{r setup1, include=FALSE}
install.packages(c("caret","rpart","e1071", "dplyr", "randomForest", "xgboost", 
 "ROSE", "praznik", "gridExtra", "adabag"))
```

### Example

If you want to run Logistic Regression,  on imbalanced data on training set, without feature selection, with 5 fold cross validation, you can run the code below. 

```{r setup1, include=FALSE}
Baseline_Hyp(dataL = dataL, 
                 method           = "Logistic Regression" ,
                 imbalanced       =  TRUE,
                 feature_sel      =  "NO FS",
                 n_fold           =  5 s
)
```
So the output will be the confusion matrix like below.


```{r setup1, include=FALSE}
           NPV       PPV      Spec      Sens       Acc        F1
[1,] 0.9130425 0.1835661 0.5912669 0.6118235 0.5943996 0.2803637

```


If you want to run SVM, working on NOT imbalanced data, with LASSO feature selection, with 5-fold cross validation, you can run the code below.  

```{r setup1, include=FALSE}
Baseline_Hyp(dataL = dataL, 
                 method           = "SVM" ,
                 imbalanced       =  FALSE,
                 feature_sel      =  "Lasso",
                 n_fold           =  5 
)
```

If you want to run all the combinations of ```method```, and ```feature_sel```, you can go to the ```base_ML.run.R``` (it is not necessary).  


