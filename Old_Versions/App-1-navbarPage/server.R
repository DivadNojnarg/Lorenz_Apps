library(shiny)
library(deSolve)
library(rgl)
library(scatterplot3d)
library(plotly)

# Define the model equations

Lorenz<-function(t, state, parameters) {
  with(as.list(c(state, parameters)),{
    # rate of change
    dX<-a*X+Y*Z
    dY<-b*(Y-Z)
    dZ<--X*Y+c*Y-Z
    # return the rate of change
    list(c(dX, dY, dZ))
  }) # end with(as.list ... +}
}

shinyServer(function(input, output, session) {
  
  parameters <- reactive({c("a" = input$a,"b" = input$b,"c" = input$c)}) # use isolate() to prevent reactivity
  state <- reactive({c("X" = input$X0,"Y" = input$Y0,"Z" = input$Z0)})
  times <- reactive({seq(0,input$tmax, by = 0.01)})
  
  # integrate the Lorenz ode model with reactive inputs
  
  out <- eventReactive(input$go,{
    parameters <- parameters() # reactive objects are called like function: object()...
    state <- state()
    times <- times()
    as.data.frame(ode(y = state, times = times, 
                      func = Lorenz, parms = parameters))
    
  }) # eventReactive prevents plot from updating without clicking on the update button
  
  # Generate the output table
  
  output$table <- renderDataTable({out()},options = list(pageLength = 5,paging = TRUE,dom = 'simple'))
  
  # Give the possibility to download the table
  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("out()-", Sys.Date(), ".csv", sep="")
    },
    content = function(file) {
      write.csv(out(), file)
  })
  
  # Generate the time serie plot
  
  plot1 <- reactive({
    parameters <- parameters()
    state <- state()
    times <- times()
    out <- out()
    
    X <- out[,"X"]
    Y <-out[,"Y"]
    Z <- out[,"Z"]
    
    p1<-plot_ly(out, x = ~time, y = ~X, name = 'X', type = 'scatter', mode = 'lines') %>%
      add_lines(y = ~Y, name = 'Y') %>%
      add_lines(y = ~Z, name = 'Z')
    
  })
  
  output$plot1 <-renderPlotly({plot1()})
  
  # Generate the 3D plot corresponding to out
  
  plot2<- reactive({
    parameters <- parameters()
    state <- state()
    times <- times()
    out <- out()
    
    X <- out[,"X"]
    Y <-out[,"Y"]
    Z <- out[,"Z"]
    
    X_1 <- out[1,"X"]
    Y_1 <-out[1,"Y"]
    Z_1 <- out[1,"Z"]
    
    #plot3d(out[, "X"], out[, "Y"], out[, "Z"], pch = ".")
    #scatterplot3d(out[, "X"], out[, "Y"], out[, "Z"], pch = ".")

    p1<-plot_ly(out, x = ~X, y = ~Y, name = 'X vs Y',
                type = 'scatter', mode = 'lines', line = list(color = "#5E88FC"))
    
    p2<-plot_ly(out, x = X, y = Z, name = 'X vs Z',
                type = 'scatter', mode = 'lines', line = list(color = "#fc5e5e")) 
    
    p3<-plot_ly(out, x = Y, y = Z, name = 'Y vs Z',
                type = 'scatter', mode = 'lines', line = list(color = "#5ac425")) 
    
    p4<-plot_ly(out, x = X, y = Y, z = Z, type = 'scatter3d', name = 'Trajectories', mode = 'lines',
                 line = list(width = 4), scene='scene1', line = list(color = "#256fc4")) %>%
      add_markers(x = X_1, y = Y_1, z = Z_1, name = 'X0/Y0/Z0', marker = list(color = "#fcae1e")) # initial position 
    
    a <- list(title = "AXIS TITLE")
      
    p <- subplot(p1,p2,p3,p4, nrows = 2, titleX = TRUE, titleY = TRUE) %>%
       layout(title = "Phase plan graphs",
              xaxis = list(xaxis = a,
                           yaxis = a),
              xaxis2 = list(xaxis = axis,
                            yaxis = axis),
              xaxis3 = list(xaxis = axis,
                            yaxis = axis),
              scene = list(xaxis = axis,
                           yaxis = axis,
                           zaxis = axis,
                           domain=list(x=c(0.5,1),y=c(0,0.5))),
              showlegend=FALSE,showlegend2=FALSE)
    
  })
  
  #output$plot2<- renderPlot({plot2()})
  output$plot2<- renderPlotly({plot2()}) # same as renderPlot but with plotly
  
  # Hide or show plot2
  observeEvent(input$hideshow, {
    toggle("plot2")
  })
  
  # Hide or show table
  observeEvent(input$hideshow2, {
    toggle("table")
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
  
  # reset all the values
  
  observeEvent(input$resetAll, {
    reset("sidebar1")
  })
  
  # Hide or show sidebar on hover
  #onevent("mouseleave", "mainPanel1", show("sidebar1"))
  #onevent("mouseenter", "mainPanel1", hide("sidebar1"))
  
  # Download the plot without the Plotly donwloader
  # output$downloadGraph <- downloadHandler(
  #   filename = "ShinyPlot.png",
  #   content = function(file) {
  #     png(file)
  #     print(plot2())
  #     dev.off()
  #   })
  
})