library(shiny)
library(shinydashboard)
library(shinythemes)
library(plotly)
library(shinyjs)
library(dygraphs)
library(shinyBS)
library(visNetwork)
library(shinyAce)

source("helpers.R")

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  useShinyjs(),
  
  # Application theme
  #theme = shinytheme("cerulean"),
  theme = "bootswatch-journal.css",
  
  # Application title
  titlePanel(""),
  
  # CSS and Javascript
  
  tagList(
    
    tags$head(
      
      tags$link(rel="stylesheet", type="text/css",href="style.css"),
      
      tags$script(type="text/javascript", src = "busy.js")
      
    )
    
  ),
  
  
  #navbarPage layout
  navbarPage(title = "Web-based application of the Lorenz model", 
             
             # first panel of the page         
             tabPanel("Change parameters", 
                      
                      # buttons to load, save, reset the solver
                      div(style = "position:absolute;right:1em;", 
                          actionButton(class="fa fa-play fa-5x",inputId="go", label=" Update", class="btn btn-success"),
                          bsTooltip("go", "Click here to update graph and table", 
                                    options = list(container = "body")),
                          downloadButton(outputId="downloadData", label=" Download Table", 
                                         class="btn btn-success"),
                          bsTooltip("downloadData", "Download table", 
                                    options = list(container = "body")),
                          actionButton(class="fa fa-floppy-o fa-5x", inputId="save", label=" Save", class="btn btn-success"),
                          bsTooltip("save", "Save the session", 
                                    options = list(container = "body")),
                          actionButton(class="fa fa-refresh fa-5x", inputId="load", label=" Load", class="btn btn-success"),
                          bsTooltip("load", "Load the saved session", 
                                    options = list(container = "body")),
                          actionButton(class="fa fa-trash fa-5x", inputId="resetAll", label=" Reset", class="btn btn-primary"),
                          bsTooltip("resetAll", "Reset to the initial state", 
                                    options = list(container = "body"))
                          
                      ),
                      tabsetPanel(id="tabsetPanel1",
                                  tabPanel(id="tabPanel1", "About The Model",
                                           dashboardPage(skin = "black",
                                                         dashboardHeader(disable = TRUE),
                                                         dashboardSidebar(disable = TRUE),
                                                         dashboardBody(
                                                           fluidRow(
                                                             box(
                                                               title = "Equations", width = 4, solidHeader = TRUE, 
                                                               status = NULL, collapsible = TRUE,
                                                               p("The Lorenz model was developed in Lorenz, Journal of 
                                                   the Atmospheric Sciences,20: 1963. This finite system is composed of 3 ordinary
                                                   differential equations, which can be obtained from the equations of
                                                   ", 
                                                                 em(a("Saltzman", href = "http://kiamagic.com/wiki/index.php/
                                                        Deterministic_Nonperiodic_Flow_-_The_convection_equations_of_Saltzman")) 
                                                               ),
                                                               
                                                               h4("These are the equations behind the Lorenz model"),
                                                               p(withMathJax("$$\\left\\{
                                                   \\begin{align}
                                                   \\frac{dX}{dt} & = a(Y-X),\\\\
                                                   \\frac{dY}{dt} & = X(c-Z) - Y,\\\\
                                                   \\frac{dZ}{dt} & = XY - bZ,
                                                   \\end{align}
                                                   \\right.$$")),
                                                               
                                                               
                                                               p("where \\(a\\) is the Prandtl number."),
                                                               br()  
                                                             ),
                                                             box(
                                                               title = "Steady State Analysis", width = 4, solidHeader = TRUE, 
                                                               status = NULL, collapsible = TRUE,
                                                               p("At steady-state we know that:"),
                                                               p("$$\\left\\{
                                                   \\begin{align}
                                                    \\frac{dX}{dt} & = 0,\\\\
                                                    \\frac{dY}{dt} & = 0,\\\\
                                                    \\frac{dZ}{dt} & = 0.
                                                    \\end{align}
                                                    \\right.$$"),
                                                               p("This leads to 3 equilibrium points: \\(\\Big(0,0,0\\Big)\\), 
                                                   \\(\\Big(\\sqrt{b(c-1)},\\sqrt{b(c-1)}, c-1\\Big)\\) and 
                                                   \\(\\Big(-\\sqrt{b(c-1)},-\\sqrt{b(c-1)}, c-1\\Big)\\).")
                                                               
                                                             ),
                                                             box(
                                                               title = "Stability of steady states", width = 4, solidHeader = TRUE, 
                                                               status = NULL, collapsible = TRUE,
                                                               p("The jacobian matrix of the system is:"),
                                                               p("$$
                                                   \\begin{align}
                                                    J^{\\ast} = 
                                                    \\begin{pmatrix}
                                                    -a & a & 0 \\\\
                                                    c-Z & -1 & -X \\\\
                                                    Y & X & -b
                                                    \\end{pmatrix}
                                                     \\end{align}$$"),
                                                               p("Besides, to find the characteristic equation, we let:"),
                                                               p("$$
                                                   \\begin{align}
                                                   det(J^{\\ast}- \\lambda I) = 0 \\Longleftrightarrow
                                                   \\begin{vmatrix}
                                                   -a-\\lambda & a & 0 \\\\
                                                   c-Z & -1-\\lambda & -X \\\\
                                                   Y & X & -b-\\lambda
                                                   \\end{vmatrix}
                                                   \\end{align} = 0.$$"),
                                                               p("In \\(\\Big(0,0,0\\Big)\\) this gives:"),
                                                               p("$$
                                                   \\begin{align}
                                                   \\lambda^3 + \\lambda^2(1+a+b) + \\lambda(a+ab+b-ac) + ab(1-c) = 0 
                                                   \\end{align}.$$"),
                                                               p("Applying the Routh-Hurwitz criterion in \\(R^3\\), we see that 
                                                   \\(\\Big(0,0,0\\Big)\\) is stable if and only if \\(c \\leq 1\\).")
                                                             )
                                                           ),
                                                           fluidRow(
                                                             box(
                                                               title = "Bifurcation Analysis", width = 4, solidHeader = TRUE, 
                                                               status = NULL, collapsible = TRUE,
                                                               p("A super-critical pitchfork bifurcation occurs depending on the value of c. 
                                                   If \\(0<c\\leq 1\\), there is only \\(\\Big(0,0,0\\Big)\\) which is stable. 
                                                   If \\(c >1\\), there are 3 equilibrium points as shown in the second box. The two
                                                   symetric points are then stable. Furthermore, a Hopf-bifurcation is expected 
                                                   when \\(c = a\\frac{a+b+3}{a-b-1}\\) and chaotic behavior happens when 
                                                   \\(c > a\\frac{a+b+3}{a-b-1}\\). See more", 
                                                                 em(a("here.", href = "http://www.emba.uvm.edu/~jxyang/teaching/Math266notes13.pdf")))
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
                                  ),
                                  tabPanel(id="tabPanel2", "Main Results",
                                           dashboardPage(skin = "black",
                                                         dashboardHeader(disable = TRUE),
                                                         dashboardSidebar(disable = TRUE),
                                                         dashboardBody(
                                                           fluidRow(
                                                             box(
                                                               style="height: 80vh; overflow-y: auto; max-height: 500px",
                                                               title = "Phase Graphs", width = 4, solidHeader = TRUE, 
                                                               status = NULL, collapsible = TRUE,
                                                               div(class = "busy", id = "plot-container",  
                                                                   p("Calculation in progress.."), 
                                                                   img(src="spinner2.gif", id = "loading-spinner")
                                                               ),
                                                               conditionalPanel("go",
                                                                                plotlyOutput("plot2", width = "auto", height = "auto")
                                                               )
                                                             ),
                                                             box(
                                                               style="height: 40vh; overflow-y: auto; max-height: 325px",
                                                               title = "Table", width = 4, solidHeader = TRUE, 
                                                               status = NULL, collapsible = TRUE,
                                                               div(class = "busy", id = "plot-container",  
                                                                   p("Calculation in progress.."), 
                                                                   img(src="spinner2.gif", id = "loading-spinner")
                                                               ),
                                                               conditionalPanel("go",
                                                                                dataTableOutput("table")
                                                               )
                                                               
                                                             ),
                                                             box(
                                                               style="height: 80vh; overflow-y: auto; max-height: 500px",
                                                               title = "Time Serie Graphs", width = 4, solidHeader = TRUE, 
                                                               status = NULL, collapsible = TRUE,
                                                               div(class = "busy", id = "plot-container",  
                                                                   p("Calculation in progress.."), 
                                                                   img(src="spinner2.gif", id = "loading-spinner")
                                                               ),
                                                               conditionalPanel("go",
                                                                                plotlyOutput("plot1", width = "auto", height = "auto")
                                                                                
                                                               )
                                                             )
                                                           ),
                                                           
                                                           fluidRow(
                                                             box(
                                                               id ="input1", style="height: 40vh; overflow-y: auto; 
                                       max-height: 325px", # vertical scrolling
                                                               title = "Parameters", width = 2, solidHeader = TRUE, 
                                                               status = NULL, collapsible = TRUE,
                                                               sliderInput("a",
                                                                           "Value of parameter a:",
                                                                           min = 1,
                                                                           max = 20,
                                                                           value = 10),
                                                               sliderInput("b",
                                                                           "Value of parameter b:",
                                                                           min = 1,
                                                                           max = 10,
                                                                           value = 8/3),
                                                               sliderInput("c",
                                                                           "Value of parameter c:",
                                                                           min = 0,
                                                                           max = 100,
                                                                           value = 28)
                                                             ),
                                                             box(
                                                               style="height: 10vh; overflow-y: auto;
                                       max-height: 325px", # vertical scrolling
                                                               title = "Hopf-Bifurcation Control", width = 2, solidHeader = TRUE,
                                                               status = NULL, collapsible = TRUE,
                                                               textOutput("hopf")
                                                             ),
                                                             box(
                                                               style="height: 10vh; overflow-y: auto;
                                       max-height: 325px", # vertical scrolling
                                                               title = "Computation Statistics", width = 2, solidHeader = TRUE,
                                                               status = NULL, collapsible = TRUE,
                                                               textOutput("elapsed_integrating")
                                                             ),
                                                             box(
                                                               style="height: 40vh; overflow-y: auto; 
                                       max-height: 500px", # vertical scrolling
                                                               title = "Model Diagram", width = 6, solidHeader = TRUE, 
                                                               status = NULL, collapsible = TRUE,
                                                               #source("graph.gv"),
                                                               #source("graphbis.mmd")
                                                               source("visNetwork_1.R")
                                                             )
                                                           ),
                                                           fluidRow(
                                                             column(width= 2
                                                             ),
                                                             column(width= 12,
                                                                    box(
                                                                      style="height: 15vh; overflow-y: auto;
                                              max-height: 400px", # vertical scrolling
                                                                      title = "Model Options", width = 3, solidHeader = TRUE,
                                                                      status = NULL, collapsible = TRUE,
                                                                      column(width= 6,
                                                                             radioButtons("modelchoice", "Choose a model:", selected = 1,
                                                                                          choices = list("default(Lorenz classic)" = 1,
                                                                                                         "Lorenz 2" = 2,
                                                                                                         "Lorenz 3" = 3)
                                                                             )
                                                                      ),
                                                                      column(width= 6,
                                                                             radioButtons("solverChoice", "Choose a solver", selected = 1,
                                                                                          choices = list("default (lsode)" = 1,
                                                                                                         "Radau" = 2,
                                                                                                         "ODE23" = 3,
                                                                                                         "ODE45" = 4,
                                                                                                         "Adams" = 5,
                                                                                                         "bdf" =6)
                                                                             )
                                                                      )
                                                                      #verbatimTextOutput("model")
                                                                    )
                                                             )
                                                           )
                                                         )
                                           )
                                  ),
                                  tabPanel(id="tabPanel3", "Model Tweaks",
                                           dashboardPage(skin = "black",
                                                         dashboardHeader(disable = TRUE),
                                                         dashboardSidebar(disable = TRUE),
                                                         dashboardBody(
                                                           fluidRow(
                                                             id = "boxclose",
                                                             box(
                                                               style="height: 40vh; overflow-y: auto; 
                                       max-height: 500px", width = 3,
                                                               title = "Equation Editor",
                                                               p("Below are the R equations of the Lorenz-Model:"),
                                                               aceEditor("ace", value="Lorenz<-function(t, state, parameters) {
  with(as.list(c(state, parameters)),{
   # rate of change
   dX<-a*(Y-X)
   dY<-X*(c-Z) - Y
   dZ<- X*Y - b*Z
   # return the rate of change
   list(c(dX, dY, dZ))
  })
 }", theme="cobalt", mode ="r", 
                                                                         highlightActiveLine = TRUE, autoComplete = "live", height = "200px", 
                                                                         fontSize = 12),
                                                               
                                                               fileInput('modelfile', 'Choose file to upload',
                                                                         accept = c(
                                                                           'text/csv',
                                                                           'text/comma-separated-values',
                                                                           'text/tab-separated-values',
                                                                           'text/plain',
                                                                           '.csv',
                                                                           '.tsv',
                                                                           placeholder="No file selected",
                                                                           buttonLabel="Browse..."
                                                                         )
                                                               ),
                                                               
                                                               #dataTableOutput("out_upload")
                                                               verbatimTextOutput("contents")
                                                               
                                                             ),
                                                             actionButton(class="fa fa-window-close",inputId="close", label="")
                                                           )
                                                         )
                                           )
                                  )
                                  
                      )
             ),
             tabPanel("Sensitivity Analysis",
                      div(style = "position:absolute;right:1em;", 
                          actionButton(class="fa fa-floppy-o fa-5x", inputId="save2", label=" Save", class="btn btn-success"),
                          bsTooltip("save2", "Save the session", 
                                    options = list(container = "body")),
                          actionButton(class="fa fa-refresh fa-5x", inputId="load2", label=" Load", class="btn btn-success"),
                          bsTooltip("load2", "Load the saved session", 
                                    options = list(container = "body")),
                          actionButton(class="fa fa-trash fa-5x", inputId="resetAll2", label=" Reset", class="btn btn-primary"),
                          bsTooltip("resetAll2", "Reset to the initial state", 
                                    options = list(container = "body"))
                          
                      ),
                      tabsetPanel(id="tabsetPanel2",
                                  tabPanel(id="tabPanel4", "About sensitivity analysis",
                                           dashboardPage(skin = "black",
                                                         dashboardHeader(disable = TRUE),
                                                         dashboardSidebar(disable = TRUE),
                                                         dashboardBody(
                                                           fluidRow(
                                                             box(
                                                               
                                                             ),
                                                             box(
                                                               
                                                             )
                                                           )
                                                           
                                                         )
                                           )
                                  ),
                                  tabPanel(id="tabPanel5", "Results",
                                           dashboardPage(skin = "black",
                                                         dashboardHeader(disable = TRUE),
                                                         dashboardSidebar(disable = TRUE),
                                                         dashboardBody(
                                                           fluidRow(
                                                             box(
                                                               style="height: 40vh; overflow-y: auto; max-height: 325px",
                                                               title = "Table", width = 6, solidHeader = TRUE, 
                                                               status = NULL, collapsible = TRUE,
                                                               div(class = "busy", id = "plot-container",  
                                                                   p("Calculation in progress.."), 
                                                                   img(src="spinner2.gif", id = "loading-spinner")
                                                               ),
                                                               conditionalPanel("gosensitivity",
                                                                                
                                                                                dataTableOutput("SnsLorenz"),
                                                                                dataTableOutput("Coll")
                                                                                #tableOutput("paramRanges")
                                                                                #dataTableOutput("sR")
                                                               )
                                                             ),
                                                             box(
                                                               style="height: 40vh; overflow-y: auto; max-height: 700px",
                                                               title = "Plot", width = 6, solidHeader = TRUE, 
                                                               status = NULL, collapsible = TRUE,
                                                               div(class = "busy", id = "plot-container",  
                                                                   p("Calculation in progress.."), 
                                                                   img(src="spinner2.gif", id = "loading-spinner")
                                                               ),
                                                               conditionalPanel("gosensitivity",
                                                                                
                                                                                plotOutput("sens1plot"),
                                                                                plotOutput("sens2plot")
                                                               )
                                                               
                                                             )
                                                           ),
                                                           fluidRow(
                                                             box(
                                                               id ="input2", style="height: 40vh; overflow-y: auto; 
                                                      max-height: 450px", # vertical scrolling
                                                               title = "Parameters", width = 3, solidHeader = TRUE, 
                                                               status = NULL, collapsible = TRUE,
                                                               sliderInput("sliderrange1", label = "Range of parameter a", min = 0, 
                                                                           max = 20, value = c(5, 10)),
                                                               sliderInput("sliderrange2", label = "Range of parameter b", min = 0, 
                                                                           max = 10, value = c(2, 4)),
                                                               sliderInput("sliderrange3", label = "Range of parameter c", min = 0, 
                                                                           max = 100, value = c(20, 50)),
                                                               
                                                               numericInput("modelrun", label = "How much times run the model", 
                                                                            value = NULL),
                                                               
                                                               radioButtons("modelchoice", "Choose a model:", selected = 1,
                                                                            choices = list("default(Lorenz classic)" = 1,
                                                                                           "Lorenz 2" = 2,
                                                                                           "Lorenz 3" = 3)
                                                               ),
                                                               
                                                               actionButton("gosensitivity", label = "Run Sensitivity Analysis")
                                                               
                                                             ),
                                                             box(
                                                               style="height: 40vh; overflow-y: auto; max-height: 500px",
                                                               title = "Plot", width = 8, solidHeader = TRUE, 
                                                               status = NULL, collapsible = TRUE,
                                                               div(class = "busy", id = "plot-container",  
                                                                   p("Calculation in progress.."), 
                                                                   img(src="spinner2.gif", id = "loading-spinner")
                                                               ),
                                                               conditionalPanel("gosensitivity",
                                                                                
                                                                                plotOutput("Snsplot"),
                                                                                plotOutput("Snspairs"),
                                                                                plotOutput("SFMCplot")
                                                               )
                                                               
                                                             )
                                                             
                                                           )
                                                           
                                                         )
                                           )
                                  )
                      )
             ),
             navbarMenu("Test",
                        tabPanel("Sub-menu 1"),
                        tabPanel("Sub-menu 2"),
                        tabPanel("Sub-menu 3")
             )
             # textOutput("counter") Find a better container to put the counter
  )
))