
# Slider for atol and rtol
sliderPrecision <- function(inputId, label) {
  tagList(
    sliderInput(
      inputId, 
      label = label, 
      min = 0.001, 
      max = 1, 
      step = 0.001,
      value = 0.5) %>%
      shinyInput_label_embed(
        icon("undo") %>%
          actionBttn(
            inputId = paste0("reset_", inputId),
            label = "", 
            color = "danger", 
            size = "xs"
          )
      )
  )
}


# All solver related inputs in the controlbar
solverInputsUi <- function(id) {
  
  ns <- NS(id)
  
  tagList(
    # integration steps
    numericInput(inputId = ns("tmax"), label = "Value of tmax:", value = 100, min = 0, max = NA),
    numericInput(inputId = ns("dt"), label = "Step of integration:",  value = 0.01, min = 0, max = NA),
    
    # numerical method
    selectInput(
      inputId = ns("solver"), 
      label = "Choose a solver:", 
      choices = c(
        "lsoda", "lsode", "lsodes", 
        "lsodar", "vode", "daspk",
        "euler", "rk4", "ode23", 
        "ode45", "radau", "bdf", 
        "bdf_d", "adams", "impAdams", 
        "impAdams_d"
      )
    ),
    
    # precision
    sliderPrecision(inputId = ns("rtol"), label = "Relative Tolerance"),
    sliderPrecision(inputId = ns("atol"), label = "Absolute Tolerance"),
    
    # initial conditions 
    numericInput(inputId = ns("X0"), label = "Initial value of X:", value = 1, min = 0, max = 100),
    numericInput(inputId = ns("Y0"), label = "Initial value of Y:", value = 1, min = 0, max = 100),
    numericInput(inputId = ns("Z0"), label = "Initial value of Z:", value = 1, min = 0, max = 100)
  )
}


# Make all inputs available for all modules
solverInputs <- function(input, output, session) {
  return(
    list(
      tmax = reactive(input$tmax),
      dt = reactive(input$dt),
      solver = reactive(input$solver),
      atol = reactive(input$atol),
      rtol = reactive(input$rtol),
      X0 = reactive(input$X0),
      Y0 = reactive(input$Y0),
      Z0 = reactive(input$Z0)
    )
  )
}