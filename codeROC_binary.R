# pROC3 nin gelismis hali
# burda grafik ve cross validation yok

library(dplyr)
library(ROCR)
library(ggplot2)
library(PRROC)
library(klaR)
library(stringr)
library(caret)

ROC_Anfin4 <- function(data, dependent = "Dependent",   k=5){
  
  stopifnot(!missing(data))
  #----------------------------------------------------------------------------
  col_name <- colnames(data)
  moveYtoEnd<-function(df,  dependent ){ 
    
    yvar<-dependent
    cnames <- colnames(df)
    idx <- which(cnames == yvar)
    idxs <- which(cnames != yvar)
    orderedNames <- c(cnames[idxs], cnames[idx])
    df <- subset(df, select=orderedNames)
    return(df)
  }
  data<-moveYtoEnd(data,  dependent) # sort of the dependent variable
  
  colnames(data)[dim(data)[2]]<-"Dependent"
  data$Dependent <- factor(data$Dependent)
  
  lvls = levels(data$Dependent)
  aucs = c()
  
  
  acc_need<-  c("Sensitivity", "Specificity", "PPV", "NPV","ACC", "AUC")
  all_res <- matrix(NA, nrow = (k), ncol=length(acc_need))
  colnames(all_res)<-acc_need
  
  
  rownames(all_res)<-  paste0("row",seq(1:k))
  
  folds <- createFolds(data$Dependent, k = k)
  type.id<-1
  
  for (i in 1:k) {
    
    #inTrain <- createDataPartition(y = data$Dependent, p = 0.8, list = FALSE)
    testIndex <- folds[[i]]
    
    data_train <- data[-testIndex,]
    data_test <-  data[testIndex,]
    
    data1<-data_train
    
    data1$Dependent    =  as.factor(data1$Dependent == lvls[type.id])
    mytarget <- "Dependent"
    
    myFormula <- as.formula(paste(paste(mytarget,"~"), "."))
    nbmodel       =  NaiveBayes(myFormula, data=data1)
    resp<-which(colnames(data1)=="Dependent")
    
    nbprediction  =  predict(nbmodel, newdata = data_test, type='raw')
    score = nbprediction$posterior[, 'TRUE']
    actual.class = data_test$Dependent == lvls[type.id]
    
    pred   = prediction(score, actual.class)
    nbperf = performance(pred, "tpr", "fpr")
    
    roc.x = unlist(nbperf@x.values)
    roc.y = unlist(nbperf@y.values)
    
 
 
    #AUC
    nbauc = performance(pred, "auc")
    nbauc = unlist(slot(nbauc, "y.values"))
    aucs[type.id] = nbauc
    #Sens 
    nbsens = performance(pred, "sens")
    nbsens = unlist(slot(nbsens, "y.values"))
    #Spec
    nbspec = performance(pred, "spec")
    nbspec = unlist(slot(nbspec, "y.values"))
    #PPV
    nbppv = performance(pred, "ppv")
    nbppv = unlist(slot(nbppv, "y.values"))
    #nPV
    nbnpv = performance(pred, "npv")
    nbnpv = unlist(slot(nbnpv, "y.values"))
    #acc
    nbacc = performance(pred, "acc")
    nbacc = unlist(slot(nbacc, "y.values"))
    # G-means  
    th<-which.max(sqrt(nbsens*nbspec))
    
    # "Sensitivity","Specificity","PPV","NPV","AUC"
    all_res[i,]<-round(c(nbsens[th], nbspec[th], nbppv[th],nbnpv[th], nbacc[th], nbauc),4)
    #all_res<-all_res2[i,]
    
    # if(plot == TRUE){
    #   nm<- paste0("ROC_pict", ".jpg")
    #   dev.copy(jpeg, filename= nm);
    # }
    nm1<-paste0("ROC_acc", ".csv")
    # write.csv(all_res, nm1)
  }# end of for loop
  resFin<-apply(all_res, 2, mean)
  
  return(list(nFold_accuracy=  resFin))
}
