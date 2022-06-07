
# burda   
# sadece roc paketi var
# roc(output,  predict(glm(Y~X1+X2)))
# ayrica ci lar hesaplandi
# train/test olarak bolmedik (Laura lar oyle yapmıslar)

ROC_An <- function(data, 
                   dependent = "Dependent", 
                   plot=TRUE){
  
  if( missing(data) ) 
    stop("missing data imputation needed.\n")
  
  
  #---------------------------------------------------------------------------- library
  if(!require(dplyr)){install.packages("dplyr");require(dplyr)}
  if(!require(pROC)){install.packages("pROC");require(pROC)}
  if(!require(ggplot2)){install.packages("ggplot2");require(ggplot2)}
  if(!require(PRROC)){install.packages("PRROC");require(PRROC)}
  if(!require(klaR)){install.packages("klaR");require(klaR)}
  if(!require(stringr)){install.packages("stringr");require(stringr)}
  if(!require(caret)){install.packages("caret");require(caret)}
  #----------------------------------------------------------------------------
  
  
  
  j<-1
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
  data
  colnames(data)
  colnames(data)[dim(data)[2]]<-"Dependent"
  data$Dependent<- as.factor(data$Dependent)
  colnames(data)
  
  
  lvls = levels(data$Dependent)
  lvls
  
  
  
  type.id<-2
  aucs = c()
  
  
  
  head(data);tail(data)
  table(data$Dependent)
  
  
  
  inTrain <- createDataPartition(y = data$Dependent, p = 1, list = FALSE)
  data_train <- data[inTrain,]
  data_test  <- data_train
  dim(data_train)
  head(data_train)
  dim(data_test)
  head(data_test)
  
  data1<-data_train
  colnames(data1)
  data1$Dependent    =  as.factor(data1$Dependent == lvls[type.id])
  data1$Dependent
  mytarget <- "Dependent"
  
  
  myFormula <- as.formula(paste(paste(mytarget,"~"),
                                paste(colnames(data1)[1:(length(colnames(data1))-1)],collapse = "+")
  ))
  myFormula
  
  nbmodel       =  NaiveBayes(myFormula, data=data1)
  resp<-which(colnames(data1)=="Dependent")
  
  nbprediction  =  predict(nbmodel, newdata = data_test, type='raw')
  score = nbprediction$posterior[, 'TRUE']
  actual.class = data_test$Dependent == lvls[type.id]
  
  roc1_t5<-roc(actual.class, score, plot=TRUE)
  th<-coords(roc1_t5, "best", best.method="youden")
  th$threshold
  auc99<-roc1_t5$auc[1]
  
  acc_meas<-coords(roc1_t5,  th$threshold, ret=c("sens", "spec", "ppv", "npv", "acc"))
  
  
  nbprediction1<-nbprediction
  nbprediction1
  
  table(nbprediction1$class)
  ci.roc<-ci.auc(roc1_t5, conf.level=0.95, method=c("delong"))
  
  res98<- data.frame(acc_meas, auc=auc99, 
                     ci.low=ci.roc[1],
                     ci.upp=ci.roc[3])
  all_res<- res98
  all_res
  rownames( all_res)<-NULL
  
  
  
  
  nm<- paste0("ROC_pict", ".jpg")
  nm
  
  dev.copy(jpeg, filename= nm);
  
  
  
  nm1<-paste0("ROC_acc", ".csv")
  nm1
  
  write.csv(all_res, nm1)
  
  
  return(list(accuracy= all_res))
} # function
