#performance-based weights function that would provide the weights given a set of calibration questions 
#given an alpha cut off value

perfWeights_alpha<-function(assessments,realizations, alpha)
{
  
  calibrationScores = calculateCalibrationScore(assessments,realizations)
  
  tmp = calculateInformationScore(assessments, realizations, k=0.1, bounds=NULL)
  informationScores = tmp[[1]][which(!is.na(realizations)),]
  L = tmp[[2]][which(!is.na(realizations))]
  U = tmp[[3]][which(!is.na(realizations))]
  
  informationScoresCalAvg = colMeans(informationScores) 
  
  # combined score
  combinedScores = calibrationScores * informationScoresCalAvg
  
  weights_alpha = combinedScores * (calibrationScores >= alpha)
  weights_alpha = weights_alpha / sum(weights_alpha)

  
  return(weights_alpha)
}