library(shiny)
library(plotly)
library(Rcpp)
library(odeintr)

# Define the model equations with Rcpp

pars = c(a = 10, b = 3, c = 28) 
Lorenz.sys = ' dxdt[0] = a * (x[1] - x[0]); 
               dxdt[1] = c * x[0] - x[1] - x[0] * x[2]; 
               dxdt[2] = -b * x[2] + x[0] * x[1]; 
             ' # Lorenz.sys C++
cat(JacobianCpp(Lorenz.sys))
compile_implicit("lorenz", Lorenz.sys, pars, TRUE) 

shinyServer(function(input, output, session) {
  
  tmax <- reactive({input$tmax})
  dt <- reactive({input$dt})
  Smin <- reactive({input$Smin})
  Smax <- reactive({input$Smax})
  number_state <- reactive({input$n})
  
  state <- reactive({
    
    state_0 <- t(replicate(number_state(), sample(Smin():Smax(),size=3), simplify="array"))
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
    selectInput("initcondselected", "Choose initial condition:", 
                choices=seq(1:input$n))
  })
  
  # Generate the plot correspondint to out
  
  plot1 <- eventReactive(input$initcondselected,{
    out <- out()
    p1 <- plot(out[out$x == input$initcondselected,-5], upper.panel = NULL) # pair plot of the first initial condition
  })
  
  plot2<- reactive({
    
    out <- out()
    
    p2 <- plot_ly(out, x = out[, 2], y = out[, 3],
                  z = out[, 4], split = ~x, type = 'scatter3d', mode = 'lines', # use split to filter when x=1, x=2, x=10 ...
                  line = list(width = 4))
    #  add_markers(p2, x = out[1, 2], y = out[1, 3], z = out[1, 4]) # initial position
    
  })
  
  output$plot1<- renderPlot({plot1()})
  output$plot2<- renderPlotly({plot2()})
  
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
      lapply(names(values),
             function(x) session$sendInputMessage(x, list(value = values[[x]]))
      )
    }
  })
  
  # close the App with the button
  
  observeEvent(input$close, {
    js$closeWindow()
    stopApp()
  })
  
  
  # When the button is clicked, wrap the code in a call to `withBusyIndicatorServer()`
  
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
    infoBox(
      title = "Source",
      value = "Lorenz, Journal of the Atmospheric Sciences,20: 1963",
      color = "blue",
      icon = icon("tachometer")
    )
  })
  
  output$progressBox <- renderInfoBox({
    infoBox(
      title = "Progress", 
      value = tags$ol(tags$li("Save and load buttons were bugged"),
                      tags$li("Change Theme: Yeti")),
      color = "blue",
      icon = icon("list")  
    )
  })
  
  output$nameBox <- renderInfoBox({
    infoBox(
      title = paste("D. Granjon:", Sys.time()),
      value = "Version: 0.3",
      color = "blue",
      icon = icon("code")
    )
  })
  
  
  session$onSessionEnded(stopApp) # stop shiny app when the web-window is closed
  
})