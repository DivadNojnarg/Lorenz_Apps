body <- dashboardBody(
  fluidRow(
    box(
      title = tagList(shiny::icon("calendar"), "Infos"), width = 6, collapsible = T, solidHeader = TRUE,
      p("This simple application aims at solving the Lorenz Model for different initial conditions.
        You can change the integration time or time step by playing with sliders. Moreover, you can control the
        sampling of initial conditions by specifying a minimum and a maximum value. Be carefull, the minimum 
        value cannot be higher than the maximum one. The whole system is integrated using Rcpp function to improve
        the overall speed. The maximum number of initial conditions to be displayed together is set to 100, 
        to prevent the application from crashing, due to a graphic overload."),
      p("The Lorenz model was developed by Edward Lorenz (see Lorenz, Journal of the 
        Atmospheric Sciences,20: 1963). This finite system is composed of 3 ordinary
        differential equations, which can be obtained from
        ", 
        em(a("Saltzman", href = "http://kiamagic.com/wiki/index.php/
             Deterministic_Nonperiodic_Flow_-_The_convection_equations_of_Saltzman")), 
        "equations."),
      
      p("The equations behind the Lorenz model are:"),
      p(withMathJax("$$\\left\\{
                    \\begin{align}
                    \\frac{dX}{dt} & = a(Y-X),\\\\
                    \\frac{dY}{dt} & = X(c-Z) - Y,\\\\
                    \\frac{dZ}{dt} & = XY - bZ,
                    \\end{align}
                    \\right.$$")),
      
      
      p("where \\(a\\) is the Prandtl number."),
      p("The graph section displays trajectories in 3d space, as well as a pairs plot of the selected initial
        conditions. The time for computing may be important!"),
      br()  
    ),
    tabBox(
      title = tagList(shiny::icon("microchip"), "Graphs"),
      selected = "Graph 3D", id = "tabset1",
      tabPanel(title = tagList(shiny::icon("area-chart"), "Graph 3D"),
               withSpinner(plotlyOutput("plot2", width = "auto", height = "auto"), 
                           size = 2, type = 6, color = "#000000")
      ),
      tabPanel(title = tagList(shiny::icon("line-chart"), "Pairs Plot"),
               withSpinner(plotOutput("plot1"), size = 2, type = 6, color = "#000000")
      )
    )
  ),
  fluidRow(
    box(
      id = "boxinput",
      title = tagList(shiny::icon("gear"), "Control Center"), width = 12, collapsible = T, solidHeader = TRUE,
      style="height: 40vh; overflow-y: auto; max-height: 400px;",
      column(4, align="center",
             h3(shiny::icon("cogs"), "Solver Parameters"),
             br(),
             sliderInput("tmax",
                         "Maximum time of integration:",
                         min = 1,
                         max = 200,
                         value = 10),
             sliderInput("dt",
                         "Integration step:",
                         min = 0.0001,
                         max = 0.001,
                         value = 0.0005)  
      ),
      column(4, align="center",
             h3(shiny::icon("flask"), "Initial Conditions Parameters"),
             br(),
             sliderInput("n", "Number of initial conditions", 
                         min = 1, 
                         max = 100, 
                         value = 1),
             sliderInput("Smin", "Minimum value of sampling", 
                         min = 0, 
                         max = 100, 
                         value = 1),
             sliderInput("Smax", "Maximum value of sampling", 
                         min = 1, 
                         max = 100, 
                         value = 1000)
      ),
      column(4, align="center",
             h3(shiny::icon("eyedropper"), "List of Initial Conditions for Pairs Plot"),
             br(),
             uiOutput("selectinput1"),
             withSpinner(verbatimTextOutput("state"), size = 2, type = 6, color = "#000000")
      )
    )
  ),
  fluidRow(
    infoBoxOutput("sourceBox", width = 4),
    infoBoxOutput("progressBox", width = 4), 
    infoBoxOutput("nameBox", width = 4)
  )
)