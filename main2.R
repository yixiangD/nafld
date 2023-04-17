data <- readxl::read_excel("data/NAFLD April 2023 Australia and Mediterranean Database (Laura Valenzuela).xlsx")
# remove duplicated columns, only keep one replicate
colnames(data) <- gsub("\\.\\.\\..", "", colnames(data))
data <- data[, !duplicated(colnames(data))]
outdir <- "./results"
summ <- psych::describe(data)
summ <- cbind(" " = rownames(summ), summ)
writexl::write_xlsx(summ, paste(outdir, "data_summary.xlsx", sep = "/"))
