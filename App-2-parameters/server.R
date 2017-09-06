library(shiny)
library(plotly)
library(deSolve)

# Define the model equations

Lorenz <- function(t, state, parameters) {
  with(as.list(c(state, parameters)),{
    dX <- a*(Y-X)
    dY <- X*(c-Z) - Y
    dZ <- X*Y - b*Z
    list(c(dX, dY, dZ))
  })
}

shinyServer(function(input, output, session) {
  
  # store reactives values
  
  parameters <- reactive({c("a" = input$a,"b" = input$b,"c" = input$c)})
  state <- reactive({c("X" = input$X0,"Y" = input$Y0,"Z" = input$Z0)})
  times <- reactive({seq(0,input$tmax, by = input$dt)})

  # integrate the Lorenz ode model with reactive inputs, solver is selected by the user
  
  out <- reactive({
    
    parameters <- parameters()
    state <- state()
    times <- times()
  
    as.data.frame(ode(y = state, times = times, 
                      func = Lorenz, parms = parameters,
                      method = input$solver, rtol = input$rtol, atol = input$atol))
    
  })
  
  
  # Generate the output table
  
  output$table <- renderDataTable({out()},options = list(pageLength = 5))
  
  # Generate the plot of each variable as a function of time
  
  output$plot1 <-renderPlotly({

    parameters <- parameters()
    state <- state()
    times <- times()
    out <- out()
    
    X <- out[,"X"]
    Y <-out[,"Y"]
    Z <- out[,"Z"]
    
    p1 <- plot_ly(out, x = ~time, y = ~X, name = 'X', type = 'scatter', mode = 'lines') %>%
      add_lines(y = ~Y, name = 'Y') %>%
      add_lines(y = ~Z, name = 'Z')
    
  })
  
  
  # Generate the 3D plot correspondint to out
  
  output$plot2<- renderPlotly({
    
      parameters <- parameters()
      state <- state()
      times <- times()
      out <- out()
      
      p2 <- plot_ly(out, x = out[, "X"], y = out[, "Y"], z = out[, "Z"], type = 'scatter3d', mode = 'lines',
                    line = list(width = 4)) %>%
        add_markers(x = out[1, "X"], y = out[1, "Y"], z = out[1, "Z"], name = '(X0,YO,Z0)') %>% # initial position
        add_markers(x = sqrt(input$b*(input$c-1)), y = sqrt(input$b*(input$c-1)), 
                    z = input$c-1, marker = list(color = "#000000"), name = "Non trivial Eq1") %>% # other steady state
        add_markers(x = -sqrt(input$b*(input$c-1)), y = -sqrt(input$b*(input$c-1)), 
                    z = input$c-1, marker = list(color = "#000000"), name = "Non trivial Eq2") # other steady state
      
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
    
    p3 <- plot_ly(out, x = ~out[,input$xvar], y = ~out[,input$yvar], type = 'scatter', mode = 'lines') %>%
      layout(xaxis = xvar , yaxis = yvar)
           
  })
  
  # Give the possibility to download the table
  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("out()-", Sys.Date(), ".csv", sep="")
    },
    content = function(file) {
      write.csv(out(), file)
    })
  
  # reset all the values of box inputs
  
  observeEvent(input$resetAll, {
    reset("boxinput")
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
  
  # close the App with the button
  
  observeEvent(input$close, {
    js$closeWindow()
    stopApp()
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
  
  # Footer info boxes
  
  output$sourceBox <- renderInfoBox({
    infoBox(title = "Source", value = "Lorenz, Journal of the Atmospheric Sciences,20: 1963", 
            color = "blue", icon = icon("tachometer"))
  })
  
  output$progressBox <- renderInfoBox({
    infoBox(title = "Progress", value = tags$ol(tags$li("Save and load buttons were bugged"),
                                                tags$li("Change Theme: Yeti")), color = "blue", icon = icon("list"))
  })
  
  output$nameBox <- renderInfoBox({
    infoBox(title = paste("D. Granjon:", Sys.time()), value = "Version: 0.3", 
            color = "blue", icon = icon("code"))
  })
  
  
  # Hopf bifurcation or not? 
  
  output$hopf <- renderInfoBox({
    
    if(input$c < input$a*(input$a+input$b+3)/(input$a-input$b-1)){
       r1 <- paste(input$c,"<", input$a*(input$a+input$b+3)/(input$a-input$b-1), 
            ": no Hopf-bifurcation expected")
    }
    else{r1 <- paste(input$c,">", input$a*(input$a+input$b+3)/(input$a-input$b-1), 
               ": Hopf-bifurcation expected")}
    infoBox(
      "Hopf Bifurcation?", r1, icon = icon("thumbs-up", lib = "glyphicon"),
      color = "blue",  fill = TRUE
    )
    
  })
  
  output$pitchfork <- renderInfoBox({
    if(0 < input$c && input$c <= 1){
      r2 <- paste(0, "=<", input$c,"=<", 1, 
                 ": (0,0,0) is the only one equilibrium point")
    }
    else{r2 <- paste(input$c,">", 1, 
                    ": 3 equilibrium points expected ,(0,0,0) is unstable")}
    
    infoBox("Pitchfork Bifurcation?", r2, icon = icon("thumbs-up", lib = "glyphicon"), color = "blue",
             href = NULL, fill = TRUE)
    
  })

  
  
  session$onSessionEnded(stopApp)  # stop shiny app when the web-window is closed
  
})