library(shiny)
library(ggplot2)
library(magrittr)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    filedata <-  reactive ({
        infile <- input$datafile
        if (is.null(infile)) {
          # User has not uploaded a file yet
          return(NULL)
        }
        read.csv(infile$datapath,na.strings = c("NA","."))
    })
    myData <- reactive({
        df=filedata()
        if (is.null(df)) return(NULL)
        df
    })
    plotObject <- reactive ({
        plotdata <- myData
        #plotdata$start_date <- as.Date(plotdata$start_date)

        if(!is.null(plotdata)) {
            p <-  ggplot(plotdata(), aes("start_date","value")) + 
            geom_point(aes(size="observations", colour="choice")) +
            geom_smooth(aes(weight="observations", colour="choice"), size=3, level=.9, alpha=.35, span=input$trendline_sen_sel) +
            scale_size(guide=FALSE) +
            scale_color_manual(values = c("Clinton" = "#00008B", 
                                      "Trump" = "#8B0000", 
                                      "Other/Undecided" = "#708090")) 
            print(p)
        }

    })
    output$plot <- renderPlot ({
        plotObject()
        })
    output$resultstable <- renderDataTable ({
        myData()
        })


 #   
#    output$vote_plot <- renderPlot({
#
#        plot_data = myData
#        
#        vote_plot=ggplot(plot_data, aes(start_date,value)) + 
#        geom_point(aes(size=observations, colour=choice)) +
#        geom_smooth(aes(weight=observations, colour=choice), size=3, level=.9, alpha=.35, span=input$trendline_sen_sel) +
#        scale_size(guide=FALSE) +
#        scale_color_manual(values = c("Clinton" = "#00008B", 
#                                      "Trump" = "#8B0000", 
#                                      "Other/Undecided" = "#708090")) +
#        #scale_colour_brewer("Legend",palette = "Paired") +
#        theme(panel.background =  element_rect(fill = NA, colour = "black", size = 0.25),
#            panel.border =      element_blank(),
#            panel.grid.major =  element_line(colour = "black", size = 0.05),
#            panel.grid.minor =  element_line(colour = "black", size = 0.05),
#            plot.title=element_text(size=18, family="Helvetica Neue Light"),
#            axis.title.x=element_text(size=14, family="Helvetica Neue Light"),
#            axis.text.x=element_text(colour="black", size=14, family="Helvetica Neue Light"),
#            axis.title.y=element_text(size=14, family="Helvetica Neue Light"),
#            axis.text.y=element_text(colour="black",size=14, family="Helvetica Neue Light"),
#            strip.text.x = element_text(size = 14,family="Helvetica Neue Light"),
#            strip.text.y = element_text(size = 14,family="Helvetica Neue Light"),
#            legend.title = element_text(size=14, family="Helvetica",face="bold"),
#            legend.text = element_text(size=14, family="Helvetica Neue Light"),
#            strip.background = element_rect(colour = "grey", fill = "white")) +
#        xlab("Date") + ylab("%") + ggtitle("2016 Presidential Vote: Clinton vs. Trump")
#        print(vote_plot)
  #})
})
