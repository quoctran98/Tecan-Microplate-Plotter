library(shiny)

shinyUI(fluidPage(
    useShinyjs(),

    titlePanel("Quoc's Super Cool Tecan Plot Maker"),

    sidebarLayout(
        sidebarPanel(
            wellPanel(
                h2("1. Upload Raw Tecan File"),
                fileInput("rawTecanUpload", "", accept = c(".xlsx"))
            ),
            wellPanel(
                h2("2. Define Wells"),
                "",
                selectizeInput("hotDefinitionSelection", 
                               "Define Wells",
                               c("Strains", "Treatment"), 
                               options = list(create = F)),
                verticalLayout(
                    HTML("<label class=\"control-label\" for=\"hotDefinitionSave\">Save 96w Def. File</label>"),
                    downloadButton("hotDefinitionSave", "Download"),
                    HTML("<br>")
                ),
                fileInput("hotDefinitionUpload", "Upload 96w Def. File", accept = ".xlsx")
                
            ),
            wellPanel(
                h2("3. Normalize Data"),
                fluidRow(
                    column(6, selectInput("plotOD", "OD Meas.", c(""))),
                    column(6, selectInput("plotFluor", "Fluor. Meas.", c("")))
                ),
                fluidRow(
                    column(6, selectInput("plotBackground", "Background Strain", c(""))),  
                    column(6, selectInput("plotBlank", "Blank Media", c("")))
                ),
                hidden(downloadButton("normDataSave", "Download Normalized Data"))
            ),
            wellPanel(
                h2("4. Plot Options"),
                selectInput("plotStrains", "Choose Strain(s)", c(""), multiple = T),
                selectInput("plotScale", "Chooose X-Axis Scale", choices = c("identity", "log10"), selected = "identity"),
                textInput("plotXlab", "X-Axis Label", value = "treatment"),
                textInput("plotYlab", "Y-Axis Label", value = "fluorescence"),
                
                fluidRow( 
                    column(4, hidden(actionButton("plotRender", "Render Plot"))),
                    #column(8, hidden(downloadButton("plotDataSave", "Download Normalized Data")))
                )
            )
        ),

        mainPanel(
            wellPanel(uiOutput("hotDefinitionTable")),
            wellPanel(h2("Plot Output"),
                      plotOutput("finalPlot", height = "600px")),
            textOutput("test")
        )
    )
))
