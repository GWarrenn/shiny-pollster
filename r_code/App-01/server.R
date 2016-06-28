library(shiny)
library(ggplot2)
library(magrittr)


#plot_data <- read.csv("vote_data.csv",na.strings = c("NA","."))

#plot_data$start_date <- as.Date(plot_data$start_date, "%Y-%m-%d")

# Define server logic required to draw a histogram
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
       
        if(!is.null(data())) {
            df <- data()
            df$start_date <- as.Date(df$start_date, format="%Y-%m-%d")
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

        ## Code for hardcoded read.csv option. Not optimal. The kids are all raving about dynamic visualzations nowadays...
#        vote_plot=ggplot(plot_data, aes(start_date,value)) + 
#        geom_point(aes(size=observations, colour=choice)) +
#        geom_smooth(aes(weight=observations, colour=choice), size=3, level=.9, alpha=.35, span=input$trendline_sen_sel) +
#        scale_size(guide=FALSE) +
#        scale_color_manual(values = c("Clinton" = "#00008B", 
#                                      "Trump" = "#8B0000", 
#                                      "Other/Undecided" = "#708090")) +
#            theme(panel.background =  element_rect(fill = NA, colour = "black", size = 0.25),
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
#        xlab("Date") + ylab("%") + ggtitle(input$text)
#        print(vote_plot)
    
    output$plot <- renderPlot ({
        plotObject()
    })
    output$resultstable <- renderDataTable ({
        tabledata <- reshape(myData(), ,timevar = "choice", 
            idvar = c("id","pollster","start_date","method",
                "subpopulation"), direction = "wide")
        tabledata <- data.frame(tabledata$start_date,tabledata$pollster,
                                tabledata$subpopulation,tabledata$method,
                                tabledata$value.Clinton,tabledata$value.Trump)
        tabledata

    })
    output$downloadPlot <- downloadHandler(
    filename = function() { paste(plot_data, '.png', sep='') },
    content = function(file) {
        ggsave(file, plot = plotObject(), device = "png")
    }
)
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
#
#    plotObject <- reactive ({
#        plotdata <- myData
#        #plotdata$start_date <- as.Date(plotdata$start_date)
#
#        if(!is.null(plotdata)) {
#            p <-  ggplot(plotdata, aes("start_date","value")) + 
#            geom_point(aes(size="observations", colour="choice")) +
#            geom_smooth(aes(weight="observations", colour="choice"), size=3, level=.9, alpha=.35, span=input$trendline_sen_sel) +
#            scale_size(guide=FALSE) +
#            scale_color_manual(values = c("Clinton" = "#00008B", 
#                                      "Trump" = "#8B0000", 
#                                      "Other/Undecided" = "#708090")) 
#            print(p)
#        }
#
#    })






