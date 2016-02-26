###
###
###   Purpose:   How converting gtf to gff
###   started:   2016/02/12
###
### ######################################### ###

# rm(list = ls())
require(rtracklayer)
require(GenomicRanges)
require(GenomicFeatures)

### # target gff file
sGffDir <- system.file("extdata", package = "pasilla")
sGffFn <- file.path(sGffDir, "Dmel.BDGP5.25.62.DEXSeq.chr.gff")

# read target gff file, this is the format that we need eventually
grTargetGff <- import.gff(sGffFn)
# give meta info columns
mcols(grTargetGff)

### # what was used so far
sGtfDir <- "/srv/GT/reference/Mus_musculus/Ensembl/GRCm38/Annotation/Version-2014-02-25/Genes/genes.gtf"
grSourceGtf <- import.gff(sGtfDir)
mcols(grSourceGtf)

smallGtf <- grSourceGtf[1:30]
