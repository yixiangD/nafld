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
out4 <- "F01_2_34"
# PRESENCE VS ABSENCE OF BALOONINNG
out5 <- "AnyBallooning"
# PRESENCE VS ABSENCE OF INFLAMMATION
out6 <- "anyinflammation"
# writexl::write_xlsx(summ, paste(outdir, "data_summary.xlsx", sep = "/"))

# create out variable 1
outs <- c(out1, out2, out3, out4, out5, out6)

geo.col <- "Study"
source("classic_ROC.R")

gen_res_table <- function(df, input_in_table, out) {
  sens_res <- c()
  spec_res <- c()
  for (in_var in input_in_table) {
    if (sum(is.na(df[[in_var]])) == length(df[[in_var]])) {
      sens <- NA
      spec <- NA
    } else {
      res <- ROC_fin(df, in_var, out, "maximized")
      sens <- res$maximum_sensitivity[4, 1:6]
      sens$feature <- in_var
      sens_res <- rbind(sens_res, sens)

      spec <- res$maximum_specificity[4, 1:6]
      spec$feature <- in_var
      spec_res <- rbind(spec_res, spec)
    }
  }
  row.names(sens_res) <- NULL
  row.names(spec_res) <- NULL
  return(list(sens = sens_res, spec = spec_res))
}

for (geo.grp in c("AUS", "MED", "ALL")) {
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
    print(df.loc)
    print(unique(df.loc[[out]]))
    res <- gen_res_table(df.loc, input_in_table, out)
    writexl::write_xlsx(res$sens, paste0("results/", geo.grp, out, "_sens.xlsx"))
    writexl::write_xlsx(res$spec, paste0("results/", geo.grp, out, "_spec.xlsx"))
  }
}
