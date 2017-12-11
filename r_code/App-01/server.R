library(shiny)
library(ggplot2)
library(magrittr)
library(reshape2)
library("pollstR")
library("readr")

shinyServer(function(input, output) {

    output$value <- renderPrint({ input$text })

    filedata <-  reactive ({
        infile <- input$datafile
        chart <- input$chart
        if (is.null(infile)) {
          if (chart =="") {
            # User has not uploaded a file yet or select chart
            return(NULL)
          }
          else {
            ## load pollster data
            
            slug_list <- list('favorable-ratings','2016-president','2012-president','obama-job-approval','2016-senate','2014-senate'
                         ,'uk-eu-referendum')
            
            max_page = 0 
            chart_num = 1
            
            for (i in slug_list){
              charts = pollster_charts(tags = i)
              for (z in 1:length(charts$content$items)) {
                slug_list[[charts$content$items[[z]]$title]] <- charts$content$items[[z]]$slug
              }
            }
            
            slug_list["Trump Job Approval"] <- "trump-job-approval"
            slug_list["2018 National House Race"] <- "2018-national-house-race"
            
            chart = trimws(chart)
            slug = slug_list[[chart]]
            polls <- pollster_charts_polls(slug)
            initial_dataset <- data.frame(do.call("c",list(polls$content)))
            
            metadata <- initial_dataset[c(4:ncol(initial_dataset))] 
            
            drop_columns <- colnames(test)
            drop_columns <- drop_columns[drop_columns != "poll_slug"]
            myvars <- names(initial_dataset) %in% drop_columns
            reshape_data <- initial_dataset[!myvars]
            
            varying_cols <- colnames(reshape_data)
            varying_cols <- varying_cols[varying_cols != "poll_slug"]
            
            long <- reshape(reshape_data, 
                            varying = varying_cols, 
                            v.names = "value",
                            timevar = "choice", 
                            times = varying_cols,
                            direction = "long")
            
            df <- merge(long,metadata,by="poll_slug")
            
            names(df)[names(df) == 'survey_house'] <- 'pollster'
            names(df)[names(df) == 'mode'] <- 'method'
            names(df)[names(df) == 'sample_subpopulation'] <- 'subpopulation'
            df
          }
        }  
        else {
          read.csv(infile$datapath,na.strings = c("NA","."))
        }
    })

    plotObject <- reactive ({
       
        if(!is.null(filedata())) {
            
            df <- filedata()
            df$start_date <- as.Date(df$start_date, format="%Y-%m-%d")
            plot <-  ggplot(df, aes(x=start_date,y=value)) + 
            geom_point(aes(size=observations, colour=choice)) +
            geom_smooth(aes(weight=observations, colour=choice), size=3, level=.9, alpha=.35, span=input$trendline_sen_sel) +
            scale_size(guide=FALSE) +
            #scale_color_manual(values = c("Clinton" = "#00008B", 
            #                         "Trump" = "#8B0000", 
            #                          "Other/Undecided" = "#708090")) +
            ggtitle(input$text) + theme(plot.title = element_text(size = 24, face = "bold",hjust = 0.5))
            print(plot)
        }
    })        
    
    output$plot <- renderPlot ({
        plotObject()
    })
    output$resultstable <- renderDataTable ({
        if(!is.null(filedata())) {
		  tabledata <- filedata()[,c("pollster","start_date","method","subpopulation","choice","value")]
		  tabledata <- dcast(tabledata,pollster + start_date + method + subpopulation ~ choice,value.var="value",fun.aggregate = sum)	
          print(tabledata)
        }

    })
    
    output$downloadPlot <- downloadHandler(
    	filename = function() { paste('results.png', sep='') },
    	content = function(filename) {
        	ggsave(filename, plot = plotInput(), device = "png")
    	}
    )	
    	
})






