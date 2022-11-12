---
title: "ROC Analysis for binary and 3 classes classification"
author: "Melih Agraz"
output: R documents
---

# Description

This is the ROC Analysis in R with 2 different methods, classical and machine learning (ML). In classical ROC analysis, it uses the conventional ROC analysis method with ```pROC``` library and in the ML ROC analysis it uses the Naive bases method and combines more then 2 biomarkers.  

# 1) Classical ROC Analysis (classic_ROC.R)

## i) Requirements for classic_ROC.R
```{r setup1, include=FALSE}
install.packages(c("pROC",  "cutpointr "))
```

## ii) How the method works?

The main structure of the classical ROC Analysis is:

```
ROC_fin(
    data, 
    x,
    y,
    method = c("best", "cutoff", "maximized"),
    index = NULL,
    cutoff = NULL)
```
Definition of the parameters

```
data: data.frame
x: biomarker.
y: binary output.
method: 3 different methods c("best", "cutoff", "maximized").
index: if the method is "best" you can either select the "youden" or "closest.topleft".
cutoff: you can specify a value in between the biomarker range.
```

### Example for classic ROC Analysis

You can run 3 different version of the classical ROC analysis by specifying the method with "best", "cutoff" or  "maximized". 
#### method = "best"

It is selecting the best cut-off based on the indexes, index = c("youden",“closest.topleft”).

```
ROC_fin(data = aSAH, 
    x="s100b",
    y="outcome",
    method = "best",
    index = "youden",
    cutoff = NULL)
```
output

```
$best_res
          threshold sensitivity specificity  ppv    npv accuracy  auc
threshold     0.205      0.6341      0.8056 0.65 0.7945   0.7434  0.75
```
#### method = "cutoff"
You need to specify the cutoff point of the biomarker and the function will give you the sensitivity, specificity, ppv, npv, accuracy and auc values for that cutoff point.
```
ROC_fin(
  data = aSAH, 
    x="s100b",
    y="outcome",
    method =  "cutoff",
    index = NULL,
    cutoff = 0.11)
```
output 

```
$specific_cutoff
          threshold sensitivity specificity    ppv    npv accuracy auc
threshold      0.11      0.7805      0.4861 0.4638 0.7955   0.5929. 0.75
```

#### method = "maximized"

Maximizing the specificity and sensitivity based on the minimizing the sensitivity and specificity, respectively. 
```
ROC_fin(
    data = aSAH, 
    x="s100b",
    y="outcome",
    method =   "maximized",
    index = NULL,
    cutoff = NULL)
```
output
```
$maximum_sensitivity
  cut_off       Sen      Spec       PPV       NPV       Acc Minimum_Specificity
1   0.060 0.9756098 0.1111111 0.3846154 0.8888889 0.4247788                0.01
2   0.065 0.9756098 0.1388889 0.3921569 0.9090909 0.4424779                0.10
3   0.090 0.8780488 0.3055556 0.4186047 0.8148148 0.5132743                0.25
4   0.120 0.7560976 0.5416667 0.4843750 0.7959184 0.6194690                0.50
5   0.190 0.6341463 0.7777778 0.6190476 0.7887324 0.7256637                0.75

$maximum_specificity
  cut_off       Sen      Spec       PPV       NPV       Acc Minimum_Sensitivity
1    0.74 0.1463415 1.0000000 1.0000000 0.6728972 0.6902655                0.01
2    0.70 0.2195122 1.0000000 1.0000000 0.6923077 0.7168142                0.10
3    0.54 0.2682927 1.0000000 1.0000000 0.7058824 0.7345133                0.25
4    0.30 0.5121951 0.8333333 0.6363636 0.7500000 0.7168142                0.50
5    0.12 0.7560976 0.5416667 0.4843750 0.7959184 0.6194690                0.75
```

# 2) Machine Learning (ML) ROC Analysis (codeROC_binary.R)
## i) Requirements for CodeROC_binary.R

You must install the related packages below.

```{r setup1, include=FALSE}
install.packages(c("dplyr","ROCR","ggplot2", "PRROC", "klaR", "stringr", 
 "caret"))
```


### Example for ML ROC Analysis

If you want to run ROC Analysis, you should define the name of your dependent variable and plot should be TRUE, if you need output of plot.

```{r setup1, include=FALSE}
ROC_Anfin(data, 
            dependent = "blood_pressure",
            plot=TRUE)
```
So the output will be the confusion matrix like below.


```{r setup1, include=FALSE}
$accuracy
Sensitivity Specificity         PPV         NPV    ACC         AUC 
     0.4375      0.6503      0.0603      0.9575   0.856      0.5483 

```


and the plot will be like below.  

 
<img width="539" alt="Screen Shot 2022-06-06 at 14 35 04" src="https://user-images.githubusercontent.com/37498443/172224493-8247f89f-15f9-4608-91e8-37a7ea4b0502.png">

# 3) AND and OR Rule in Machine Learning ROC Analysis

 bu kısım tamamlanmadı henuz, ancak asagidaki literatur taraması isimize yarayabilir. bu kısımda eksikler, 

https://stats.stackexchange.com/questions/120361/what-is-the-convex-hull-in-roc-curve

convex hull
https://pages.stern.nyu.edu/~fprovost/Papers/rocch-mlj.pdf

http://www.bmva.org/bmvc/1998/pdf/p082.pdf

#### ML ROC analizinde roc(actual, predicted_prob)
actual        = 1, 0,  1,  0,  0,  0,   1
predicted_prob=0.6,0.2,0.8,0.2,0.54,0.15,0.9

roc analizi burda ML de en iyi thresholdu predicted probabilityde arar, örneğin 0.8 i secer (0.75 yani olmayan birini de alabilir), ve 0.8 in uszerindekiler 1 altındakiler 0 olarak atanır.  

https://intellipaat.com/blog/confusion-matrix-python/
https://intellipaat.com/blog/roc-curve-in-machine-learning/


basit bir ROC combination method, herbir biomarker icin ayrı ayrı ROC analizi yapıyor vs
https://bmcbioinformatics.biomedcentral.com/articles/10.1186/1471-2105-7-442

