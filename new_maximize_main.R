data <- readxl::read_excel("data/NAFLD Database_locked_20230615.xlsx", sheet = 2)
# remove duplicated columns, only keep one replicate
colnames(data) <- gsub("\\.\\.\\..", "", colnames(data))
data <- data[, !duplicated(colnames(data))]
outdir <- "./results"
summ <- psych::describe(data)
summ <- cbind(" " = rownames(summ), summ)

input <- c("HSI", "aHSI", "FLI", "AST_ALT", "ALT_AST", "LAP", "TYG", "ION", "FIB4", "NFS", "APRI", "LFS")
input_in_table <- c("HSI", "aHSI", "FLI", "AST_ALT", "ALT_AST", "LAP", "TyG", "TyGo", "ION", "FIB4", "APRI", "NAFLDLFS_NEW_ATPIII")
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
# writexl::write_xlsx(summ, paste(outdir, "data_summary.xlsx", sep = "/"))

# create out variable 1
outs <- c(out1, out2, out3, out4, out5, out6)

# update Matina typo of TyGo
tyg.indc <- which(grepl("TyG", colnames(data)))
for (ind in tyg.indc) {
  if (colnames(data)[ind] != "TyG") {
    colnames(data)[ind] <- "TyGo"
  }
}
# basic checking
for (i in input_in_table) {
  if (!i %in% colnames(data)) {
    print(paste(i, "not in sheet", sep = " "))
  }
}
for (i in outs) {
  if (!i %in% colnames(data)) {
    print(paste(i, "not in sheet", sep = " "))
  }
}

geo.col <- "Bariatric01"
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

for (geo.grp in c("ALL", "0", "1")) {
  if (geo.grp != "ALL") {
    df <- data[data[[geo.col]] == geo.grp, ]
  } else {
    df <- data
  }
  print(geo.grp)
  # print(unique(df[[geo.col]]))
  sens.res <- c()
  spec.res <- c()
  for (out in outs) {
    # use this for out variable 2
    if (out == out2) {
      df.loc <- df[!is.na(df[[out]]), ]
    } else {
      df.loc <- df
      df.loc[[out]] <- ifelse(df.loc[[out]] > 0, 1, 0)
    }
    # print(df.loc)
    print(unique(df.loc[[out]]))
    res <- gen_res_table(df.loc, input_in_table, out)
    # res$sens$out <- rep(out, dim(res$sens)[1])
    res$sens$out <- out
    res$spec$out <- out
    sens.res <- rbind(sens.res, res$sens)
    spec.res <- rbind(spec.res, res$spec)
  }
  writexl::write_xlsx(sens.res, paste0("results/BARB_", geo.grp, "_sens.xlsx"))
  writexl::write_xlsx(spec.res, paste0("results/BARB_", geo.grp, "_spec.xlsx"))
}
