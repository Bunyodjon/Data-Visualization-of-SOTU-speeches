library(shiny)
library(dplyr)
library(ggplot2)
library(plotly)
library(DT)
library(shinyalert)
library(wordcloud)
library(RColorBrewer)
# read data files which is made using text_mining prep code attached 
text_data6 <- read.csv("Data/text_data6.csv")
text_data7 <- read.csv("Data/text_data7.csv")
name_data <- read.csv("Data/name_data.csv")
tdm <- readRDS("Data/tdm.RData")  # large TDM file 

# create a list of available speeches
list_names <- unique(name_data$names)

ui <- fluidPage(
  navbarPage("State of the Union Address", windowTitle = "Text",
             # this part is for the comparison worldcloud
             tabPanel("Wordcloud",
                      fluidRow(   # fluidrow allows to have nonstandard layout
                        column(4, 
                               # create sidebar
                               sidebarPanel(width = 12,    
                                            # two drop down menues for selecting speeches
                                            selectInput(inputId = "name_year1",
                                                        label = "Select First Speech",
                                                        choices = list_names,
                                                        selected = "Obama 2009"),
                                            
                                            selectInput(inputId = "name_year2",
                                                        label = "Select Second Speech",
                                                        choices = list_names,
                                                        selected = "Trump 2017"),
                                            # slidebar for max freq words
                                            sliderInput(inputId = "max_freq", 
                                                        label = "Maximum Words", 
                                                        min = 1, max = 100, value = 50),
                                            #shiny alers allows to get extra INFO about the plot
                                            useShinyalert(),
                                            actionButton("info", "Info")
                                            
                               )),
                        column(8, align="center", offset =0,
                               plotOutput("plot0", height = "500px", width = "500px") # output for the plot
                        )
                      )
             ),
             # this part creates tab for the spider plot (Emotions ) 
             tabPanel("Emotions", 
                      fluidRow(
                        sidebarPanel(width =4, 
                                     h4("Ten Emotions Associated with Presidential Speeches"),
                                     fluidRow( # inside the sidebar create three columns with three president names side by side
                                       column(1,
                                              checkboxInput(inputId = "speech1",
                                                            label = "Donald Trump",
                                                            value = TRUE),
                                              # checkbox is true, the rest of the speech list will show up 
                                              conditionalPanel(condition = "input.speech1==true", 
                                                               checkboxGroupInput(inputId = "year1",
                                                                                  label = "",
                                                                                  choices = c(2017),
                                                                                  selected = 2017)),
                                              offset = 0),
                                       column(1,
                                              checkboxInput(inputId = "speech2",
                                                            label = "Barack Obama",
                                                            value = FALSE),
                                              # checkbox is true, the rest of the speech list will show up 
                                              conditionalPanel("input.speech2==true", 
                                                               checkboxGroupInput(inputId = "year2",
                                                                                  label = "",
                                                                                  choices = c(2009:2016)
                                                               )), 
                                              offset = 2),
                                       column(1, 
                                              checkboxInput(inputId = "speech3",
                                                            label = "George Bush",
                                                            value = FALSE),
                                              # checkbox is true, the rest of the speech list will show up 
                                              conditionalPanel("input.speech3==true", 
                                                               checkboxGroupInput(inputId = "year3",
                                                                                  label = "",
                                                                                  choices = c(2001:2008)
                                                               )),
                                              offset = 2)),
                                     useShinyalert(),
                                     actionButton("info1", "Info")),
                        column(8,  # output part uses plotly for a better looking spider plot
                               plotlyOutput("plot")
                        )
                      )
             ),
             # this part creates a sentiment score plot
             tabPanel("Sentiment Score",
                      sidebarLayout(
                        sidebarPanel(
                          # create two drop down menus for selecting speeches
                          selectInput(inputId = "name_time1",
                                      label = "Select First Speech",
                                      choices = list_names,
                                      selected = "Obama 2009"),
                          
                          selectInput(inputId = "name_time2",
                                      label = "Select Second Speech",
                                      choices = list_names,
                                      selected = "Trump 2017")
                          
                        ),
                        mainPanel(
                          plotlyOutput("plot2")  # output place for the plot
                        )
                      )
             ), 
             # this part creates About page
             tabPanel("About",
                      includeMarkdown("Data/include.md"))
  )
)
# server side of the app
server <- function(input, output) {
  # this part of the server is for wordcloud
  # reactive tdm for the worldcloud 
  tdm1 <- reactive({
    list <- c(name_data$number[name_data$names==input$name_year1], name_data$number[name_data$names==input$name_year2])
    tdm1 <- tdm[, list]
  })
  
  # creating a plot
  output$plot0 <- renderPlot({
    par(mar = rep(0, 4))
    comparison.cloud(tdm1(), colors = c("indianred3","lightsteelblue3"), random.order = FALSE,
                     title.size=4, max.words=input$max_freq)}, height = 500, width = 550)
  # creates pop-up info box
  observeEvent(input$info, {
    # Show a modal when the button is pressed
    shinyalert("Comparison Cloud", "A comparison cloud compares the relative frequency with which a term was used in two or more documents. It does not simply merge two word clouds. Rather, it plots the difference between the word usage in the documents.", 
               type = "info", showConfirmButton=TRUE,
               confirmButtonText="Got it!", confirmButtonCol="#31A354")
  })  
  
  # this part of the server is for spider plot
  # create reactive data based on inputs. if the same president selected, find average. 
  spider_data <- reactive({
    text_data6 %>% 
      filter(year %in% c(input$year1, input$year2, input$year3)) %>%
      group_by_("president_name", "sentiment") %>%
      mutate(count=mean(count, na.rm = T))
      
  })
  # creates pop-up info box
  observeEvent(input$info1, {
    # Show a modal when the button is pressed
    shinyalert("Polar Plot", "Polar plot uses NRC lexicon's ten emotions and shows how many words under each emotional category. Nuetral words are automatically removed before counts. If you select two speeches from the same president, it shows the average number of counts under each category from multiple years by the same president.", 
               type = "info", showConfirmButton=TRUE,
               confirmButtonText="Got it!", confirmButtonCol="#31A354")
  })  
  # this part creates spider plot using reactive data set. it has fixed colors 
  output$plot <- renderPlotly({
    plot_ly(type = 'scatterpolar', fill = 'toself', alpha =0.7, colors=c("#377eb8", "#e41a1c", "#4daf4a")) %>%
      add_trace(data = spider_data(), r = ~count, theta = ~sentiment, color = ~president_name) %>%
      layout(
        polar = list(
          radialaxis = list(
            visible = T,
            range = c(0, max(text_data7$count)))))
  })
  
  # this part of the server is for sentiment plot
  sen_line_data <- reactive({
    text_data7 %>% 
      filter(UniqueID %in% c(input$name_time1, input$name_time2)) %>% 
      mutate(rmean10=stats::filter(sentiment, rep(1/10, 10), side=2))
  })
  # this sets the font color and size 
  f <- list(
    family = "Courier New, monospace",
    size = 20,
    color = "#7f7f7f"
  )
  # this sets x-axis label
  x <- list(
    title = "Sentence Number",
    titlefont = f
  )
  # this sets y-axis label
  y <- list(
    title = "Sentiment Score",
    titlefont = f)
  # this part creates scatter plot with a trend line
  output$plot2 <- renderPlotly({
    plot_ly(data=sen_line_data(), x = ~linenumber, y = ~sentiment, color = ~ UniqueID, 
             type = 'scatter', alpha=0.4, mode = 'markers', colors=c( "#4daf4a", "#377eb8", "#e41a1c"),
            name=~UniqueID, showlegend=FALSE) %>%
      # add trend line 
      add_lines(data = sen_line_data(), x=~linenumber, y=~rmean10, alpha=1, showlegend=TRUE, 
                line=list(width=3)) %>%  
      layout(xaxis=x, yaxis=y) # changes label formats
  })
  
}

# Create Shiny app object
shinyApp(ui = ui, server = server)