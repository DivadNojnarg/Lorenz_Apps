# automate the creation of 3 identical sliders
sliderLorenz <- function(inputId, label) {
  column(
    width = 4,
    align = "center",
    sliderInput(
      inputId = inputId, 
      label = paste0("Value of", label, ":"), 
      min = 0, 
      max = 20, 
      value = 10) %>%
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


# Compute Ui elements
computeLorenzUi <- function(id) {
  ns <- NS(id)
  
  tagAppendAttributes(
    fluidRow(
      sliderLorenz(inputId = ns("a"), label = "a"),
      sliderLorenz(inputId = ns("b"), label = "b"),
      sliderLorenz(inputId = ns("c"), label = "c")
    ),
    id = "3d_plot"
  )
  
}


# Modole integrations
computeLorenz <- function(input, output, session, solver_params) {
  
  
  # store reactives values
  parameters <- reactive(c("a" = input$a, "b" = input$b, "c" = input$c))
  state <- reactive(c("X" = solver_params$X0(), "Y" = solver_params$Y0(), "Z" = solver_params$Z0()))
  times <- reactive(seq(0, solver_params$tmax(), by = solver_params$dt()))
  
  # integrate the Lorenz ode model with reactive inputs, 
  # solver is selected by the user in the right sidebar
  # deSolve or RxODE, respectively
  out <- reactive({
    
    parameters <- as.numeric(parameters())
    state <- state()
    times <- times()
    
    # scale back
    atol <- 1e-06 * solver_params$atol()
    rtol <- 1e-06 * solver_params$rtol()
    
    as.data.frame(
      ode(
        y = state, 
        times = times, 
        func = "derivs", 
        jacfunc = "jac",
        dllname = "Lorenz",
        initfunc = "initmod",
        parms = parameters, 
        method = solver_params$solver(), 
        rtol = rtol, 
        atol = atol
      )
    )
  })
  
  
  return(list(res = out, model_params = parameters))
}