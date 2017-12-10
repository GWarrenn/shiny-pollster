library("pollstR")

charts = pollster_charts()

max_charts = length(charts$content$items)

chart_list <- list()

chart_list[[1]] <- ""

for (chart in 1:max_charts){
  list_position = chart + 1
  chart_list[[list_position]] <- charts$content$items[[chart]]$title
}

shinyUI(fluidPage(

  titlePanel("Data Visualizer"),
   sidebarLayout(position = "left",
    sidebarPanel(

      fileInput("datafile", "Upload the file"), 
           uiOutput("ycol"),
           uiOutput("xcol"),
      textInput("text", label = h4("Enter graph title"), value = ""), 

      selectizeInput("chart", "Or select from list:", 
                    choices=chart_list),
        hr(),
      
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