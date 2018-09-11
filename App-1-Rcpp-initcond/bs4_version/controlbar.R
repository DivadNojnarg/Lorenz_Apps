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

  prettyRadioButtons(
    inputId = "model_library",
    label = "Choose an ODE solver",
    choices = c("odeintr", "RxODE"),
    animation = "pulse",
    selected = "odeintr",
    thick = TRUE,
    inline = TRUE,
    bigger = TRUE
  ),
  
  sliderInput(
    "tmax",
    "Maximum time of integration:",
    min = 1,
    max = 200,
    value = 10) %>%
    shinyInput_label_embed(
      icon("undo") %>%
        actionBttn(
          inputId = "reset_tmax",
          label = "", 
          color = "danger", 
          size = "xs"
        )
    ),
  
  sliderInput(
    "dt",
    "Integration step:",
    min = 0.0001,
    max = 0.001,
    value = 0.0005) %>%
    shinyInput_label_embed(
      icon("undo") %>%
        actionBttn(
          inputId = "reset_dt",
          label = "", 
          color = "danger", 
          size = "xs"
        )
    ),
  
  numericInput(
    "n", 
    "Number of initial conditions", 
    min = 1, 
    max = 100, 
    value = 1) %>%
    shinyInput_label_embed(
      icon("undo") %>%
        actionBttn(
          inputId = "reset_n",
          label = "", 
          color = "danger", 
          size = "xs"
        )
    ), 
  
  numericInput(
    "Smin", "Minimum value of sampling", 
    min = 0, 
    max = 100, 
    value = 1) %>%
    shinyInput_label_embed(
      icon("undo") %>%
        actionBttn(
          inputId = "reset_Smin",
          label = "", 
          color = "danger", 
          size = "xs"
        )
    ),
  
  numericInput(
    "Smax", "Maximum value of sampling", 
    min = 1, 
    max = 100, 
    value = 100) %>%
    shinyInput_label_embed(
      icon("undo") %>%
        actionBttn(
          inputId = "reset_Smax",
          label = "", 
          color = "danger", 
          size = "xs"
        )
    )
)
