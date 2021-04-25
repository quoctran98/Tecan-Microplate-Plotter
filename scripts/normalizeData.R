normalizeData <- function (defTecanFluoresence, defTecanOD, backgroundStrain_name, blankMedia_name) {
  
  normDF <- data.frame()
  treatment_concentration <- 0
  for (treatment_concentration in unique(defTecanFluoresence$treatment)) {
    
    #dataframes of just the raw numbers for both so it's easier to work with
    odMeasurements <- defTecanOD[defTecanOD$treatment == treatment_concentration, 4:ncol(defTecanOD)]
    for (col in 1:ncol(odMeasurements)) {odMeasurements[,col] <- as.numeric(odMeasurements[,col])}
    fluorMeasurements <- defTecanFluoresence[defTecanFluoresence$treatment == treatment_concentration, 4:ncol(defTecanFluoresence)]
    for (col in 1:ncol(fluorMeasurements)) {fluorMeasurements[,col] <- as.numeric(fluorMeasurements[,col])}
    
    #define which rows have blank media and which ones have background strain
    blankMedia_rows <- defTecanOD[defTecanOD$treatment == treatment_concentration, "strains"] == blankMedia_name
    backgroundStrain_rows <- defTecanOD[defTecanOD$treatment == treatment_concentration, "strains"] == backgroundStrain_name
    
    #subtract the od and fluor of blank media from everything (mean by col in case there's more than one blank)
    blankMedia_od <- apply(odMeasurements[blankMedia_rows,], 2, mean)
    odMeasurements <- odMeasurements - blankMedia_od
    blankMedia_fluor <- apply(fluorMeasurements[blankMedia_rows,], 2, mean)
    fluorMeasurements <- fluorMeasurements - blankMedia_fluor
    
    #fluor is now divided by od to normalize
    fluorMeasurements <- fluorMeasurements / odMeasurements
    
    #doing the same sort of thing as subtracting blank measurements, but to get fold over background
    backgroundStrain_fluor <- apply(fluorMeasurements[backgroundStrain_rows,], 2, mean)
    fluorMeasurements <- fluorMeasurements / backgroundStrain_fluor
    
    #add the labels back on
    fluorMeasurements <- cbind(defTecanFluoresence[defTecanFluoresence$treatment == treatment_concentration, 1:3], fluorMeasurements)
    fluorMeasurements <- fluorMeasurements[(!blankMedia_rows & !backgroundStrain_rows),]
    
    normDF <- rbind(normDF, fluorMeasurements)
  }
  
  return(normDF)
}
