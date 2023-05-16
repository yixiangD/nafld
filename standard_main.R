data <- readxl::read_excel("data/OK. Yixiang_Merged database_Med_Austr.xlsx")
# remove duplicated columns, only keep one replicate
colnames(data) <- gsub("\\.\\.\\..", "", colnames(data))
data <- data[, !duplicated(colnames(data))]
outdir <- "./results"
summ <- psych::describe(data)
summ <- cbind(" " = rownames(summ), summ)

input <- c("HSI", "aHSI", "FLI", "AST_ALT", "ALT_AST", "LAP", "TYG", "ION", "FIB4", "NFS", "APRI", "LFS")
input_in_table <- c("HSI", "aHSI", "FLI", "AST_ALT", "ALT_AST", "LAP", "TyGindex", "ION", "FIB4", "NAFLDFibrosisScore", "APRI", "NAFLDLFS_NEW_IDF")
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
out5 <- "AnyBallooning"
# PRESENCE VS ABSENCE OF INFLAMMATION
out6 <- "anyinflammation"
# writexl::write_xlsx(summ, paste(outdir, "data_summary.xlsx", sep = "/"))

# create out variable 1
outs <- c(out1, out2, out3, out4, out5, out6)

geo.col <- "Study"
source("classic_ROC.R")

# read cutoff
df.cutoff <- readxl::read_excel("data/standard_cutoff.xlsx")
input_in_table <- colnames(df.cutoff)[2:dim(df.cutoff)[2]]

res.final <- c()
for (geo.grp in c("ALL")) {
  if (geo.grp == "MED") {
    df <- data[data[[geo.col]] == 1, ]
  } else if (geo.grp == "AUS") {
    df <- data[data[[geo.col]] == 2, ]
  } else {
    df <- data
  }
  # print(unique(df[[geo.col]]))
  for (out in outs) {
    # use this for out variable 2
    if (out == out2) {
      df.loc <- df[!is.na(df[[out]]), ]
    } else {
      df.loc <- df
      df.loc[[out]] <- ifelse(df.loc[[out]] > 0, 1, 0)
    }
    for (in_var in input_in_table) {
      cutoffs <- df.cutoff[, in_var]
      print(in_var)
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
    # writexl::write_xlsx(res$spec, paste0("results/", geo.grp, out, "_spec.xlsx"))
  }
}
writexl::write_xlsx(res.final, "results/standard_cutoff_results0516.xlsx")
