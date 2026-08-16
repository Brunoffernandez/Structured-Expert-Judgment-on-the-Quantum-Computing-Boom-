# item based weights
itemWeights_alpha<-function(assessments, realizations,alpha)
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
  
  itemWeights_alpha = matrix(0, nrow=N, ncol=Nexperts)
  dimnames(itemWeights_alpha) = list(labelsQuestions, labelsExperts)
  for (q in 1:N) {
    itemWeights_alpha[q,] = calibrationScores * informationScores[q,]* (calibrationScores >= alpha)
    itemWeights_alpha[q,] = itemWeights_alpha[q,] / sum(itemWeights_alpha[q,])
  }
  
  return(itemWeights_alpha)
}
