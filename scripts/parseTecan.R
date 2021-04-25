parseTecan <-  function (tecanFilepath) {
  
  rawTecan <- read.xlsx(tecanFilepath)

  #im really happy with how i made this :)
  alphanumeric <- expand.grid(toupper(letters[1:8]), 1:12)
  alphanumeric <- paste(alphanumeric$Var1, alphanumeric$Var2, sep = "")
  
  #get the names and rows of the measurements made
  measurementsIndex <- rawTecan[rawTecan[,1] == "Cycle Nr.",]
  measurementsIndex <- as.numeric(rownames(measurementsIndex[!is.na(measurementsIndex[,1]),])) - 1
  measurementNames <- rawTecan[measurementsIndex,1]
  
  #gets all the rows that are well measurements
  allMeasurements <- rawTecan[rawTecan[,1] %in% alphanumeric,]
  allMeasurements <- allMeasurements[!is.na(allMeasurements[,1]),]
  allMeasurements <- allMeasurements[,!is.na(allMeasurements[1,])] #this should remove excess columns
  
  #oh god this is impossible to understand but...
  #basically it will add the row from allMeasurements to the correct measurement dataframe
  tecanObject <- list()
  for (i in 1:length(measurementsIndex)) {
    measurementDF <- data.frame()
    measurementRow <- measurementsIndex[i]
    
    for (j in 1:nrow(allMeasurements)) {
      wellRow <- as.numeric(rownames(allMeasurements[j,]))
      #if the well is on a row greater than the current measurement label but less than the next one
      if (wellRow > measurementRow) {
        if (!is.na(measurementsIndex[i+1])) {
          if (wellRow < measurementsIndex[i+1]) {
            #add to the dataframe of current measurementDF
            measurementDF <- rbind(measurementDF, allMeasurements[j,]) #
          }
        } else { #for the last measurement name ([i+1] is NA) -- this whole thing is really inelegant :(
          measurementDF <- rbind(measurementDF, allMeasurements[j,])
        }
      }
    }
    
    colnames(measurementDF) <- c("well", 1:(ncol(measurementDF) - 1))
    tecanObject[[measurementNames[i]]] <-  measurementDF
  }
  
  #these settings might only be right for my specific tecan file
  excitation <- rawTecan[rawTecan[,1] == "Excitation Wavelength", 4]
  excitation <- as.numeric(excitation[!is.na(excitation)])
  emission <- rawTecan[rawTecan[,1] == "Emission Wavelength", 4]
  emission <- as.numeric(emission[!is.na(emission)])
  tecanObject$settings <- list(
    excitation = excitation,
    emission = emission
  )
  
  return(tecanObject)
}


