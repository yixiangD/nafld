---
title: "ROC Analysis for binary and 3 classes classification"
author: "Melih Agraz"
output: R documents
---

# Description

This is the ROC Analysis in R. ```CodeROC_binary.R``` is a ROC analysis from scratch. It uses Naive Bayes Algorithm. pROC is an example to use pROC library. 





### Requirements for CodeROC_binary.R

You must install the related packages below.

```{r setup1, include=FALSE}
install.packages(c("dplyr","ROCR","ggplot2", "PRROC", "klaR", "stringr", 
 "caret"))
```


### Example for classic ROC Analysis

You can run 3 different version of the classical ROC analysis. Specify the method with "best","cutoff" or  "maximized". 
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
          threshold sensitivity specificity  ppv    npv accuracy
threshold     0.205      0.6341      0.8056 0.65 0.7945   0.7434
```
#### method = "cutoff"

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
          threshold sensitivity specificity    ppv    npv accuracy
threshold      0.11      0.7805      0.4861 0.4638 0.7955   0.5929

    ```
### Example for CodeROC_binary.R

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




