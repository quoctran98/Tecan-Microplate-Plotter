plotNormData <- function (normDF,
                          plotOptions = list(
                            timeSeries = F,
                            strains = NA,
                            xlab = "treatment",
                            ylab = "fluorescence",
                            scale = "identity"
                          )) {
  
  normDF <- normDF[normDF$strains %in% plotOptions$strains,]
  
  if (plotOptions$timeSeries) {
    
  } else {
    
    #gives mean of all the mesurements instead of plotting as time series
    normDF[,"meanNormFoldFluor"] <- apply(normDF[,4:ncol(normDF)], 1, mean)
    
    p <- ggplot(normDF) +
      geom_point(aes(x = treatment, y = meanNormFoldFluor, color = strains), size = 2) +
      geom_smooth(aes(x = treatment, y = meanNormFoldFluor, color = strains), size = 2, se = F, fullrange = T) +
      xlab(plotOptions$xlab) +
      ylab(plotOptions$ylab) +
      scale_colour_manual(values = viridis(length(unique(normDF$strains)))) +
      scale_x_continuous(trans = plotOptions$scale) + #expand confuses me -- this cuts off the last tick i think
      theme_pubr() +
      theme(axis.text = element_text(size = 10),
            axis.title = element_text(size = 20),
            legend.text = element_text(size = 20),
            legend.title = element_text(size = 20))
    
    return(p)
  }
}