data <- readxl::read_excel("data/NAFLD April 2023 Australia and Mediterranean Database (Laura Valenzuela).xlsx")
# remove duplicated columns, only keep one replicate
colnames(data) <- gsub("\\.\\.\\..", "", colnames(data))
data <- data[, !duplicated(colnames(data))]
outdir <- "./results"
summ <- psych::describe(data)
summ <- cbind(" " = rownames(summ), summ)

input <- c("HSI", "aHSI", "FLI", "AST_ALT", "ALT_AST", "LAP", "TYG", "ION", "FIB4", "NFS", "APRI", "LFS")
input_in_table <- c("HSI", "aHSI", "FLI", "AST_ALT", "ALT_AST", "LAPIndex", "TyG index", "ION", "FIB-4", "NAFLD Fibrosis Score", "APRI", "NAFLD-LFS")
colnames(data) <- sapply(colnames(data), function(x) trimws(x))
# Control vs all
out1 <- "ControlsVsAll" # derive from column named "Group Class", merge lean & obese, merge NAFL & NASH
# NAFL VS NASH
out2 <- "NAFL_NASH" # also from "Group Class"
# FIBROSIS F0-1 VS F2-4
out3 <- "FIBROSIS01" # column named Fibrosis01vs23
# FIBROSIS F0-2 VS F3-4
out4 <- "FIBROSIS012" # column named Fibrosis012vs3
# PRESENCE VS ABSENCE OF BALOONINNG
out5 <- "BALLOONING" # column named AnyBallooning
# PRESENCE VS ABSENCE OF INFLAMMATION
out6 <- "INFLAMMATION" # column named anyinflammation
# writexl::write_xlsx(summ, paste(outdir, "data_summary.xlsx", sep = "/"))

# create out variable 1
# data[, out1] <- ifelse(grepl("Control", data$`Group Class`), "control", "case")
# use this for out variable 2
data2 <- data[!grepl("Control", data$`Group Class`), ]

geo.grp <- "MED" # "AUS", "ALL"
geo.col <- "Database0Mediterranean1Australian"
in_var <- input_in_table[1]
source("classic_ROC.R")
res <- ROC_fin(data[data[[geo.col]] == 0, ], in_var, out1, "maximized")
print(res)
