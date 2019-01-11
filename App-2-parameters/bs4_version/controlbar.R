#-------------------------------------------------------------------------
#  This code contains the controlsidebar of shinydashboard. It is the
#  sidebar available on the left. Parameters are put in this sidebar.
#  Sliders are handled via a conditionalPanel, but this can be disable
#
#  David Granjon, the Interface Group, Zurich
#  December 4th, 2017
#-------------------------------------------------------------------------
controlbar <- tagAppendAttributes(
  bs4DashControlbar(
    skin = "light",
    title = "Solver Settings",
    
    numericInput("tmax","Value of tmax:", 100, min = 0, max = NA),
    numericInput("dt","Step of integration:", 0.01, min = 0, max = NA),
    selectInput(
      "solver", 
      "Choose a solver:", 
      choices = c(
        "lsoda", "lsode", "lsodes", 
        "lsodar", "vode", "daspk",
        "euler", "rk4", "ode23", 
        "ode45", "radau", "bdf", 
        "bdf_d", "adams", "impAdams", 
        "impAdams_d"
      )
    ),
    sliderInput(
      "rtol", 
      label = "Relative tolerance", 
      min = 1e-10,
      max = 1e-02, 
      value = 1e-06) %>%
      shinyInput_label_embed(
        icon("undo") %>%
          actionBttn(
            inputId = "reset_rtol",
            label = "", 
            color = "danger", 
            size = "xs"
          )
      ),
    sliderInput(
      "atol", 
      label = "Absolute tolerance", 
      min = 1e-10, 
      max = 1e-02, 
      value = 1e-06) %>%
      shinyInput_label_embed(
        icon("undo") %>%
          actionBttn(
            inputId = "reset_atol",
            label = "", 
            color = "danger", 
            size = "xs"
          )
      ),
    
    prettyRadioButtons(
      inputId = "compile",
      label = "Choose an ODE solver",
      choices = c("deSolve", "RxODE"),
      animation = "pulse",
      selected = "deSolve",
      thick = TRUE,
      inline = TRUE,
      bigger = TRUE
    ),
    
    numericInput("X0","Initial value of X:", 1, min = 0, max = 100),
    numericInput("Y0","Initial value of Y:", 1, min = 0, max = 100),
    numericInput("Z0","Initial value of Z:", 1, min = 0, max = 100)
  ),
  # add id attribute to the controlbar to use shinyjs::reset later
  id = "controlbar"
)
