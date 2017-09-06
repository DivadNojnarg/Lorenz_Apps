library(shiny)
library(shinydashboard)
library(shinythemes)
library(plotly)
library(shinyjs)
library(dygraphs)
library(shinyBS)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

  useShinyjs(),
  
  # Application theme
  #theme = shinytheme("cerulean"),
  theme = "bootswatch-journal.css",
  
  # Application title
  titlePanel(""),
  
  #navbarPage layout
  navbarPage(title = "Web-based application of the Lorenz model", 
             
    # first panel of the page         
    tabPanel("Change parameters", 
    
      # Show a plot of the generated distribution
      mainPanel(id="mainPanel1",
        tabsetPanel(
          tabPanel(id="tabPanel1", "About the model",
                   tags$div(class="panel panel-info",
                            tags$div(class="panel-heading",
                                     h3(class="panel-title","Equations")
                            ),
                            tags$div(class="panel-body",
                                     h4("Model Introduction"),
                                     p("The Lotka-Volterra predator-prey model describes the 
                                       population dynamics of a pair of species interacting as 
                                       predator and prey. The basic model assumes that the prey 
                                       population grows", 
                                       em(a("exponentially", href = "http://gauravsk.shinyapps.io/single_pop")), 
                                       "(i.e. without a carrying capacity) in the absence of the 
                                       predator; in other words, predators are the only control on 
                                       prey population in the basic model. Predator population 
                                       growth rate is a function of prey availability, 
                                       the 'conversion efficiency' of prey into predator 
                                       (i.e. how many individuals of the prey are needed to make 
                                       an additional member of the predator population), and some 
                                       intrinsic death rate."),
                                     
                                     h4("These are the equations behind the L-V predator prey model"),
                                     p(withMathJax("$$ \\frac{dN}{dt} = rN - aNP $$")), # only need to call once
                                     p("$$ \\frac{dP}{dt} = baNP - dP $$"),
                                     p("Where \\(r\\) is the per capita growth rate of the prey, 
                                                   \\(a\\) is the prey conversion efficiency, \\(b\\) is 
                                                   predation efficiency, and \\(d\\) is predator death rate."),
                                     br(),
                                     p("The equilibrium isoclines can be computed with these equations:"),
                                     p("$$ \\frac{dN}{dt} = 0 \\text{  when  } P = \\frac{r}{a} $$"),
                                     p("$$ \\frac{dP}{dt} = 0 \\text{  when  } N = \\frac{d}{ab}$$"),
                                     br(),
                                     br(),
                                     h4("Model modifications:"),
                                     p("A carrying capacity can be introduced onto the prey:"),
                                     p("$$ \\frac{dN}{dt} = rN - aNP - 
                                                   \\left(1-\\frac{N}{K} \\right) $$"),
                                     p("This changes the equilibrium isocline for the prey:"),
                                     p("$$ \\frac{dN}{dt}=0 \\text{  when  } 
                                                   P = \\frac{r}{a}-\\frac{rP}{aK} $$"),
                                     p("$$\\left\\{
                                       \\begin{align}
                                       y & = x - y + z,\\\\
                                       x & = y,\\\\
                                       z & = y
                                       \\end{align}
                                       \\right.$$")
                            )
                   )
          ),
          tabPanel("Main Results",
            #plotOutput("plot2", height = 400)
            conditionalPanel("go",
                             tags$div(class="panel panel-info",
                                      tags$div(class="panel-heading",
                                               h3(class="panel-title","Graph")
                                      ),
                                      tags$div(class="panel-body",
                                               plotlyOutput("plot2", width = "auto", height = "auto")
                                      )
                             )
            ),
            tags$div(class="panel panel-info",
                     tags$div(class="panel-heading",
                              h3(class="panel-title","Table")
                     ),
                     tags$div(class="panel-body",
                              dataTableOutput("table")
                     )
            ),
            actionButton("hideshow", "Hide/Show Graph", class="btn btn-info"),
            actionButton("hideshow2", "Hide/Show Table", class="btn btn-info")
          ),
          tabPanel("Secondary Results",
            conditionalPanel("go",
                             tags$div(class="panel panel-info",
                                      tags$div(class="panel-heading",
                                               h3(class="panel-title","Graph")
                                      ),
                                      tags$div(class="panel-body",
                                               plotlyOutput("plot1")
                                      )
                             )
                   
            )
          ),
          tabPanel(id="tabPanelTest" ,"Test",
                   dashboardPage(skin = "black",
                     dashboardHeader(disable = TRUE),
                     dashboardSidebar(disable = TRUE),
                     dashboardBody(
                       tags$div(class ="progress progress-striped active",
                                tags$div(class ="progress-bar", style = "width : 45%")
                       ),
                       tags$div(class="progress-bar", 
                                role="progressbar", 
                                #aria-valuenow="60", 
                                #aria-valuemin="0", 
                                #aria-valuemax="100",
                                style="width: 60%;"
                       ),
                       tags$div(class="alert alert-dismissible alert-warning",
                               tags$button(type="button", class="close", 
                                          type="alert"),
                               h4("Warning!"),
                               p("Test")
                       ),
                       tags$i(class="fa fa-cloud"), 
                       tags$i(class="fa fa-apple fa-5x"),
                       tags$i(class="fa fa-spinner fa-pulse fa-3x fa-fw"),
                       tags$i(class="fa fa-cog fa-spin fa-3x fa-fw"),
                       
                       fluidRow(
                         box(title = "Box title", "Box content"),
                         box(status = "warning", "Box content")
                       ),
                       
                       fluidRow(
                         box(
                           title = "Title 1", width = 4, solidHeader = TRUE, status = "primary",
                           "Box content", collapsible = TRUE
                         ),
                         box(
                           title = "Title 2", width = 4, solidHeader = TRUE,
                           "Box content"
                         ),
                         box(
                           title = "Title 1", width = 4, solidHeader = TRUE, status = "warning",
                           "Box content"
                         )
                       ),
                       
                       fluidRow(
                         box(
                           width = 4, background = "black",
                           "A box with a solid black background"
                         ),
                         box(
                           title = "Title 5", width = 4, background = "light-blue",
                           "A box with a solid light-blue background"
                         ),
                         box(
                           title = "Title 6",width = 4, background = "maroon",
                           "A box with a solid maroon background"
                         )
                       ),
                       fluidRow(
                         tabBox(
                           title = "First tabBox",
                           # The id lets us use input$tabset1 on the server to find the current tab
                           id = "tabset1", height = "250px",
                           tabPanel("Tab1", "First tab content"),
                           tabPanel("Tab2", "Tab content 2")
                         ),
                         tabBox(
                           side = "right", height = "250px",
                           selected = "Tab3",
                           tabPanel("Tab1", "Tab content 1"),
                           tabPanel("Tab2", "Tab content 2"),
                           tabPanel("Tab3", "Note that when side=right, the tab order is reversed.")
                         )
                       ),
                       fluidRow(
                         tabBox(
                           # Title can include an icon
                           title = tagList(shiny::icon("gear"), "tabBox status"),
                           tabPanel("Tab1",
                                    "Currently selected tab from first box:",
                                    verbatimTextOutput("tabset1Selected")
                           ),
                           tabPanel("Tab2", "Tab content 2")
                         )
                       )
                     )
                   )
          )             
        )
      ),
      # Sidebar with a slider input for the parameters
      sidebarPanel(id="sidebar1",style = "border: 0px; max-width: 300px; background: transparent;",
        tags$div(class="panel panel-info",
                 tags$div(class="panel-heading",
                          h3(class="panel-title","Parameters")
                 ),
                 tags$div(class="panel-body",
                          inputPanel(style="height: 40vh; overflow-y: auto; max-height: 325px", # vertical scrolling
                            sliderInput("a",
                                        "Value of parameter a:",
                                        min = -10,
                                        max = -1,
                                        value = round(-8/3)),
                            sliderInput("b",
                                        "Value of parameter b:",
                                        min = -20,
                                        max = 10,
                                        value = -10),
                            sliderInput("c",
                                        "Value of parameter c:",
                                        min = 0,
                                        max = 100,
                                        value = 28)
                          )
                 )
        ),
        tags$div(class="panel panel-info",
                 tags$div(class="panel-heading",
                          h3(class="panel-title","Initial conditions")
                 ),
                 tags$div(class="panel-body",
                          inputPanel(style="height: 40vh; overflow-y: auto; max-height: 340px", # vertical scrolling
                            numericInput("X0","Initial value of X0:", 1, min = 0, max = 100),
                            numericInput("Y0","Initial value of Y0:", 1, min = 0, max = 100),
                            numericInput("Z0","Initial value of Z0:", 1, min = 0, max = 100),
                            #numericInput("t0","Initial value of t0:", 0, min = 0, max = NA),
                            numericInput("tmax","Value of tmax:", 100, min = 0, max = NA)
                            #numericInput("dt","Step of integration:", 0.01, min = 0, max = NA)
                          )
                 )
        ),
        tags$div(class="panel panel-info",
                 tags$div(class="panel-heading",
                          h3(class="panel-title","Tools")
                 ),
                 tags$div(class="panel-body",
                          inputPanel(style="height: 15vh; overflow-y: auto;", # vertical scrolling
                            actionButton(inputId="go", label="Update", class="btn btn-success"),
                            bsTooltip("go", "Click here to update graph and table", 
                                      options = list(container = "body")),
                            downloadButton(outputId="downloadData", label="Download Table", 
                                           class="btn btn-success"),
                            bsTooltip("downloadData", "Download Table data", 
                                      options = list(container = "body")),
                            actionButton(inputId="save", label="Save", class="btn btn-success"),
                            bsTooltip("save", "Save the session", 
                                      options = list(container = "body")),
                            actionButton(inputId="load", label="Load", class="btn btn-success"),
                            bsTooltip("load", "Load the saved session", 
                                      options = list(container = "body")),
                            actionButton(inputId="resetAll", label="Reset", class="btn btn-primary"),
                            bsTooltip("reset", "reset to the initial state", 
                                      options = list(container = "body"))
                            #downloadButton(outputId="downloadGraph", label="Download Graph")
                          )
                 )
        )
                          
      )
    ),
    tabPanel("Do other things!","Come back later!"
    ),
    navbarMenu("Test",
      tabPanel("Sub-menu 1"),
      tabPanel("Sub-menu 2"),
      tabPanel("Sub-menu 3")
    )
  )
))