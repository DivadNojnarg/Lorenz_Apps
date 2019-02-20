# automate the creation of 3 identical sliders
sliderLorenz <- function(inputId, label, value, inputIdReset) {
  sliderInput(
    inputId = inputId, 
    label = paste0("Value of ", label, ":"), 
    min = value / 10, 
    max = value * 2, 
    value = value) %>%
    shinyInput_label_embed(
      icon("undo") %>%
        actionBttn(
          inputId = inputIdReset,
          label = "", 
          color = "danger", 
          size = "xs"
        )
    )
}



# autonate radioBttn for phase plane

radioLorenz <- function(inputId, label, selected) {
  prettyRadioButtons(
    shape = "square",
    inputId = inputId,
    animation = "pulse",
    choices = c("X", "Y", "Z"),
    selected = selected,
    status = "primary",
    label = label,
    inline = TRUE
  )
}


# Compute Ui elements
# We already use ns in the sliderLorenz function
computeLorenzUi <- function(id) {
  
  ns <- NS(id)
  
  dropdownButton(
    inputId = ns("parms_list"),
    label = "Controls",
    icon = icon("sliders"),
    status = "primary",
    circle = FALSE,
    size = "sm",
    tooltip = "Model Options",
    
    # content
    # add id attrib to reset with shinyjs
    tagAppendAttributes(
      div(
        align = "center",
        style = "height: 400px; overflow-y: scroll; overflow-x: hidden;",
        sliderLorenz(inputId = ns("a"), label = "a", value = 10, inputIdReset = ns("reset_a")),
        sliderLorenz(inputId = ns("b"), label = "b", value = 3, inputIdReset = ns("reset_b")),
        sliderLorenz(inputId = ns("c"), label = "c", value = 28, inputIdReset = ns("reset_c")),
        hr(),
        radioLorenz(inputId = ns("xvar"), label = "X axis variable", selected = "X"),
        radioLorenz(inputId = ns("yvar"), label = "Y axis variable", selected = "Y"),
        
        hr(),
        tagList(
          tagAppendAttributes(
            prettySwitch(
              inputId = ns("print_infoboxes"),
              label = "Print Info Boxes?",
              status = "danger",
              value = TRUE,
              fill = TRUE,
              bigger = TRUE
            ),
            class = "my-2"
          )
        )
      ),
      id = "lorenzParms"
    )
  )
  
}


# Modole integrations
computeLorenz <- function(input, output, session, solver_params) {
  
  
  # store reactives values
  parameters <- reactive(c("a" = input$a, "b" = input$b, "c" = input$c))
  state <- reactive(c("X" = solver_params$X0(), "Y" = solver_params$Y0(), "Z" = solver_params$Z0()))
  times <- reactive(seq(0, solver_params$tmax(), by = solver_params$dt()))
  plot_parameters <- reactive(c("xvar" = input$xvar, "yvar" = input$yvar))
  infoBoxes <- reactive(input$print_infoboxes)
  
  # integrate the Lorenz ode model with reactive inputs, 
  # solver is selected by the user in the right sidebar
  # deSolve or RxODE, respectively
  out <- reactive({
    
    parameters <- as.numeric(parameters())
    state <- state()
    times <- times()
    
    # precision (do not change)
    atol <- 1e-06 
    rtol <- 1e-06 
    
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
  
  
  #reset sliders individually
  rv <- reactiveValues(lastBtn = character())
  reset <- c("reset_a", "reset_b", "reset_c")
  lapply(seq_along(reset), FUN = function(i) {
    observeEvent(input[[reset[[i]]]], {
      if (input[[reset[[i]]]] > 0) {
        rv$lastBtn <- paste(reset[[i]])
        slider_name <- unlist(str_split(rv$lastBtn, "reset_"))[[2]]
        shinyjs::reset(slider_name)
      }
    }, ignoreInit = TRUE)
  })
  
  
  return(
    list(
      res = out, 
      model_params = parameters, 
      plot_params = plot_parameters,
      print_infos = infoBoxes
    )
  )
}