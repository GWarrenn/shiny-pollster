library(shiny)
library(ggplot2)
library(magrittr)
library(reshape2)

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
            charts = pollster_charts()
            
            max_charts = length(charts$content$items)
            
            slug_list <- list()
            
            for (i in 1:max_charts){
              slug_list[[charts$content$items[[i]]$title]] <- charts$content$items[[i]]$question$slug
            }
            chart = trimws(chart)
            slug = slug_list[[chart]]
            polls <- pollster_questions_responses_raw(slug)
            df <- data.frame(do.call("c",list(polls$content)))
            names(df)[names(df) == 'pollster_label'] <- 'choice'
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
		tabledata <- filedata()[,c("pollster","start_date","method","subpopulation","choice","value")]
		tabledata <- dcast(tabledata,pollster + start_date + method + subpopulation ~ choice,value.var="value",fun.aggregate = sum)	
        print(tabledata)

    })
    
    output$downloadPlot <- downloadHandler(
    	filename = function() { paste('results.png', sep='') },
    	content = function(filename) {
        	ggsave(filename, plot = plotInput(), device = "png")
    	}
    )	
    	
})






