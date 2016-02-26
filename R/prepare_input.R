#input = '/home/petervr/myRepo/ezRun/inst/extdata/mm_feature_count/small_dataset_local.tsv'
input = '/home/petervr/myRepo/ezRun/inst/extdata/mm_feature_count/complete_dataset_local.tsv'
dfSmallInput <- read.delim(file = input, stringsAsFactors = FALSE)
Count <- gsub("bam$", "fc", basename(dfSmallInput$BAM))
Stats <- gsub("bam$", "fs", basename(dfSmallInput$BAM))
dfSmallInput <- cbind(dfSmallInput,Count,Stats)
write.table(dfSmallInput, file = "/home/petervr/myRepo/ezRun/inst/extdata/mm_feature_count/complete_dataset_local_ext.tsv", 
            sep = "\t", 
            row.names = FALSE,
            quote = FALSE)

# add message stuff to input
Msg <- sapply(dfMultiSampleInput$Name, function(x) paste(x, "msg", sep = "."), USE.NAMES = FALSE)
dfMultiSampleInput <- cbind(dfMultiSampleInput, Msg)

write.table(dfMultiSampleInput, file = "/home/petervr/myRepo/ezRun/inst/extdata/mm_feature_count/complete_dataset_local_ext.tsv", 
            sep = "\t", 
            row.names = FALSE,
            quote = FALSE)