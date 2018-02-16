body <- dashboardBody(
  useShinyjs(),
  withMathJax(),
  useShinyFeedback(),
  
  tabItems(
    tabItem(
      tabName = "main",
      
      fluidRow(
        box(
          title = tagList(shiny::icon("area-chart"), "Graph 3D"), width = 6, 
          collapsible = T, solidHeader = TRUE, 
          withSpinner(plotlyOutput("plot2", width = "auto", height = "500px"), 
                      size = 2, type = 6, color = "#000000")
        ),
        box(
          title = tagList(shiny::icon("line-chart"), "Pairs Plot"), width = 6, 
          collapsible = T, solidHeader = TRUE,
          
          withSpinner(plotOutput("plot1", height = "500px"), 
                      size = 2, type = 6, color = "#000000")
        )
      )
    ),
    tabItem(
      tabName = "info",
      box(
        title = tagList(shiny::icon("calendar"), "Infos"), width = 12, collapsible = T, solidHeader = TRUE,
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
      )
    )
  )
)