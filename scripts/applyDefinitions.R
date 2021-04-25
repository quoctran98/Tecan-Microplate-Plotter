applyDefinitions <- function (tecanObject, definitionObject) {
  
  #turns alphanumeric (A1-H12) into rows and columns
  alphanum2rowcol <- function(alphanum) {
    alpha <- str_sub(alphanum, end = 1)
    row <- match(alpha, toupper(letters))
    col <- as.numeric(str_sub(alphanum, start = 2))
    return(c(row, col))
  }
  
  #loop through the measurement dataframes
  for (measurementName in names(tecanObject)[names(tecanObject) != "settings"]) {
    measurement <- tecanObject[[measurementName]]
    #expand the dataframe for a strain and treatment column
    measurement <- cbind(well = measurement$well, 
                         strains = NA, 
                         treatment = NA,
                         measurement[2:ncol(measurement)])
    #apply the dataframes in definitionObject to the measurement dataframe
    for (i in 1:nrow(measurement)) {
      row <- measurement[i,]
      defRow <- alphanum2rowcol(row$well)[1]
      defCol <- alphanum2rowcol(row$well)[2]
      
      for (dfName in names(definitionObject)) {
        measurement[i, dfName] <- definitionObject[[dfName]][defRow, defCol]
      }
    }
    tecanObject[[measurementName]] <- measurement
  }
  
  return(tecanObject)
}