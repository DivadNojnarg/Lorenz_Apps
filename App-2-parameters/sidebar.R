sidebar <- dashboardSidebar(
  width = 300,
  
  sidebarMenu(
    
    id = "sidebar_main",
    
    menuItem("Info", tabName = "info", icon = icon("info")),
    menuItem("App", tabName = "main", icon = icon("home"), selected = TRUE),
    menuItem("Datas", tabName = "datas", icon = icon("table")),
    menuItem("Solver Settings", tabName = "solve_settings", icon = icon("cogs"),
             
             numericInput("tmax","Value of tmax:", 100, min = 0, max = NA),
             numericInput("dt","Step of integration:", 0.01, min = 0, max = NA),
             selectInput("solver", "Choose a solver:", 
                         choices = c("lsoda", "lsode", "lsodes", 
                                     "lsodar", "vode", "daspk",
                                     "euler", "rk4", "ode23", 
                                     "ode45", "radau", "bdf", 
                                     "bdf_d", "adams", "impAdams", 
                                     "impAdams_d")),
             sliderInput("rtol", label = "Relative tolerance", 
                         min = 1e-10, max = 1e-02, value = 1e-06),
             sliderInput("atol", label = "Absolute tolerance", 
                         min = 1e-10, max = 1e-02, value = 1e-06)
    ),
    menuItem("Speed up", tabName = "speedup", icon = icon("calculator"),
             
             prettyRadioButtons(inputId = "compile",
                                label = "Choose an ODE solver",
                                choices = c("deSolve", "RxODE"),
                                animation = "pulse",
                                selected = "deSolve",
                                thick = TRUE,
                                inline = FALSE,
                                bigger = TRUE)
    ),
    menuItem("Initial conditions", tabName = "init_settings", icon = icon("flask"),
             
             numericInput("X0","Initial value of X:", 1, min = 0, max = 100),
             numericInput("Y0","Initial value of Y:", 1, min = 0, max = 100),
             numericInput("Z0","Initial value of Z:", 1, min = 0, max = 100)
    )
  )
)

