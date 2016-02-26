
# clean up everyting, start new
rm(list = ls())
# define global variables
EZ_GLOBAL_VARIABLES <<- '/home/petervr/myRepo/ezRun/inst/extdata/EZ_GLOBAL_VARIABLES.txt'
sPackWd <- "~/myRepo/ezRun"

### # setting working directory to local ezRun directory
setwd(sPackWd)
sRunMode <- "dev"
# load local version of ezRun or installed version
if (sRunMode == "dev") {
  devtools::load_all()
} else {
  library(ezRun)
}

# define helper function
# running feature count app for multiple sample
runMultiSampleFeatureCount <- function(input=NA, param=NA){
  # input has a tsv-file with all samples
  stopifnot(file.exists(input))
  dfMultiSampleInput <- read.delim(file = input, stringsAsFactors = FALSE)
  # initialize list with results
  lResFeatCount <- list()
  ### # loop over samples in dfMultiSampleInput
  for (samIdx in 1:nrow(dfMultiSampleInput)){
    # single sample parameters
    lOneSampleInput <- list(Name = dfMultiSampleInput[samIdx,"Name"],
                            BAM = dfMultiSampleInput[samIdx,"BAM"])
    lOneSampleOutput <- list(Name = dfMultiSampleInput[samIdx,"Name"],
                             Count = dfMultiSampleInput[samIdx,"Count"],
                             Stats = dfMultiSampleInput[samIdx,"Stats"])
    # run feature count on current sample
    EzAppFeatureCounts$new()$run(input=lOneSampleInput, output=lOneSampleOutput, param=param)
    # rename message file for current run, if alternative is specified
    if(!is.null(dfMultiSampleInput[samIdx, "Msg"])) {
      file.rename(from = "messages.txt", to = dfMultiSampleInput[samIdx, "Msg"])
    }
  }
  invisible(TRUE)
}

# change the working directory to where the results will be placed
sCurWd <- getwd()
setwdNew('/scratch/PVR_test/bamFiles_ExonCounting_results')

# start constructing parameter
sRefFeatureFile <- "/srv/GT/reference/Mus_musculus/Ensembl/GRCm38/Annotation/Version-2014-02-25/Genes/genes.gtf"
refBuild = "Mus_musculus/Ensembl/GRCm38/Annotation/Version-2014-02-25"
param <- ezParam(list(refBuild=refBuild))
# check whether feature file can be found
stopifnot(file.exists(param[['ezRef']]@refFeatureFile))

param[['cores']] = '1'
param[['ram']] = '16'
param[['scratch']] = '100'
param[['node']] = ''
param[['process_mode']] = 'DATASET'
param[['mail']] = 'peter.vonrohr@gmail.com'
param[['dataRoot']] = ''
param[['gtfFeatureType']] <- "exon"    # default
param[['featureLevel']] <- "exon"  #"gene"
param[['allowMultiOverlap']] <- TRUE
param[['paired']] <- TRUE
param[['strandMode']] <- "both"
param[['minMapQuality']] <- 0         # default
param[['minFeatureOverlap']] <- 1     # default
param[['keepMultiHits']] <- TRUE
param[['countPrimaryAlignmentsOnly']] <- FALSE


# specify output information  
#output = list()
#output[['Name']] = 'bamFiles_ExonCounting_results'
#output[['Count']] = 'feature_counts'
#output[['Stats']] = 'feature_stats'

#input = '/home/petervr/myRepo/ezRun/inst/extdata/mm_feature_count/small_dataset_local_ext.tsv'
input = '/home/petervr/myRepo/ezRun/inst/extdata/mm_feature_count/complete_dataset_local_ext.tsv'

# create a wrapper for running multiple samples
runMultiSampleFeatureCount(input = input, param = param)

# unlink copied bam and bai files
unlink("*.bam")
unlink("*.bai")

# reset wd
setwd(sCurWd)
