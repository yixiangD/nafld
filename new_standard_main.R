data <- readxl::read_excel("data/NEW corrected NFS Yixiang June 26 2023.xlsx", sheet = 2)
# data <- readxl::read_excel("data/OK. Yixiang_Merged database_Med_Austr.xlsx")
# remove duplicated columns, only keep one replicate
args <- commandArgs(trailingOnly = TRUE)
opt <- args[1]
stopifnot(opt %in% c("bmi_below_40", "", "no_t2d"))

colnames(data) <- gsub("\\.\\.\\..", "", colnames(data))
data <- data[, !duplicated(colnames(data))]
outdir <- "./results"
# summ <- psych::describe(data)
# summ <- cbind(" " = rownames(summ), summ)

input <- c("HSI", "aHSI", "FLI", "AST_ALT", "ALT_AST", "LAP", "TYG", "ION", "FIB4", "NFS", "APRI", "LFS")
# input_in_table <- c("HSI", "aHSI", "FLI", "AST_ALT", "ALT_AST", "LAP", "TyG", "TyGo", "ION", "FIB4", "APRI", "NAFLDLFS_NEW_ATPIII")
colnames(data) <- sapply(colnames(data), function(x) trimws(x))
# Control vs all
out1 <- "ControlsVsAll" # derive from column named "Group Class", merge lean & obese, merge NAFL & NASH
# NAFL VS NASH
out2 <- "NAFLvsNASH"
# FIBROSIS F0-1 VS F2-4
out3 <- "F01_234"
# FIBROSIS F0-2 VS F3-4
out4 <- "F02_34"
# PRESENCE VS ABSENCE OF BALOONINNG
out5 <- "Ballooning_01"
# PRESENCE VS ABSENCE OF INFLAMMATION
out6 <- "Inflammation_01"

# create out variable 1
outs <- c(out1, out2, out3, out4, out5, out6)

if (opt == "no_t2d") {
  data <- data[data["DiabetesYES1NO0"] == "0", ]
} else if (opt == "bmi_below_40") {
  data <- data[data["BMIcmm2"] < 40, ]
}
# update Matina typo of TyGo
tyg.indc <- which(grepl("TyG", colnames(data)))
for (ind in tyg.indc) {
  if (colnames(data)[ind] != "TyG") {
    colnames(data)[ind] <- "TyGo"
  }
}
# basic checking
for (i in outs) {
  if (!i %in% colnames(data)) {
    print(paste(i, "not in sheet", sep = " "))
  }
}

geo.col <- "Bariatric01"
source("classic_ROC.R")

# read cutoff
df.cutoff <- readxl::read_excel("data/standard_cutoff_matina.xlsx")
input_in_table <- colnames(df.cutoff)[2:dim(df.cutoff)[2]]
for (i in input_in_table) {
  if (!i %in% colnames(data)) {
    print(paste(i, "not in sheet", sep = " "))
  }
}

res.final <- c()
for (geo.grp in c("ALL", "0", "1")) {
  if (geo.grp != "ALL") {
    df <- data[data[[geo.col]] == geo.grp, ]
  } else {
    df <- data
  }
  print(geo.grp)
  for (out in outs) {
    # use this for out variable 2
    # if (out == out2) {
    df.loc <- df[!is.na(df[[out]]), ]
    # } else {
    #  df.loc <- df
    #  df.loc[[out]] <- ifelse(df.loc[[out]] > 0, 1, 0)
    # }
    if (length(unique(df.loc[[out]])) < 2) {
      print("out")
      print(out)
      print(unique(df.loc[[out]]))
      res.final[nrow(res.final) + 1, ] <- NA
      res.final[nrow(res.final), "outcome"] <- "out"
      res.final[nrow(res.final), "group"] <- geo.grp
    } else {
      for (in_var in input_in_table) {
        cutoffs <- df.cutoff[, in_var]
        for (cutoff in cutoffs[!is.na(cutoffs)]) {
          res <- ROC_fin(df.loc, in_var, out, "cutoff", "youden", cutoff)
          ret <- res$specific_cutoff
          ret$feature <- in_var
          ret$outcome <- out
          ret$group <- geo.grp
          rownames(ret) <- NULL
          res.final <- rbind(res.final, as.data.frame(ret))
        }
      }
    }
    # writexl::write_xlsx(res$spec, paste0("results/", geo.grp, out, "_spec.xlsx"))
  }
}
writexl::write_xlsx(res.final, paste0("results/", opt, "_", "standard_cutoff_results0621.xlsx"))
