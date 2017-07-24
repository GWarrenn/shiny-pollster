library(shiny)
library(ggplot2)
library(magrittr)
library(reshape2)

shinyServer(function(input, output) {

    output$value <- renderPrint({ input$text })

    filedata <-  reactive ({
        infile <- input$datafile
        if (is.null(infile)) {
          # User has not uploaded a file yet
          return(NULL)
        }
        read.csv(infile$datapath,na.strings = c("NA","."))
    })

    plotObject <- reactive ({
       
        if(!is.null(filedata())) {
            
            df <- filedata()
            df$start_date <- as.Date(df$start_date, format="%Y-%m-%d")
            plot <-  ggplot(df, aes(x=start_date,y=value)) + 
            geom_point(aes(size=observations, colour=choice)) +
            geom_smooth(aes(weight=observations, colour=choice), size=3, level=.9, alpha=.35, span=input$trendline_sen_sel) +
            scale_size(guide=FALSE) +
            scale_color_manual(values = c("Clinton" = "#00008B", 
                                      "Trump" = "#8B0000", 
                                      "Other/Undecided" = "#708090")) +
            ggtitle(input$text) + theme(plot.title = element_text(size = 24, face = "bold",hjust = 0.5))
            print(plot)
        }
    })        
    
    output$plot <- renderPlot ({
        plotObject()
    })
    output$resultstable <- renderDataTable ({
		tabledata <- filedata()[,c("id","pollster","start_date","method","subpopulation","choice","value")]
		tabledata <- dcast(tabledata,id + pollster + start_date + method + subpopulation ~ choice,value.var="value",fun.aggregate = sum)	
        print(tabledata)

    })
    output$downloadPlot <- downloadHandler(
    	filename = function() { paste(plot, '.png', sep='') },
    	content = function(file) {
        	ggsave(file, plot = plotObject(), device = "png")
    }
)
})






