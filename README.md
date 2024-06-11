MTFAP a comprehensive master transcription factors prediction and analysis platform with different types data
We provide 3 script files：

bulk-rna-analysis.R

This script is used for analyzing gene expression data using the CaCTS package in R. It reads in a gene names file and a processed table, calculates the CaCTS score for a specified cancer type, and filters the results based on expression rank. The output is the filtered result.

single-rna-analysis.R

This R script analyzes gene expression data to identify GO terms associated with cancer using the CaCTS package.It processes the input data, calculates scores, and filters results based on user-defined parameters.The script then outputs a list of GO terms sorted by their relevance to the specified cancer type.

dependency-boxplot.R

This R script analyzes gene expression data to identify GO terms associated with cancer. It takes multiple CSV files as input, each representing a different cancer type, and requires the name of the gene to be analyzed. The output is a boxplot showing the distribution of the gene's expression across the different cancer types.



