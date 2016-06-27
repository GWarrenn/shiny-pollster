
shinyUI(fluidPage(

  titlePanel("2016 Presidential Vote"),
   sidebarLayout(position = "left",
    sidebarPanel(
       sliderInput("trendline_sen_sel", 
                label = (h5("Select trend line smoothing")), 
                min = 0.05, max = 1, value = .50, step = .05,width=5),

      fileInput("datafile", "Upload the file"), 
           uiOutput("ycol"),
           uiOutput("xcol"), 

      checkboxInput(inputId = 'header', 
                    label = 'Header', 
                    value = TRUE),

      radioButtons(inputId = 'sep', 
                   label = 'Separator', 
                   choices = c(Comma=',',Semicolon=';',Tab='\t', Space=''), 
                   selected = ',')
    ),  
    mainPanel(
      h4(plotOutput("plot", height=800, width=1000)),
      h4(dataTableOutput("resultstable"))
    ) #MainPanel
  ) #SidebarLayout
) #Fluidpage
) #ShinyUI