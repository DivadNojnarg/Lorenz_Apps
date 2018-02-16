sidebar <- dashboardSidebar(
  width = 300,
  
  sidebarMenu(
    
    id = "sidebar_main",
    
    menuItem("Info", tabName = "info", icon = icon("info")),
    menuItem("App", tabName = "main", icon = icon("home"), selected = TRUE),
    menuItem("Solver Settings", tabName = "solve_settings", icon = icon("cogs"),
             
             h6(shiny::icon("cogs"), "Solver Parameters"),
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
    menuItem("Initial conditions", tabName = "init_settings", icon = icon("flask"),
             
             h6("Initial Conditions Parameters"),
             
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
    )
  )
)
