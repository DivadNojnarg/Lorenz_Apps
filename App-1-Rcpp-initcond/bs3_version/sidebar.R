sidebar <- dashboardSidebar(
  width = 300,
  
  sidebarMenu(
    
    id = "sidebar_main",
    
    menuItem("Info", tabName = "info", icon = icon("info")),
    menuItem("App", tabName = "main", icon = icon("home"), selected = TRUE),
    menuItem("Solver Settings", tabName = "solve_settings", icon = icon("cogs"),
             
             prettyRadioButtons(inputId = "model_library",
                                label = "Choose an ODE solver",
                                choices = c("odeintr", "RxODE"),
                                animation = "pulse",
                                selected = "odeintr",
                                thick = TRUE,
                                inline = FALSE,
                                bigger = TRUE),
             
             hr(),
        
             sliderInput("tmax",
                         "Maximum time of integration:",
                         min = 1,
                         max = 200,
                         value = 10) %>%
               shinyInput_label_embed(
                 icon("undo") %>%
                   actionBttn(inputId = "reset_tmax",
                              label = "", 
                              color = "danger", 
                              size = "xs")
               ),
             
             sliderInput("dt",
                         "Integration step:",
                         min = 0.0001,
                         max = 0.001,
                         value = 0.0005) %>%
               shinyInput_label_embed(
                 icon("undo") %>%
                   actionBttn(inputId = "reset_dt",
                              label = "", 
                              color = "danger", 
                              size = "xs")
               )
    ),
    menuItem("Initial conditions", tabName = "init_settings", icon = icon("flask"),
             
             sliderInput("n", "Number of initial conditions", 
                         min = 1, 
                         max = 100, 
                         value = 1) %>%
               shinyInput_label_embed(
                 icon("undo") %>%
                   actionBttn(inputId = "reset_n",
                              label = "", 
                              color = "danger", 
                              size = "xs")
               ), 
             
             sliderInput("Smin", "Minimum value of sampling", 
                         min = 0, 
                         max = 100, 
                         value = 1) %>%
               shinyInput_label_embed(
                 icon("undo") %>%
                   actionBttn(inputId = "reset_Smin",
                              label = "", 
                              color = "danger", 
                              size = "xs")
               ),
             
             sliderInput("Smax", "Maximum value of sampling", 
                         min = 1, 
                         max = 100, 
                         value = 1000) %>%
               shinyInput_label_embed(
                 icon("undo") %>%
                   actionBttn(inputId = "reset_Smax",
                              label = "", 
                              color = "danger", 
                              size = "xs")
               )
    )
  )
)
