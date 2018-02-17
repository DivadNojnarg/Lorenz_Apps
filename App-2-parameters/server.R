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
  output$hopf <- renderInfoBox({
    
    if (input$c < input$a*(input$a + input$b + 3)/(input$a - input$b - 1)) {
      r1 <- paste(input$c,"<", round(input$a*(input$a + input$b + 3) / 
                                       (input$a - input$b - 1)), 
                  ": no Hopf-bifurcation expected")
    } else {
      r1 <- paste(input$c,">", round(input$a*(input$a + input$b + 3) / 
                                       (input$a - input$b - 1)), 
                     ": Hopf-bifurcation expected")
      }
    infoBox(
      "Hopf Bifurcation?", r1, icon = icon("thumbs-up", lib = "glyphicon"),
      color = "blue",  fill = TRUE
    )
    
  })
  
  output$pitchfork <- renderInfoBox({
    if (0 < input$c && input$c <= 1) {
      r2 <- paste(0, "=<", input$c,"=<", 1, 
                  ": (0,0,0) is the only one equilibrium point")
    } else {
      r2 <- paste(input$c,">", 1, ": 3 equilibrium points expected ,(0,0,0) is unstable")
      }
    
    infoBox("Pitchfork Bifurcation?", 
            r2, 
            icon = icon("thumbs-up", lib = "glyphicon"), 
            color = "blue",
            href = NULL, fill = TRUE)
    
  })
  

  # integrate the Lorenz ode model with reactive inputs, solver is selected by the user
  out <- reactive({
    
    parameters <- parameters()
    state <- state()
    times <- times()
  
    if (input$compile == "deSolve") {
      as.data.frame(
        ode(y = state, times = times, func = Lorenz, parms = parameters, 
            method = input$solver, rtol = input$rtol, atol = input$atol)
      )
    } else {
      ev1$add.sampling(times)
      as.data.frame(
        mod1$solve(params = parameters, events = ev1, inits = state, stiff = TRUE)
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
    
    p1 <- plot_ly(out, x = ~time, y = ~X, name = 'X', 
                  type = 'scatter', mode = 'lines') %>%
      add_lines(y = ~Y, name = 'Y') %>%
      add_lines(y = ~Z, name = 'Z')
    
  })
  
  
  # Generate the 3D plot correspondint to out
  output$plot2 <- renderPlotly({
    
      parameters <- parameters()
      state <- state()
      times <- times()
      out <- out()
      
      p2 <- plot_ly(out, x = out[, "X"], y = out[, "Y"], z = out[, "Z"], 
                    type = 'scatter3d', mode = 'lines', line = list(width = 4)) %>%
        add_markers(x = out[1, "X"], y = out[1, "Y"], 
                    z = out[1, "Z"], name = '(X0,YO,Z0)') %>% # initial position
        add_markers(x = sqrt(input$b*(input$c - 1)), y = sqrt(input$b*(input$c - 1)), 
                    z = input$c - 1, marker = list(color = "#000000"), 
                    name = "Non trivial Eq1") %>% # other steady state
        add_markers(x = -sqrt(input$b*(input$c - 1)), y = -sqrt(input$b*(input$c - 1)), 
                    z = input$c - 1, marker = list(color = "#000000"), 
                    name = "Non trivial Eq2") # other steady state
      
  }) 
  
  # plot phase plan projection as a function of 2 selected values by the user
  
  
  output$plot3 <- renderPlotly({
    
    parameters <- parameters()
    state <- state()
    times <- times()
    out <- out()
    
    xvar <- list(
      title = input$xvar[[1]]
    )
    yvar <- list(
      title = input$yvar[[1]]
    )
    
    p3 <- plot_ly(out, x = ~out[,input$xvar], y = ~out[,input$yvar], 
                  type = 'scatter', mode = 'lines') %>%
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
      lapply(names(values), function(x) session$sendInputMessage(x, 
                                                                 list(value = values[[x]])))
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