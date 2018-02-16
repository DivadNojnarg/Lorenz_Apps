# define server function
shinyServer(function(input, output, session) {
  
  tmax <- reactive({input$tmax})
  dt <- reactive({input$dt})
  Smin <- reactive({input$Smin})
  Smax <- reactive({input$Smax})
  number_state <- reactive({input$n})
  
  state <- reactive({
    state_0 <- t(replicate(number_state(), sample(Smin():Smax(),size = 3), simplify = "array"))
    n_init <- seq(1,dim(state_0)[1], by = 1)
    rownames(state_0) <- paste(n_init)
    return(state_0)
  })
  
  output$state <- renderPrint({state()})
  
  # integrate the Lorenz ode model with reactive inputs
  out <- reactive({
    list_out <- apply(state(), 1, function(x0){
      
      init <- c(x0[1],
                x0[2],
                x0[3])
      
      tmax <- tmax()
      dt <- dt()
      
      out = as.data.frame(lorenz(init, tmax, dt))
    })
    
    data_out <- do.call(rbind, lapply(names(list_out),
                                      function(x) data.frame(list_out[[x]], x, stringsAsFactors = FALSE)))
    data_out[,5] <- as.numeric(data_out[,5])
    return(data_out) # each sublist of list_out are bound by lines 
    
  })
  
  # Generate the select input list of initial conditions
  output$selectinput1 <- renderUI({
    selectInput("initcondselected", "Choose initial condition (Pairs plot):", 
                choices = seq(1:input$n), width = "100%")
  })
  
  # Generate the plot correspondint to out
  plot1 <- eventReactive(input$initcondselected,{
    out <- out()
    p1 <- plot(out[out$x == input$initcondselected,-5], upper.panel = NULL) # pair plot of the first initial condition
  })
  
  plot2 <- reactive({
    
    out <- out()
    
    p2 <- plot_ly(out, x = out[, 2], y = out[, 3],
                  z = out[, 4], split = ~x, type = 'scatter3d', mode = 'lines', # use split to filter when x=1, x=2, x=10 ...
                  line = list(width = 4))
    #  add_markers(p2, x = out[1, 2], y = out[1, 3], z = out[1, 4]) # initial position
    
  })
  
  output$plot1 <- renderPlot({plot1()})
  output$plot2 <- renderPlotly({plot2()})
  
  
  
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
      subText = HTML("<b>Version</b> 0.3")
    )
  })
  
  
  
  session$onSessionEnded(stopApp) # stop shiny app when the web-window is closed
  
})