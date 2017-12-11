library("pollstR")
library("readr")

slug_list <- list('favorable-ratings','2016-president','2012-president','obama-job-approval','2016-senate','2014-senate'
                  ,'uk-eu-referendum')

chart_list <- list()

chart_list[[1]] <- ""
chart_num = 2

for (i in slug_list){
  charts = pollster_charts(tags = i)
  for (z in 1:length(charts$content$items)) {
    chart_list[chart_num] <- charts$content$items[[z]]$title
    chart_num = chart_num + 1
  }
}

## need to manually add charts for 'untagged' items: 2018 house race, trump job approval

chart_list[chart_num] <- "2018 National House Race"
chart_list[chart_num + 1] <- "Trump Job Approval"


shinyUI(fluidPage(

  titlePanel("Polling Dashboard"),
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