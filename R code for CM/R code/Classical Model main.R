###########################################################
##Classical Model, as coded by Tina Nane and Tong Dong#####
###########################################################

#set pathway
# The working directory must be the "R code for CM" folder that contains
# the "R code" and "Expert data" sub-folders. Two easy ways to do it:
#   * RStudio: Session -> Set Working Directory -> To Source File Location,
#     then run  setwd("..")  so the wd is one level above this script.
#   * Command line: run R from inside the "R code for CM" folder.
# The line below tries to do it automatically when the script is sourced.
if (requireNamespace("rstudioapi", quietly = TRUE) &&
    rstudioapi::isAvailable()) {
  setwd(dirname(dirname(rstudioapi::getSourceEditorContext()$path)))
}
#original hard-coded paths (kept for reference):
#setwd("D:/surfDrive/R code for CM")
#setwd("C:/Users/gsinguran/surfdrive/SEJ/R code for Esma")


Nquantiles = 3
quantilesPercent = c("5%","50%","95%")
quantiles = c(0.05, 0.50, 0.95)

# load other functions
source("R code/calibrationScore.R")
source("R code/informationScore.R")
source("R code/constructDM.R")
source("R code/globalWeights_opt.R")
source("R code/globalWeights_alpha.R")
source("R code/itemWeights.R")
source("R code/itemWeights_alpha.R")
source("R code/itemWeights_opt.R")


#import the data that we have so far
realizations_file = read.csv("Expert data/realizations.csv")
 
#get the vector of realizations
realizations = realizations_file[,2]
#get the list of questions
questions = realizations_file[,1]

m = list() # create empty list of matrices for assessment data

# read experts assessments
badReads = 0
goodReads = 0


#select which data to choose
path = "Expert data"
#read the expert data - needs to have Exp in the name of the csv file
pattern = "Exp.*\\.csv$"      # only read expert data, not realizations
csvFiles = list.files(path = path, pattern = pattern)
# sort filenames in natural order
numbers = as.numeric(regmatches(csvFiles, regexpr("[0-9]+", csvFiles)))
csvFiles = csvFiles[order(numbers)]

# expertMappingRev[idx in m] == expertID in csv file
expertMappingRev = array()

for (file in csvFiles) {
  tryCatch(
    {
      filename = sprintf("%s/%s", path, file)
      dataAll = read.csv(filename)
      
      # get assessments
        data = dataAll[3:5][,]
      
      # get expert ID
      expertID = as.integer(dataAll[1][1,])
      # skip expert manually
      
      expertMappingRev[goodReads+1] = expertID
      
      # check if assessments are strictly increasing
      for (row in 1:NROW(data)) {
        if (any(diff(t(data[row,]))<=0)) {
          errorString = sprintf("Error assessments for %s question %d are not strictly increasing", filename, row)
          stop(errorString)
        }
      }
      
      mm = as.matrix(data, nrow=NROW(data), ncol=Nquantiles)
      if (typeof(mm) == "double" || typeof(mm) == "integer") {
        m[[goodReads+1]] = mm
        goodReads = goodReads + 1
      } else {
        print("Error cannot interpret data as numeric")
        badReads = badReads + 1
      }
    },
    warning=function(cond) {
      print(cond)
      message("Warning cannot read csv file")
      badReads = badReads + 1
    }
  )
}

cat("Found", length(csvFiles), "csv files\n")
numExperts = goodReads      # number of experts
cat("Read", numExperts, "experts\n")
cat("Cannot read", badReads, "experts\n")
N = NROW(m[[1]])   # total number of questions

# create labels for all experts
labelsExperts = c()
for (e in 1:numExperts) {
  labelsExperts = c(labelsExperts, sprintf("Expert %d", expertMappingRev[[e]]))
}

##########################################################################################################################################
#############performance of experts#######################################################################################################
##########################################################################################################################################
#calibration scores
calibrationScores = calculateCalibrationScore(m,realizations) 
dimnames(calibrationScores) = list(labelsExperts)

print("calibration scores")
print(calibrationScores)

# calculate information scores
tmp = calculateInformationScore(m, realizations, k=0.1, bounds=NULL)
informationScores = tmp[[1]]
L = tmp[[2]]
U = tmp[[3]]

#print(informationScores)
informationScoresCalAvg = colMeans(informationScores[which(!is.na(realizations)),]) 
informationScoresAllAvg = colMeans(informationScores)

print("information scores calibration questions")
print(informationScoresCalAvg)
print("information scores all questions")
print(informationScoresAllAvg)

#combined scores
combinedScores = calibrationScores * informationScoresCalAvg

#performance_based weights
perfweights = combinedScores / sum(combinedScores)


##########################################################################################################################################
############costruction of DM ############################################################################################################
##########################################################################################################################################
# To create Decision Maker (DM):
# - for every question, define vector with x values where CDF of DM changes gradient
#   this is on every experts assessment
# - for every x value, calculate y value
#
# Equal Weights Decision Maker (EWDM)
# Performance Weights Decision Maker (PWDM)

equalWeights = 1/numExperts

#######################################################################
#############DMs and solutions#########################################
#######################################################################

#construct the DMs
EWDM = constructDM(m,rep(equalWeights,numExperts), NULL, L, U, quantiles)
PWDM = constructDM(m, perfweights, NULL, L, U, quantiles)

#obtain all sort of weights
#global optimized
perf_opt = perfWeights_opt(m,realizations)

PWDM_opt = constructDM(m, perf_opt, NULL, L, U, quantiles)

#global with cut off value alpha
perf_alpha = perfWeights_alpha(m,realizations,0.05)

PWDM_alpha = constructDM(m, perf_alpha, NULL, L, U, quantiles)

#item weights
item_weights = itemWeights(m,realizations)

IWDM = constructDM(m, item_weights, NULL, L, U, quantiles)

#item weights opt
item_weights_opt = itemWeights_opt(m,realizations)[[1]]

IWDM_opt = itemWeights_opt(m,realizations)[[2]]

#item weights with cut off value
item_alpha = itemWeights_alpha(m,realizations,0.05)

IWDM_alpha = constructDM(m, item_alpha, NULL, L, U, quantiles)

#############################
###DMs solutions#############
############################

print("EWDM solution")
print(EWDM)

print("PWDM solution")
print(PWDM)

print("PWDM optimized solution")
print(PWDM_opt)

print("PWDM alpha=0.05 solution")
print(PWDM_alpha)

print("IWDM optimized solution")
print(IWDM_opt)


#####################################################################
########performance of DMs###########################################
#####################################################################
#cal scores
PWDMCalScore = calculateCalibrationScoreStatic(list(PWDM), realizations)
EWDMCalScore = calculateCalibrationScoreStatic(list(EWDM), realizations)

#info scores
tmp = calculateInformationScoreStatic(list(PWDM),realizations, k=0.1, bounds=NULL, L, U)
PWDMInfoScoreAll = mean(tmp[[1]])
PWDMInfoScoreCal = mean(tmp[which(!is.na(realizations))][[1]])
tmp = calculateInformationScoreStatic(list(EWDM),realizations, k=0.1, bounds=NULL, L, U)
EWDMInfoScoreAll = mean(tmp[[1]])
EWDMInfoScoreCal = mean(tmp[which(!is.na(realizations))][[1]])

cat("PWDM calScore: ", PWDMCalScore, ", infoScoreAll: ", PWDMInfoScoreAll, ", infoScoreCal: ", PWDMInfoScoreCal, "\n")
cat("EWDM calScore: ", EWDMCalScore, ", infoScoreAll: ", EWDMInfoScoreAll, ", infoScoreCal: ", EWDMInfoScoreCal, "\n")


