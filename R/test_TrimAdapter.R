
# clean up everyting, start new
rm(list = ls())


# define global variables
EZ_GLOBAL_VARIABLES <<- '/home/petervr/myRepo/ezRun/inst/extdata/EZ_GLOBAL_VARIABLES_20151204.txt'
setwd("~/myRepo/ezRun")
devtools::load_all()
#library(ezRun)

#' run method for TrimTester
ezMethodTrimTest <- function(input=NA, output=NA, param=NA){
  setwdNew(basename(output$getColumn("Report")))
  param$readCountsBarplot = basename(output$getColumn("TrimCounts"))
  if(param$trimMethod == "trimmirna") {
    cat(" * Running runTrimMiRna ...\n")
    runTrimMiRna(input=input, dataset=input$meta, param=param)
  } else if(param$trimMethod == "ezMethodTrim") {
    cat(" * running ezMethodTrim...\n")
    runEzMethodTrim(input, output, param)
 
  } else {
    cat(" * Trimming method: ", param$trimMethod, " not implemented ...\n")
  }
  return("Success")
}

#' Reference class for testing trimming
EzTrimTester <- setRefClass(Class = "EzTrimTester",
                            contains = "EzApp",
                            methods = list(
                              initialize = function(){
                                "Initializes the application using its specific defaults."
                                runMethod <<- ezMethodTrimTest
                                name <<- "EzAppNcpro"
                              }
                            ))

#' Define a function that calls the trimming using trimMirna
#' 
runTrimMiRna <- function(input, dataset, param=NULL){
  samples = rownames(dataset)
  fqFiles = input$getFullPaths(param, "Read1")
  names(fqFiles) = samples
  adapter = unique(dataset$Adapter1)
  stopifnot(length(adapter) == 1)
  jobList = lapply(fqFiles, function(fq){list(input=fq, output=file.path(getwd(), sub(".gz$", "", basename(fq))))})
  .myFunc = function(job, param){
    trimMirna(input=job$input, output=job$output, adapter=adapter, param=param)
  }
  buildName = param$ezRef["refBuildName"]
  trimmedFastqFiles = unlist(ezMclapply(jobList,.myFunc,param=param,mc.cores=as.numeric(param[['cores']]),mc.preschedule =FALSE, mc.set.seed=FALSE))
  cat(" * Trimmed fastqfiles:\n")
  print(trimmedFastqFiles)
}

#' Preparing and running ezMethodTrim()
#' 
runEzMethodTrim <- function(input=NA, output=NA, param=NA) {
  # parameters specific for ezMethodTrim
  param[['trimAdapter']]            <-  TRUE
  param[['minTailQuality']]         <-  20
  param[['minAvgQuality']]          <-  4
  param[['minReadLength']]          <-  18
  #param[['onlyAdapterFromDataset']] <- TRUE
  param[['onlyAdapterFromDataset']] <- FALSE
  
  # calling the trim method
  refobjOutput <- ezMethodTrim(input, output=NA, param)
  cat(" * Structure of output:\n")
  str(refobjOutput)
  cat(" * Cat meta information:\n")
  dfMetaInf <- refobjOutput$meta
  print(dfMetaInf)
  fastqfiles <- as.vector(refobjOutput$meta[,"Read1 [File]"])
  names(fastqfiles) <- rownames(dfMetaInf)
  cat(" * Fastq files:\n")
  print(fastqfiles)
  
}


# ### ### Below this, constants are set and the test is run #################### ###
setwdNew('/scratch/PVR_test')
param = list()
param[['cores']] = '1'
param[['ram']] = '16'
param[['scratch']] = '100'
param[['node']] = ''
param[['process_mode']] = 'DATASET'
param[['refBuild']] = 'Mus_musculus/UCSC/mm10/Annotation/Version-2012-05-23'
param[['name']] = 'ncPRO_Result'
#param[['mail']] = 'lopitz@fgcz.ethz.ch1'
param[['mail']] = 'peter.vonrohr@gmail.com'
param[['dataRoot']] = ''
param[['resultDir']] = 'p1001/Count_ncPRO_Report_8955_2015-11-27--13-35-21'


output = list()
output[['Name']] = 'ncPRO_Result'
output[['Species']] = ''
output[['refBuild']] = 'Mus_musculus/UCSC/mm10/Annotation/Version-2012-05-23'
output[['Report [File]']] = 'p1001/Count_ncPRO_Report_8955_2015-11-27--13-35-21/ncPRO_Result'
output[['Html [Link]']] = 'p1001/Count_ncPRO_Report_8955_2015-11-27--13-35-21/ncPRO_Result/ncpro/report.html'
output[['TrimCounts [Link]']] = 'p1001/Count_ncPRO_Report_8955_2015-11-27--13-35-21/ncPRO_Result/trimCounts-barplot.png'

input = '/home/petervr/myRepo/ezRun/inst/extdata/smRNA_250k/dataset_local.tsv'
bckinput = '/home/petervr/myRepo/ezRun/inst/extdata/smRNA_250k/dataset_local.tsv.backup'

#input = '/home/petervr/myRepo/ezRun/inst/extdata/smRNA_250k/dataset.tsv'

# loop over both trimming methods
for (m in c("trimmirna","ezMethodTrim")) {
  cat(" * Trimming method: ", m, "\n")
  param[['trimMethod']] <- m
  # cleanup output dir, if it exists
  if (dir.exists(output$Name)) unlink(output$Name, recursive = T)
  
  # restore original dataset file
  file.copy(from = bckinput, to = input, overwrite = TRUE)
  
  # run trimMiRna
  EzTrimTester$new()$run(input=input, output=output, param=param)
  
  # save away the result to prevent from cleaning up in the next round
  setwd('/scratch/PVR_test')
  if (dir.exists(output$Name)) file.rename(from = output$Name, 
                                           to = paste(format(Sys.time(), "%Y%m%d%H%M%S"), param$trimMethod, sep = "-"))
}
