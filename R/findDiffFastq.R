###
###
###
###   Purpose:   Find differences between two fastq files
###   started:   2016/01/29 (pvr)
###
### ####################################################### ###

# clean up
# rm(list = ls())

### #################
### functions
#' Write reads that are different between result sets of two trimming methods
#' 
#' Reads are read from fastq file that are results from the same input for 
#' two trimming methods. One method is always called the base method which 
#' is the reference for trimming. The other method is the one that is compared 
#' to the base method of trimming.
writeDiffFastq <- function(psBaseFastqDir, psBaseFastqFile, psCompareFastqDir, psCompareFastqFile) {
  ### # get the vector of ids of test 1 in base
  fqt1base <- readFastq(dirPath = psBaseFastqDir, 
                        pattern = psBaseFastqFile, 
                        withIds = TRUE)
  idst1base <- as.vector(id(fqt1base))
  cat(" * Number of ids in base: ", length(idst1base), "\n")
  ### # get vector of ids of test 1 in compare
  fqt1compare <- readFastq(dirPath = psCompareFastqDir, 
                           pattern = psCompareFastqFile, 
                           withIds = TRUE)
  idst1compare <- as.vector(id(fqt1compare))
  cat(" * Number of ids in compare: ", length(idst1compare), "\n")
  ### # find all ids that are in base but not in compare, please note order of arguments to setdiff() is important 
  idInBaseNotInCompare <- setdiff(idst1base,idst1compare)
  cat(" * Number of reads in base and not in compare: ", length(idInBaseNotInCompare), "\n")
  
  ### # vector of indices where reads are in fqt1base
  idInBaseNotInCompareIdx <- sapply(idInBaseNotInCompare, function(x) which(x == idst1base), USE.NAMES = FALSE)
  
  ### # write reads from base that are not in compare method set to output file
  writeFastq(fqt1base[idInBaseNotInCompareIdx], 
             file = file.path(psBaseFastqDir,
                              paste0("trim_method_diff-",psBaseFastqFile)), 
             full = TRUE, 
             compress = FALSE)
  
}

# constants
lMethodSettings <- list(trimmirna    = list(fastqDir    = "20160129101316-trimmirna",
                                            test1FqFile = "test1_R1.fastq",
                                            test2FqFile = "test2_R1.fastq"),
                        ezMethodTrim = list(fastqDir    = "20160129101322-ezMethodTrim",
                                            test1FqFile = "test1-trimmed-R1.fastq",
                                            test2FqFile = "test2-trimmed-R1.fastq"))
# root where all results were stored
dataDir <- "/scratch/PVR_test"

# set working directory to where files are
setwd(dataDir)

# choose one method as basemethod to which the other one will be compared to, 
# save all ids from reads in basemethod that are not in other method
# base method trimmirna
sBaseMethod <- "trimmirna"
sCompareMethod <- "ezMethodTrim"

#setwd(file.path(dataDir,lMethodSettings[[sBaseMethod]]$fastqDir))
cat(" * Working directory set to: ", getwd(), "\n")

cat(" * Base method:    ", sBaseMethod, "\n")
cat(" * Compare method: ", sCompareMethod, "\n")

### # compare test1 for trimmirna und ezMethodTrim
#writeDiffFastq(psBaseFastqDir = lMethodSettings[[sBaseMethod]]$fastqDir, 
#               psBaseFastqFile = lMethodSettings[[sBaseMethod]]$test1FqFile, 
#               psCompareFastqDir = lMethodSettings[[sCompareMethod]]$fastqDir, 
#               psCompareFastqFile = lMethodSettings[[sCompareMethod]]$test1FqFile)

# quality report comparing original reads with the once not found in comparison
qa1 <- qa(lMethodSettings[[sBaseMethod]]$fastqDir, "*test1_R1.fastq", type= "fastq")
#browseURL(report(qa1))

### # compare test2 for trimmirna und ezMethodTrim
writeDiffFastq(psBaseFastqDir = lMethodSettings[[sBaseMethod]]$fastqDir, 
               psBaseFastqFile = lMethodSettings[[sBaseMethod]]$test2FqFile, 
               psCompareFastqDir = lMethodSettings[[sCompareMethod]]$fastqDir, 
               psCompareFastqFile = lMethodSettings[[sCompareMethod]]$test2FqFile)

qa2 <- qa(lMethodSettings[[sBaseMethod]]$fastqDir, "*test2_R1.fastq", type= "fastq")
#browseURL(report(qa2))

# alternative quality report with /usr/local/ngseq/opt/FastQC-0.11.3/fastqc test1_R1.fastq trim_method_diff-test1_R1.fastq
