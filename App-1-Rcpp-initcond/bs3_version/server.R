# define server function
shinyServer(function(input, output, session) {
  
  
  #-------------------------------------------------------------------------
  #
  #  Useful reactive expressions ...
  #
  #-------------------------------------------------------------------------
  
  tmax <- reactive({input$tmax})
  dt <- reactive({input$dt})
  Smin <- reactive({input$Smin})
  Smax <- reactive({input$Smax})
  number_state <- reactive({input$n})
  
  # Generate the select input list of initial conditions
  output$selectinput1 <- renderUI({
    selectInput("initcondselected", "Choose initial condition (Pairs plot):", 
                choices = c(0, seq(1:input$n)), selected = "0", width = "100%")
  })
  
  # generate some warning regarding parameters
  observe({
    feedbackWarning(
      inputId = "Smin",
      condition = !is.null(input$Smin),
      text = "Min sampling should be < to Max sampling."
    )
    feedbackDanger(
      inputId = "n",
      condition = !is.null(input$n),
      text = "Don't push it too hard if your computer is limited!"
    )
    if (input$Smin >= input$Smax) {
      shinyjs::reset("Smin")
      shinyjs::reset("Smax")
    }
  })
  
  # initial conditions
  state <- reactive({
    state_0 <- t(
      replicate(
        number_state(), sample(Smin():Smax(),size = 3), simplify = "array"
        )
      )
    n_init <- seq(1,dim(state_0)[1], by = 1)
    rownames(state_0) <- paste(n_init)
    return(state_0)
  })
  
  output$state <- renderPrint({state()})
  
  #-------------------------------------------------------------------------
  #
  #  Integrate the system ...
  #
  #-------------------------------------------------------------------------
  
  # integrate the Lorenz ode model with reactive inputs
  out <- reactive({
    tmax <- tmax()
    dt <- dt()
    state <- state()
    # using parallel here
    list_out <- mclapply(1:nrow(state), function(i){
      
      init <- c(state[i, 1],
                state[i, 2],
                state[i, 3])
      
      if (input$model_library == "odeintr") {
        out <- as.data.frame(lorenz(init, tmax, dt))
      } else {
        ev1$add.sampling(seq(0, tmax, by = dt))
        out <- mod1$solve(theta, events = ev1, inits = init, stiff = TRUE)
      }
      
    })
    data_out <- do.call(
      # using parallel here
      rbind, mclapply(seq_along(list_out), 
                    function(x) data.frame(list_out[[x]], x, stringsAsFactors = FALSE)))
    data_out[, 5] <- as.numeric(data_out[, 5])
    return(data_out) # each sublist of list_out are bound by lines 
  })
  
  #-------------------------------------------------------------------------
  #
  #  Plot results ...
  #
  #-------------------------------------------------------------------------
  
  # pairs plot
  output$plot1 <- renderPlot({
    req(input$initcondselected)
    validate(
      need(input$initcondselected >= 1, 
           "select a initial condition to target, in the right sidebar")
    )
    out <- out()
    # pair plot of the first initial condition (time consuming ...)
    p1 <- plot(out[out$x == input$initcondselected,-5], upper.panel = NULL) 
  })
  
  # space plot
  output$plot2 <- renderPlotly({
    out <- out()
    # use split to filter when x=1, x=2, x=10 ...
    p2 <- plot_ly(out, x = out[, 2], y = out[, 3],
                  z = out[, 4], split = ~x, type = 'scatter3d', mode = 'lines', 
                  line = list(width = 4))
    #  add_markers(p2, x = out[1, 2], y = out[1, 3], z = out[1, 4]) # initial position
  })
  
  #-------------------------------------------------------------------------
  #
  #  Useful tasks such as save, reset, load ...
  #
  #-------------------------------------------------------------------------
  
  
  # change the dashboard skin
  current_skin <- reactiveValues(color = NULL)
  previous_skin <- reactiveValues(color = NULL)
  observeEvent(input$skin,{
    # the first time, previous_skin$color is set to the first
    # skin value at opening. Same thing for current value
    if (is.null(previous_skin$color)) {
      previous_skin$color <- current_skin$color <- input$skin
    } else {
      current_skin$color <- input$skin
      # if the old skin is the same as the current selected skin
      # then, do nothing
      if (previous_skin$color == current_skin$color) {
        NULL
      } else {
        # otherwise, remove the old CSS class and add the new one
        shinyjs::removeClass(selector = "body", class = paste("skin", previous_skin$color, sep = "-"))
        shinyjs::addClass(selector = "body", class = paste("skin", current_skin$color, sep = "-"))
        # the current skin is added to previous_skin to be ready for
        # the next change
        previous_skin$color <- c(previous_skin$color, current_skin$color)[-1]
      }
    }
  })
  
  #reset sliders individually
  rv <- reactiveValues(lastBtn = character())
  reset <- c("reset_tmax", "reset_n", "reset_dt", "reset_Smin", "reset_Smax")
  lapply(seq_along(reset), FUN = function(i) {
    observeEvent(input[[reset[[i]]]], {
      if (input[[reset[[i]]]] > 0) {
        rv$lastBtn <- paste(reset[[i]])
        slider_name <- unlist(str_split(rv$lastBtn, "reset_"))[[2]]
        shinyjs::reset(slider_name)
      }
    }, ignoreInit = TRUE)
  })
  
  # Custom footer
  output$dynamicFooter <- renderFooter({
    dashboardFooter(
      mainText = h5(
        "2017, David Granjon, Zurich.",
        br(),
        "Built with",
        img(src = "https://www.rstudio.com/wp-content/uploads/2014/04/shiny.png", height = "30"),
        "by",
        img(src = "https://www.rstudio.com/wp-content/uploads/2014/07/RStudio-Logo-Blue-Gray.png", height = "30"),
        "and with", img(src = "love.png", height = "30")),
      subText = HTML("<b>Version</b> 0.5")
    )
  })
  
  # Set this to "force" instead of TRUE for testing locally (without Shiny Server)
  # Only works with shiny server > 1.4.7
  session$allowReconnect(TRUE)
  
})