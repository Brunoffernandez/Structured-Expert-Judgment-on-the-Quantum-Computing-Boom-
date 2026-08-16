# item based weights
itemWeights<-function(assessments, realizations)
{
  Nexperts = length(assessments)      # number of experts
  N = NROW(assessments[[1]])

  #which are calibration variables
  Cal = which(!is.na(realizations))
  # which are the variables of interest
  QoI = which(is.na(realizations))
  
  # create labels for all questions
  labelsQuestions = c()
  for (q in Cal) {
    labelsQuestions = c(labelsQuestions, sprintf("CAL%d", q))
  }
  for (q in QoI) {
    labelsQuestions = c(labelsQuestions, sprintf("QoI%d", q))
  }
  
  for (e in 1:Nexperts) {
    dimnames(assessments[[e]][c(Cal,QoI),]) = list(labelsQuestions, quantilesPercent)
  }
  
  calibrationScores = calculateCalibrationScore(assessments,realizations)
  
  tmp = calculateInformationScore(assessments, realizations, k=0.1, bounds=NULL, Larg = NULL, Uarg = NULL)
  
  informationScores = tmp[[1]]
  L = tmp[[2]]
  U = tmp[[3]]
  
  itemWeights = matrix(0, nrow=N, ncol=Nexperts)
  dimnames(itemWeights) = list(labelsQuestions, labelsExperts)
  for (q in 1:N) {
    itemWeights[q,] = calibrationScores * informationScores[q,]
    itemWeights[q,] = itemWeights[q,] / sum(itemWeights[q,])
  }
  
  return(itemWeights)
}
