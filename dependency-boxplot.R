#!/usr/bin/env Rscript

# 加载所需的包
#if (!requireNamespace("tidyverse", quietly = TRUE)){
#  BiocManager::install("tidyverse")
 # q()
#}

if (!requireNamespace("ggplot2", quietly = TRUE)){
  BiocManager::install("ggplot2")
  q()
}

# library packages
suppressMessages(library(ggplot2))
#suppressMessages(library(tidyverse))
suppressMessages(library(getopt))

# 输入参数和帮助文档
spec <- matrix(c(
  'help', 'h', 0, "logical", "for help",
  'csv1', '1', 1, "character", "input CSV file 1 [required]",
  'csv2', '2', 1, "character", "input CSV file 2 [optional]",
  'csv3', '3', 1, "character", "input CSV file 3 [optional]",
  'csv4', '4', 1, "character", "input CSV file 4 [optional]",
  'csv5', '5', 1, "character", "input CSV file 5 [optional]", 
  'csv6', '6', 1, "character", "input CSV file 6 [optional]",  
  'csv7', '7', 1, "character", "input CSV file 7 [optional]",
  'csv8', '8', 1, "character", "input CSV file 8 [optional]",
  'csv9', '9', 1, "character", "input CSV file 9 [optional]",
  'csv10', '10', 1, "character", "input CSV file 10 [optional]",
  'gene', 'g', 1, "character", "input gene [required]",
  'output', 'o', 1, "character", "output file name [required]"
), byrow=TRUE, ncol=5)

# 解析参数
opt <- getopt(spec)

# 检查非空参数
if (is.null(opt$csv2) || is.null(opt$gene) || is.null(opt$output) ) {
  print_usage(spec)
}

# 读取CSV文件
csv_files <- c(opt$csv1, opt$csv2, opt$csv3, opt$csv4, opt$csv5, opt$csv6, opt$csv7, opt$csv8, opt$csv9, opt$csv10)
csv_files <- csv_files[!is.na(csv_files)] # 去除未提供的CSV文件


dfs <- lapply(csv_files, function(file) {
  read.csv(file, header = TRUE, row.names = 1)
})


# # 函数用于将多个ggplot对象绘制在一个坐标轴中
# multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
#   require(ggplot2)
#   
#   # 检查plotlist是否是一个列表对象，如果是则转换为数据框
#   if (is.null(plotlist)) {
#     plotlist <- list(...)
#   }
#   
#   if (!is.list(plotlist)) {
#     stop("plotlist不是列表对象！")
#   }
#   
#   # 提取绘图列表中的行数和列数
#   nrows <- length(plotlist) %/% cols
#   nrows <- nrows + ifelse(length(plotlist) %% cols > 0, 1, 0)
#   
#   # 如果没有指定layout，则根据列数和行数设置layout
#   if (is.null(layout)) {
#     # 设置layout
#     layout <- matrix(seq(1, cols * nrows), ncol = cols, nrow = nrows)
#   }
#   
#   if (nrows == 1) {
#     layout <- t(layout)
#   }
#   
#   if (length(plotlist) == 1) {
#     return(plotlist[[1]])
#   } else {
#     # 设置绘图区域
#     par(mfrow = layout, mar = c(1, 1, 2, 1))
#     
#     # 绘制图形
#     for (i in 1:length(plotlist)) {
#       plotlist[[i]]
#     }
#   }
# }
# 


# 提取基因对应列并绘制箱线图
gene <-opt$gene

cancer_names <- sapply(csv_files, function(file) {
  gsub("Table_for_", "", gsub(".csv", "", strsplit(file, "/")[[1]][length(strsplit(file, "/")[[1]])]))
})

plots <- list()
combined_data <- data.frame()
for (i in 1:length(dfs)) {
  data <- dfs[[i]]
  cancer_name <- cancer_names[i]
  
  if (gene %in% colnames(data)) {
    gene_data <- data[, gene]
    combined_data <- rbind(combined_data, data.frame(cancer_name = cancer_name, gene_data = gene_data))
  } else {
    warning(paste("Gene", gene, "not found in", csv_files[i]))
  }
}

p <- ggplot(combined_data, aes(x = cancer_name, y = gene_data,fill = cancer_name )) +
  geom_boxplot() +
  stat_boxplot(geom ='errorbar', width = 0.5)+
  geom_jitter(color="black", size=0.8, alpha=0.9)+ #添加数据点
  labs(x = "Cancer", y = gene)
 

# for (i in 1:length(dfs)) {
#   data <- dfs[[i]]
#   cancer_name <- cancer_names[i]
#   
#   if (gene %in% colnames(data)) {
#     gene_data <- data[, gene]
#     
#     p <- ggplot(data, aes(x = cancer_name, y = gene_data)) +
#       geom_boxplot() +
#       labs(x = "Cancer", y = gene) +
#       ggtitle(paste(cancer_name, gene, sep = "_"))
#     
#     plots[[i]] <- p
#   } else {
#     warning(paste("Gene", gene, "not found in", csv_files[i]))
#   }
# }

output_name <- paste(cancer_names, collapse = "_")
output_name <- paste(output_name, gene, sep = "_")
output_name <- paste(output_name, "png", sep = ".")
output_dir<-opt$output
output_path <- file.path(output_dir, output_name)
png(output_path, width =1800, height =900,res = 150)
p 
dev.off()

