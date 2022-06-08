---
title: "ROC Analysis for binary and 3 classes classification"
author: "Melih Agraz"
output: R documents
---

# Description

This is the ROC Analysis in R. CodeROC_binary.R is a ROC analysis from scratch. It uses Naive Bayes Algorithm. pROC is an example to use pROC library. 





### Requirements for CodeROC_binary.R

You must install the related packages below.

```{r setup1, include=FALSE}
install.packages(c("dplyr","ROCR","ggplot2", "PRROC", "klaR", "stringr", 
 "caret"))
```



### Example for CodeROC_binary.R

If you want to run ROC Analysis, you should define the name of your dependent variable and plot should be TRUE, if you need output of plot.

```{r setup1, include=FALSE}
ROC_An(data, 
            dependent = "blood_pressure",
            plot=TRUE)
```
So the output will be the confusion matrix like below.


```{r setup1, include=FALSE}
$accuracy
Sensitivity Specificity         PPV         NPV         AUC 
     0.4375      0.6503      0.0603      0.9575      0.5483 

```


and the plot will be like below.  

 
<img width="539" alt="Screen Shot 2022-06-06 at 14 35 04" src="https://user-images.githubusercontent.com/37498443/172224493-8247f89f-15f9-4608-91e8-37a7ea4b0502.png">


