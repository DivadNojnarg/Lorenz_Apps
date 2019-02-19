# Server code
server <- function(input, output, session) {
  
  observe(print(input$isMobile))
  
  solver_params <- callModule(module = solverInputs, id = "solver_inputs")
  out <- callModule(module = computeLorenz, id = "compute", solver_params = solver_params)
  callModule(module = bifurcations, id = "bifurc", model_params = out$model_params)
  callModule(module = stability, id = "stability", model_params = out$model_params)
  callModule(module = dataTable, id = "datatable", datas = out$res)
  
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
       name = '(X0,Y0,Z0)') %>% # initial position
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
       name = "Non trivial Eq2") %>% # other steady state
      layout(legend = list(orientation = 'h'))
    
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
  
  # reset all the values of the right sidebar
  observeEvent(input$resetAll, {
    reset("controlbar")
    reset("3d_plot")
    reset("phase_plot")
  })
  
  # save input parameters into the global values
  observeEvent(input$save, {
    values <<- lapply(reactiveValuesToList(input), unclass)
  })
  
  # restore inputs when click on load
  observeEvent(input$load, {
    if (exists("values")) {
      lapply(names(values), function(x) {
        session$sendInputMessage(x, list(value = values[[x]]))
      }) 
    }
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
  
  # deleted dlls on stop 
  session$onSessionEnded(function() {
    if (.Platform$OS.type == "unix") {
      file.remove("Lorenz.o")
      file.remove("Lorenz.so")
    } else if (.Platform$OS.type == "windows") {
      file.remove("Lorenz.dll")
    }
  })
  
  # Set this to "force" instead of TRUE for testing locally (without Shiny Server)
  # Only works with shiny server > 1.4.7
  session$allowReconnect(TRUE)
  
}