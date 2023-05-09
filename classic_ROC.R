library(cutpointr)
library(pROC)


ROC_fin <- function(
    data,
    x,
    y,
    method = c("best", "cutoff", "maximized"),
    index = NULL,
    cutoff = NULL) {
  # if the method is best you can specify the index = c("youden","closest.topleft")
  # cutoff = NULL #you can specify the cutoff
  # data = aSAH
  # x="s100b"
  # y="outcome"
  # index = "youden"
  x1 <- data[[x]]
  y1 <- data[[y]]

  roc.s100b <- roc(y1, x1, ci = TRUE)
  auc.s100b <- round(roc.s100b$auc[1], 4)
  ci_L <- round(roc.s100b$ci[1], 4)
  ci_U <- round(roc.s100b$ci[3], 4)

  if (method == "best") {
    main_res <- round(coords(roc.s100b, "best",
      ret = c(
        "threshold", "sensitivity", "specificity",
        "ppv", "npv", "accuracy", "auc"
      ),
      best.method = index, transpose = FALSE
    ), 4)
    main_res <- cbind(main_res, auc = auc.s100b, ci_low = ci_L, ci_up = ci_U)

    main_res <- list(best_res = main_res, pl = roc.s100b)
  } else if (method == "cutoff") {
    main_res <- round(coords(roc.s100b, cutoff,
      ret = c(
        "threshold", "sensitivity", "specificity",
        "ppv", "npv", "accuracy"
      ),
      best.method = index, transpose = FALSE
    ), 4)
    main_res <- cbind(main_res, auc = auc.s100b, ci_low = ci_L, ci_up = ci_U)
    main_res <- list(specific_cutoff = main_res, pl = roc.s100b)
  } else {
    min_cons <- c(0.1, 0.25, 0.5, 0.7)

    main_res <- data.frame(
      cut_off = numeric(),
      Sen = numeric(),
      Spec = numeric(),
      PPV = numeric(),
      NPV = numeric(),
      Acc = numeric(),
      Minimum_Specificity = numeric()
    )


    for (ix in 1:length(min_cons)) {
      # constrain specif
      df_ns <- data.frame(Dependent = data[, y], X1 = data[, x])
      colnames(df_ns) <- c("Dependent", "X1")
      df_ns <- df_ns[complete.cases(df_ns), ]
      cp <- cutpointr(
        x = df_ns[, "X1"], class = df_ns[, "Dependent"],
        method = maximize_metric,
        metric = sens_constrain,
        constrain_metric = specificity,
        min_constrain = min_cons[ix]
      )
      test <- summary(cp)
      cutf <- test$confusion_matrix[[1]][[1]] # cutoff
      tp <- test$confusion_matrix[[1]][[2]]
      fn <- test$confusion_matrix[[1]][[3]]
      fp <- test$confusion_matrix[[1]][[4]]
      tn <- test$confusion_matrix[[1]][[5]]
      sens <- (tp) / (tp + fn)
      spec <- (tn) / (tn + fp)
      PPV <- (tp) / (tp + fp)
      NPV <- (tn) / (tn + fn)
      Acc <- (tp + tn) / (tp + fp + tn + fn)

      main_res[ix, 1] <- cutf
      main_res[ix, 2] <- sens
      main_res[ix, 3] <- spec
      main_res[ix, 4] <- PPV
      main_res[ix, 5] <- NPV
      main_res[ix, 6] <- Acc
      main_res[ix, 7] <- min_cons[ix]
      round(main_res, 4)
      main_res_max_sens <- main_res
    }

    main_res <- data.frame(
      cut_off = numeric(),
      Sen = numeric(),
      Spec = numeric(),
      PPV = numeric(),
      NPV = numeric(),
      Acc = numeric(),
      Minimum_Sensitivity = numeric()
    )

    for (ix in 1:length(min_cons)) {
      # constrain specif
      df_ns <- data.frame(Dependent = data[, y], X1 = data[, x])
      colnames(df_ns) <- c("Dependent", "X1")
      df_ns <- df_ns[complete.cases(df_ns), ]

      cp <- cutpointr(
        x = df_ns[, "X1"], class = df_ns[, "Dependent"],
        method = maximize_metric,
        metric = spec_constrain,
        constrain_metric = sensitivity,
        min_constrain = min_cons[ix]
      )
      test <- summary(cp)
      cutf <- test$confusion_matrix[[1]][[1]] # cutoff
      tp <- test$confusion_matrix[[1]][[2]]
      fn <- test$confusion_matrix[[1]][[3]]
      fp <- test$confusion_matrix[[1]][[4]]
      tn <- test$confusion_matrix[[1]][[5]]
      sens <- (tp) / (tp + fn)
      spec <- (tn) / (tn + fp)
      PPV <- (tp) / (tp + fp)
      NPV <- (tn) / (tn + fn)
      Acc <- (tp + tn) / (tp + fp + tn + fn)

      main_res[ix, 1] <- cutf
      main_res[ix, 2] <- sens
      main_res[ix, 3] <- spec
      main_res[ix, 4] <- PPV
      main_res[ix, 5] <- NPV
      main_res[ix, 6] <- Acc
      main_res[ix, 7] <- min_cons[ix]
      round(main_res, 4)
      main_res_max_spec <- main_res
    }
    main_res <- list(
      maximum_sensitivity = main_res_max_sens,
      maximum_specificity = main_res_max_spec,
      pl = roc.s100b
    )
  }
  return(main_res)
}
