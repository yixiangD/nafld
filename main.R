source("ROC_ML.R")

data0 <- readxl::read_excel("../dataJan2023.xlsx", sheet = 1)
data1 <- readxl::read_excel("../DATABASE FOR MELIH.xlsx", sheet = 1)
data2 <- readxl::read_excel("../DATABASE FOR MELIH.xlsx", sheet = 2)

colnames(data1) <- gsub("\\.\\.\\..", "", colnames(data1))
data1 <- data1[, !duplicated(colnames(data1))]
col1 <- colnames(data1)
col2 <- colnames(data2)
col.same <- intersect(col1, col2)
df <- merge(data1, data2, by = col.same)
filename <- "../Melih_results.xlsx"
sheets <- readxl::excel_sheets(filename)
x <- lapply(sheets, function(X) readxl::read_excel(filename, sheet = X))
# print(x)
names(x) <- sheets
# col.feat <-
stop()
data.sel <- data %>%
  dplyr::select(c(col.feat, col.outcome))
ROC_Anfin4(data.sel, dependent, k)
