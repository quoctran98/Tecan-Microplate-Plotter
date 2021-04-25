library(shiny)
library(rhandsontable)
library(openxlsx)
library(stringr)
library(ggplot2)
library(ggpubr)
library(viridis)
library(shinyjs) 

source("scripts/parseTecan.R")
source("scripts/applyDefinitions.R")
source("scripts/normalizeData.R")
source("scripts/plotNormData.R")

shinyServer(function(input, output, session) {
    
    #i wish i could make this dynamic (with multiple treatments)
    hotDefinitions <- list(
        strains = data.frame(matrix("", nrow = 8, ncol = 12)),
        treatment = data.frame(matrix(0, nrow = 8, ncol = 12))
    )
    
    #show the selected handsontable with ui rendering
    observeEvent(input$hotDefinitionSelection, {
        tableID <- paste("hotDefinition", input$hotDefinitionSelection, sep = "")
        uiText <- c("verticalLayout(h2(\"Define ", input$hotDefinitionSelection, " in 96-Well Plate\"),")
        uiText <- c(uiText,"rHandsontableOutput(\"", tableID,"\"))")
        
        output$hotDefinitionTable <- renderUI({
            eval(parse(text = paste(uiText, collapse = "")))
        })
    })
    
    #populate the handsontable with the dataframe
    output$hotDefinitionStrains <- renderRHandsontable({
        rhandsontable(hotDefinitions$strains,
                      colHeaders = 1:12,
                      rowHeaders = toupper(letters[1:8])) %>%
            hot_table(highlightCol = TRUE, highlightRow = TRUE)
    })
    output$hotDefinitionTreatment <- renderRHandsontable({
        rhandsontable(hotDefinitions$treatment,
                      colHeaders = 1:12,
                      rowHeaders = toupper(letters[1:8]) )%>%
            hot_table(highlightCol = TRUE, highlightRow = TRUE)
    })

    #save the handsontable to the dataframe and populates the strain selection choices
    observeEvent(input$hotDefinitionStrains$changes$changes, {
        hotDefinitions$strains <<- hot_to_r(input$hotDefinitionStrains)
        allStrains <- unique(unlist(hotDefinitions$strains))
        exptStrains <- allStrains[!allStrains %in% c(input$plotBackground, input$plotBlank)]
        updateSelectInput(session, "plotStrains", choices = exptStrains, selected = exptStrains)
        updateSelectInput(session, "plotBackground", choices = allStrains)
        updateSelectInput(session, "plotBlank", choices = allStrains)
    })
    observeEvent(input$hotDefinitionTreatment$changes$changes, {
        hotDefinitions$treatment <<- hot_to_r(input$hotDefinitionTreatment)
    })
    
    #download the defintion dataframes
    output$hotDefinitionSave <- downloadHandler(
        filename = "wellDefinitions.xlsx",
        content = function (file) {
            return(write.xlsx(hotDefinitions, file))}
    )
    
    #upload a definition data.frame
    observeEvent(input$hotDefinitionUpload, {
        hotDefinitions$strains <<- read.xlsx(input$hotDefinitionUpload$datapath, sheet = 1)
        hotDefinitions$treatment <<- read.xlsx(input$hotDefinitionUpload$datapath, sheet = 2)
        
        #force update of definition table and strain selections
        output$hotDefinitionStrains <- renderRHandsontable({
            rhandsontable(hotDefinitions$strains,
                          colHeaders = 1:12,
                          rowHeaders = toupper(letters[1:8]))
        })
        output$hotDefinitionTreatment <- renderRHandsontable({
            rhandsontable(hotDefinitions$treatment,
                          colHeaders = 1:12,
                          rowHeaders = toupper(letters[1:8]))
        })
        allStrains <- unique(unlist(hotDefinitions$strains))
        exptStrains <- allStrains[!allStrains %in% c(input$plotBackground, input$plotBlank)]
        updateSelectInput(session, "plotStrains", choices = exptStrains, selected = exptStrains)
        updateSelectInput(session, "plotBackground", choices = allStrains)
        updateSelectInput(session, "plotBlank", choices = allStrains)
    })
    
    #populate the od and fluor selections when a tecan file is uploaded
    observeEvent(input$rawTecanUpload, {
        if (!is.null(input$rawTecanUpload)) {
            shinyjs::show("plotRender")
            shinyjs::show("normDataSave")
        }
        measurements <- names(parseTecan(input$rawTecanUpload$datapath))
        measurements <- measurements[measurements != "settings"]
        updateSelectInput(session, "plotOD", choices = measurements)
        updateSelectInput(session, "plotFluor", choices = measurements)
    })
    
    #sets the plot placeholder image
    output$finalPlot <- renderImage({
        list(src = "images/plot.png")
    })
    
    #download the normalized dataframe
    output$normDataSave <- downloadHandler(
        filename = "normalizedData.csv",
        content = function (file) {
            defTecan <- applyDefinitions(parseTecan(input$rawTecanUpload$datapath), hotDefinitions)
            od <- input$plotOD
            fluoresence <- input$plotFluor
            normDF <- normalizeData(defTecan[[fluoresence]], defTecan[[od]], input$plotBackground, input$plotBlank)
            return(write.csv(normDF, file))
    })
    
    #update the strains to plot
    observeEvent(input$plotBackground, {
        allStrains <- unique(unlist(hotDefinitions$strains))
        exptStrains <- allStrains[!allStrains %in% c(input$plotBackground, input$plotBlank)]
        updateSelectInput(session, "plotStrains", choices = exptStrains, selected = exptStrains)
    })
    observeEvent(input$plotBlank, {
        allStrains <- unique(unlist(hotDefinitions$strains))
        exptStrains <- allStrains[!allStrains %in% c(input$plotBackground, input$plotBlank)]
        updateSelectInput(session, "plotStrains", choices = exptStrains, selected = exptStrains)
    })
    
    #update y axix label
    observeEvent(input$plotFluor, {
        updateTextInput(session, "plotYlab", value = input$plotFluor)
    })
    
    #renders the plot when the button is pressed (also half reactive?)
    observeEvent(input$plotRender, {
        output$finalPlot <- renderPlot({
            defTecan <- applyDefinitions(parseTecan(input$rawTecanUpload$datapath), hotDefinitions)
            od <- input$plotOD
            fluoresence <- input$plotFluor
            
            normData <- normalizeData(defTecan[[fluoresence]], defTecan[[od]], input$plotBackground, input$plotBlank)
            plotNormData(normData,
                         plotOptions = list(
                             timeSeries = F,
                             strains = input$plotStrains,
                             xlab = input$plotXlab,
                             ylab = input$plotYlab,
                             scale = input$plotScale
                         ))
        })
    })
})



