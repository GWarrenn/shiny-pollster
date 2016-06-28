
shinyUI(fluidPage(

  titlePanel("Data Visualizer"),
   sidebarLayout(position = "left",
    sidebarPanel(

      fileInput("datafile", "Upload the file"), 
           uiOutput("ycol"),
           uiOutput("xcol"),
      textInput("text", label = h4("Enter graph title"), value = ""), 

      checkboxInput(inputId = 'header', 
                    label = 'Header', 
                    value = TRUE),

      radioButtons(inputId = 'sep', 
                   label = 'Separator', 
                   choices = c(Comma=',',Semicolon=';',Tab='\t', Space=''), 
                   selected = ','),
       sliderInput("trendline_sen_sel", 
                label = (h5("Select trend line smoothing")), 
                min = 0.05, max = 1, value = .50, step = .05),

      downloadButton('downloadPlot', 'Download Plot')

    ),  
    mainPanel(
      plotOutput("plot", height=800, width=1000),
      dataTableOutput("resultstable")
    ) #MainPanel
  ) #SidebarLayout
) #Fluidpage
) #ShinyUI