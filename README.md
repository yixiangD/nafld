---
title: "ROC Analysis for binary and 3 classes classification"
author: "Melih Agraz"
output: R documents
---

# Description

This is the ROC Analysis of in R. 

```base_ML_.main.R```, ```self_ML_.main.R``` and ```CO_ML_.main.R``` are the main part of the conventional, self training and co-training machine learning of code, respectively. 




### Requirements

You must install the related packages below.

```{r setup1, include=FALSE}
install.packages(c("dplyr","ROCR","ggplot2", "PRROC", "klaR", "stringr", 
 "caret"))
```



### Example

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


