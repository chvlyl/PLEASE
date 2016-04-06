
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
source('load.R')

shinyUI(navbarPage(

  # Application title
  title = "PLEASE Data",
  
  
  ##############################################
  ##############################################
  #### Tab: taxa
  tabPanel("Taxa",
    fluidRow(
    column(2,
           selectInput("selectSamples", "Samples", 
                       choices = c("COMBO" ,"PLEASE-T1" ,
                                   "PLEASE-T4"), selected = "COMBO")),
    
    conditionalPanel(condition = "input.selectSamples != 'COMBO'",
                     column(2,
                            selectInput("selectTreatment", "Treatment", 
                                        choices = c("All", "EEN" ,"PEN","antiTNF"), 
                                        selected = "All"))
    ),
    
    conditionalPanel(condition = "input.selectSamples != 'COMBO'",
                     column(2,
                            selectInput("selectResponse", "Response", 
                                        choices = c("All", "Response" ,"Non.Response" ), 
                                        selected = "All"))
    ),
    


    column(5,
           sliderInput('maxCor', 'Filter taxa by max correlation', 
                       min=0, max=1, value=min(0, 1), 
                       step=0.05, round=0.01)
    )
  ),
  
  #########
  plotOutput("heatmapTaxa"),
  

  #########
  fluidRow(
    column(3,
         selectInput("selectTaxa", "Taxa", 
                     choices = colnames(taxa.data)))
  ),
  plotOutput("corplotTaxa",height = "800px")
  
  #   #########
  #   conditionalPanel(condition = "input.selectSamples != 'COMBO'",
  #                    plotOutput("fcpplot",height = "800px")
  #   )
  ), 


##############################################
##############################################
#### Tab: metabolite
tabPanel("Metabolites",
         fluidRow(
           column(2,
                  selectInput("selectSamplesMetab", "Samples", 
                              choices = c("COMBO" ,"PLEASE-T1" ,
                                          "PLEASE-T4"), selected = "COMBO")),
           
           conditionalPanel(condition = "input.selectSamplesMetab != 'COMBO'",
                            column(2,
                                   selectInput("selectTreatmentMetab", "Treatment", 
                                               choices = c("All","EEN" ,"PEN","antiTNF"), 
                                               selected = "All"))
           ),
           
           conditionalPanel(condition = "input.selectSamplesMetab != 'COMBO'",
                            column(2,
                                   selectInput("selectResponseMetab", "Response", 
                                               choices = c("All","Response" ,"Non.Response" ), 
                                               selected = "All"))
           ),
           
           
           
           column(5,
                  sliderInput('maxCorMetab', 'Filter metabolites by max correlation', 
                              min=0, max=1, value=min(0, 1), 
                              step=0.05, round=0.01)
           )
         ),
         
         #########
         plotOutput("heatmapMetab",width = "200%"),
         
         
         #########
         fluidRow(
           column(3,
                  selectInput("selectMetab", "Metablite", 
                              choices = colnames(kmdata.nor))
         )),
         plotOutput("corplotMetab",height = "800px")
)

))
