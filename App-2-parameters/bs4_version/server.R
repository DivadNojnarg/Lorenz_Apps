# Server code
shinyServer(function(input, output, session) {
  
  #-------------------------------------------------------------------------
  #
  #  Useful reactive expressions ...
  #
  #-------------------------------------------------------------------------
  
  # store reactives values
  parameters <- reactive({c("a" = input$a,"b" = input$b,"c" = input$c)})
  state <- reactive({c("X" = input$X0,"Y" = input$Y0,"Z" = input$Z0)})
  times <- reactive({seq(0,input$tmax, by = input$dt)})
  
  #-------------------------------------------------------------------------
  #
  #  Integrate the system and perform other calculations (hopf bifurcation)
  #
  #-------------------------------------------------------------------------
  
  # Hopf bifurcation or not? 
  output$hopf <- renderbs4InfoBox({
    no_hopf <- "input$c < input$a * (input$a + input$b + 3) / (input$a - input$b - 1)"
    no_hopf <- eval(parse(text = no_hopf))
    
    res <- round(input$a * (input$a + input$b + 3) / (input$a - input$b - 1))
    
    if (no_hopf) {
      r1 <- paste(input$c, "<", res, ": no Hopf-bifurcation")
    } else {
      r1 <- paste(input$c, ">", res, ": Hopf-bifurcation")
    }
    bs4InfoBox(
      title = "Hopf Bifurcation?", 
      value = r1, 
      icon = "thumbs-up",
      status = NULL,  
      iconElevation = 4
    )
  })
  
  output$pitchfork <- renderbs4InfoBox({
    if (0 < input$c && input$c <= 1) {
      r2 <- paste(0, "=<", input$c,"=<", 1, ": (0,0,0) is the only one equilibrium")
    } else {
      r2 <- paste(input$c,">", 1, ": 3 equilibrium, (0,0,0) is unstable")
    }
    
    bs4InfoBox(
      title = "Pitchfork Bifurcation?", 
      value = r2, 
      icon = "thumbs-up", 
      status = NULL,
      iconElevation = 4
    )
  })
  
  
  # integrate the Lorenz ode model with reactive inputs, solver is selected by the user
  out <- reactive({
    
    parameters <- parameters()
    state <- state()
    times <- times()
    
    if (input$compile == "deSolve") {
      as.data.frame(
        ode(
          y = state, 
          times = times, 
          func = Lorenz, 
          parms = parameters, 
          method = input$solver, 
          rtol = input$rtol, 
          atol = input$atol
        )
      )
    } else {
      ev1$add.sampling(times)
      as.data.frame(
        mod1$solve(
          params = parameters, 
          events = ev1, 
          inits = state, 
          stiff = TRUE
        )
      )
    }
  })
  
  
  # Generate the output table
  output$table <- renderDataTable({out()},options = list(pageLength = 5))
  
  #-------------------------------------------------------------------------
  #
  #  Plot results ...
  #
  #-------------------------------------------------------------------------
  
  # Generate the plot of each variable as a function of time
  output$plot1 <- renderPlotly({
    
    parameters <- parameters()
    state <- state()
    times <- times()
    out <- out()
    
    X <- out[,"X"]
    Y <- out[,"Y"]
    Z <- out[,"Z"]
    
    p1 <- plot_ly(
      out, 
      x = ~time, 
      y = ~X, 
      name = 'X', 
      type = 'scatter',
      mode = 'lines') %>%
      add_lines(y = ~Y, name = 'Y') %>%
      add_lines(y = ~Z, name = 'Z')
    
  })
  
  
  # Generate the 3D plot correspondint to out
  output$plot2 <- renderPlotly({
    
    parameters <- parameters()
    state <- state()
    times <- times()
    out <- out()
    
    p2 <- plot_ly(
      out, 
      x = out[, "X"], 
      y = out[, "Y"], 
      z = out[, "Z"], 
      type = 'scatter3d', 
      mode = 'lines', 
      line = list(width = 4)) %>%
      add_markers(
        x = out[1, "X"], 
        y = out[1, "Y"], 
        z = out[1, "Z"], 
        name = '(X0,YO,Z0)') %>% # initial position
      add_markers(
        x = sqrt(input$b*(input$c - 1)), 
        y = sqrt(input$b*(input$c - 1)), 
        z = input$c - 1, 
        marker = list(color = "#000000"), 
        name = "Non trivial Eq1") %>% # other steady state
      add_markers(
        x = -sqrt(input$b*(input$c - 1)), 
        y = -sqrt(input$b*(input$c - 1)), 
        z = input$c - 1, 
        marker = list(color = "#000000"), 
        name = "Non trivial Eq2") # other steady state
    
  }) 
  
  # plot phase plan projection as a function of 2 selected values by the user
  
  
  output$plot3 <- renderPlotly({
    
    parameters <- parameters()
    state <- state()
    times <- times()
    out <- out()
    
    xvar <- list(title = input$xvar[[1]])
    yvar <- list(title = input$yvar[[1]])
    
    p3 <- plot_ly(
      out, 
      x = ~out[,input$xvar], 
      y = ~out[,input$yvar], 
      type = 'scatter', 
      mode = 'lines') %>%
      layout(xaxis = xvar , yaxis = yvar)
    
  })
  
  
  #-------------------------------------------------------------------------
  #
  #  Useful tasks such as save, reset, load ...
  #
  #-------------------------------------------------------------------------
  
  # Give the possibility to download the table
  output$downloadData <- downloadHandler(
    filename = function() {
      paste0("out()-", Sys.Date(), ".csv")
    },
    content = function(file) {
      write.csv(out(), file)
    })
  
  # reset all the values of box inputs
  observeEvent(input$resetAll, {
    shinyjs::reset("sidebar_main")
    shinyjs::reset("sidebar_bis")
  })
  
  # save and load a session
  observeEvent(input$save, {
    values <<- lapply(reactiveValuesToList(input), unclass)
  })
  
  observeEvent(input$load, {
    if (exists("values")) {
      lapply(names(values), function(x) {
        session$sendInputMessage(x, list(value = values[[x]]))
      }) 
    }
  })
  
  # When the button is clicked, wrap the code in a call to
  # `withBusyIndicatorServer()`
  observeEvent(input$save, {
    withBusyIndicatorServer("save", {
      Sys.sleep(1)
    })
  })
  
  observeEvent(input$load, {
    withBusyIndicatorServer("load", {
      Sys.sleep(1)
    })
  })
  
  #reset sliders individually
  rv <- reactiveValues(lastBtn = character())
  reset <- c("reset_a", "reset_b", "reset_c", "reset_atol", "reset_rtol")
  lapply(seq_along(reset), FUN = function(i) {
    observeEvent(input[[reset[[i]]]], {
      if (input[[reset[[i]]]] > 0) {
        rv$lastBtn <- paste(reset[[i]])
        slider_name <- unlist(str_split(rv$lastBtn, "reset_"))[[2]]
        shinyjs::reset(slider_name)
      }
    }, ignoreInit = TRUE)
  })
  
  
  # Set this to "force" instead of TRUE for testing locally (without Shiny Server)
  # Only works with shiny server > 1.4.7
  session$allowReconnect(TRUE)
  
})