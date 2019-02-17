#-------------------------------------------------------------------------
#  This code contains the controlsidebar of shinydashboard. It is the
#  sidebar available on the left. Parameters are put in this sidebar.
#  Sliders are handled via a conditionalPanel, but this can be disable
#
#  David Granjon, the Interface Group, Zurich
#  December 4th, 2017
#-------------------------------------------------------------------------
controlbar <- bs4DashControlbar(
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
    min = 0.001, 
    max = 1, 
    step = 0.001,
    value = 0.5) %>%
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
    min = 0.001, 
    max = 1, 
    step = 0.001,
    value = 0.5) %>%
    shinyInput_label_embed(
      icon("undo") %>%
        actionBttn(
          inputId = "reset_atol",
          label = "", 
          color = "danger", 
          size = "xs"
        )
    ),
  
  numericInput("X0","Initial value of X:", 1, min = 0, max = 100),
  numericInput("Y0","Initial value of Y:", 1, min = 0, max = 100),
  numericInput("Z0","Initial value of Z:", 1, min = 0, max = 100)
)

# add an id arg to reset the controlbar input with shinyjs
# we act on the second element since the first contains
# javascript code
controlbar[[2]] <- tagAppendAttributes(controlbar[[2]], id = "controlbar")
