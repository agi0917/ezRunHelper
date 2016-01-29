
# clean up everyting, start new
rm(list = ls())
# define global variables
EZ_GLOBAL_VARIABLES <<- '/home/petervr/myRepo/ezRun/inst/extdata/EZ_GLOBAL_VARIABLES_20151204.txt'
setwd("~/myRepo/ezRun")
devtools::load_all()
#library(ezRun)

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

# cleanup output dir, if it exists
if (dir.exists(output$Name)) unlink(output$Name, recursive = T)

# restore original dataset file
file.copy(from = bckinput, to = input, overwrite = TRUE)

# run ezproapp
EzAppNcpro$new()$run(input=input, output=output, param=param)
