 
ROC_An <- function(data, 
                   dependent = "Dependent",
                   plot=TRUE){
 
  if( missing(data) ) 
    stop("missing data imputation needed.\n")
  

    #---------------------------------------------------------------------------- library
    if(!require(dplyr)){install.packages("dplyr");require(dplyr)}
    if(!require(ROCR)){install.packages("ROCR");require(ROCR)}
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
    colnames(data)[dim(data)[2]]<-"Dependent"
    data$Dependent<- as.factor(data$Dependent)
    
    
    
    lvls = levels(data$Dependent)
    lvls
   
    
      
    
    aucs = c()
    if(plot == TRUE){
    plot(x=NA, y=NA, xlim=c(0,1), ylim=c(0,1),
         ylab='True Positive Rate',
         xlab='False Positive Rate',
         bty='n')
    }
    head(data);tail(data)
    table(data$Dependent)

    acc_need<-  c("Sensitivity", "Specificity", "PPV", "NPV", "AUC")
    all_res <- matrix(NA, nrow = (3), ncol=length(acc_need))
    colnames(all_res)<-acc_need
    rownames(all_res)<-c("row1", "row2","row3")
 
    
    type.id<-1
    
    inTrain <- createDataPartition(y = data$Dependent, p = 0.8, list = FALSE)
    data_train <- data[inTrain,]
    data_test <- data[-inTrain,]
    dim(data_train)
    
  
      data1<-data_train
      colnames(data1)
      data1$Dependent    =  as.factor(data1$Dependent == lvls[type.id])
      data1$Dependent
      mytarget <- "Dependent"
      myFormula <- as.formula(paste(paste(mytarget,"~"), colnames(data1)[1]))
      myFormula
      
      nbmodel       =  NaiveBayes(myFormula, data=data1)
      resp<-which(colnames(data1)=="Dependent")
      
      nbprediction  =  predict(nbmodel, newdata = data_test, type='raw')
      
      score = nbprediction$posterior[, 'TRUE']
      actual.class = data_test$Dependent == lvls[type.id]
      
      pred   = prediction(score, actual.class)
      nbperf = performance(pred, "tpr", "fpr")
      
      roc.x = unlist(nbperf@x.values)
      roc.y = unlist(nbperf@y.values)
     
      if(plot == TRUE){ 
      pic <- lines(roc.y ~ roc.x, 
                   col = type.id+1, 
                   lwd=2)
      
      nbauc = performance(pred, "auc")
      nbauc = unlist(slot(nbauc, "y.values"))
      aucs[type.id] = nbauc
      nbauc=round(nbauc,2)
      kky<-c( 0.45)
      kkx<-c(  0.7)
      xx<-paste0( paste0("AUC: " ,lvls[type.id]), "_vs_others")
      xx
      d_l<-length( names(data))
      d_l
      
  
      
      legend(kkx[type.id], kky[type.id], nbauc,   
             title =  "AUC", 
             box.lty=0, cex=0.75, text.col = type.id+1
             )
      lines(x=c(0,1), c(0,1))
      }
      
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
      
      #nPVx
      nbnpv = performance(pred, "npv")
      nbnpv = unlist(slot(nbnpv, "y.values"))
      
      # G-means  
      th<-which.max(sqrt(nbsens*nbspec))
      
      
      # "Sensitivity","Specificity","PPV","NPV","AUC"
      
      all_res[type.id,]<-round(c(nbsens[th], nbspec[th], nbppv[th],nbnpv[th], nbauc),4)
      all_res<-all_res[1,]
      all_res
      
    if(plot == TRUE){
    nm<- paste0("ROC_pict", ".jpg")
    nm
      
    dev.copy(jpeg, filename= nm);
    }
    
    
    nm1<-paste0("ROC_acc", ".csv")
    nm1
    
    write.csv(all_res, nm1)
   
  
 return(list(accuracy= all_res))
} # function
