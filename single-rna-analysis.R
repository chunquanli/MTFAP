#!/usr/bin/env Rscript
if (!requireNamespace("CaCTS", quietly = TRUE)){
  BiocManager::install("CaCTS")
  q()
}

# library packages
suppressMessages(library(CaCTS))
suppressMessages(library(optparse))
suppressMessages(library(getopt))


#输入参数和帮助文档
spec = matrix(c(
  'help'          , 'h', 0, "logical"  , "for help",
  'rank1'         , 'g', 1, "character", "input the gene names file [required, csv format, only one column, no header]",
  'rank2'        , 'e', 1, "character", "output file outdir [optional, default: cwd]",
  'rank3'           , 't', 1, "character", "a GO-to-genes rank3pings file separated by tab delimiter [required]",
  'rank4'          , 'p', 1, "numeric", "out file name prefix [optional, default: output]",
  'rank5' , 'n', 1, "numeric"  , "the number of top scoring GO terms which .... [optional, default: 5]",
  'ontology'      , 'O', 1, "character", "character string specifying the ontology of interest (BP, MF or CC) [optional, default: BP]"
), byrow=TRUE, ncol=5);

opt = getopt(spec)

#定义函数参数为空时退出
print_usage <- function(spec=NULL){
  cat("")
  cat(getopt(spec, usage=TRUE));
  q(status=1);
}
#检查非空参数
if ( is.null(opt$rank1) )     { print_usage(spec)}
if ( is.null(opt$rank2) )    { print_usage(spec)}
if ( is.null(opt$rank3) )    { print_usage(spec)}
if ( is.na(opt$rank4) )    { print_usage(spec)}
if ( is.na(opt$rank5) )    { print_usage(spec)}
library(CaCTS)
library(optparse)
library(getopt)
annot.table <-read.delim(opt$rank1)###读入组别表格
colnames(annot.table)[1] <- "cell.type"
colnames(annot.table)[3] <- "sample.id"
colnames(annot.table)[2] <- "group.name"
rank3=opt$rank3
head(annot.table)
annot.table$group.name <- paste0(annot.table$cell.type, "-", annot.table$group.name)
head(data.frame(table(annot.table$group.name)), 20)
f.TCGA.RNA = read.delim(opt$rank2)###读入处理好的表格
rownames(f.TCGA.RNA) <- f.TCGA.RNA$sample.id
f.TCGA.RNA <- f.TCGA.RNA[,2:ncol(f.TCGA.RNA)]
delta1 = max(f.TCGA.RNA, na.rm = T) - min(f.TCGA.RNA, na.rm = T)
delta2 = max(f.TCGA.RNA, na.rm = T) - 0
f.TCGA.RNA.rs = (f.TCGA.RNA - min(f.TCGA.RNA, na.rm = T)) * delta1 / delta2
matrix.rep <- prepare_representaive_samples(expr.matrix = f.TCGA.RNA.rs, sample.descr = annot.table, save.file = F)
cancer = as.character(rank3)  ##选择要的组别
res.CaCTS <- run_CaCTS_score(matrix.rep, cancer)
filtered <- filter_by_expression_rank(rep.matrix = matrix.rep, tf.scores = res.CaCTS, query.name = cancer,pn= opt$rank4, pnE= opt$rank5)###pn是jsd排名数字，pnE是数字
filtered###输出结果

