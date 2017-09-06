library(shiny)
library(deSolve)
library(rgl)
library(scatterplot3d)
library(plotly)
library(shinyAce)
library(compiler)
library(FME)

state <- c(X = 1,
           Y = 1,
           Z = 1)

times <- seq(0,100, by = 0.01)

shinyServer(function(input, output, session) {
  
  parameters <- reactive({c("a" = input$a,"b" = input$b,"c" = input$c)}) # use isolate() to prevent reactivity
  
  # Changing the system to integrate, cf radiobuttons
  
  # model <- reactive({
  #   switch(input$modelChoice,
  #          default = Lorenz.cmpf,
  #          Lorenz2 = Lorenz_1.cmpf,
  #          Lorenz2 = Lorenz_2.cmpf)
  # })
  
  # output$model<- renderPrint({model()})
  
  model <- eventReactive(input$modelchoice,{
    if(input$modelchoice == 1){
      
      source('Lorenz.R')
      Lorenz.cmpf <- cmpfun(Lorenz) # compile the source function, otherwise it does not work!!!
      
    } else if(input$modelchoice == 2){
      
      source('Modified_Lorenz_1.R')
      Lorenz_1.cmpf <- cmpfun(Modified_Lorenz_1)
      
    }else{
      
      source('Modified_Lorenz_2.R')
      Lorenz_2.cmpf <- cmpfun(Modified_Lorenz_2)
    }
  })
  
  # Change the solver to integrate: lsode is the default solver
  
  solver <- reactive({
    switch(input$solverChoice,
           default = lsode,
           Radau = radau,
           ODE23 = ode23,
           ODE45 = ode45,
           Adams = adams,
           bdf = bdf)
  })
  
  # integrate the Lorenz ode model with reactive inputs
  
  out <- eventReactive(input$go,{
    parameters <- parameters() # reactive objects are called like function: object()...
    solver <- solver()
    model <- model()
    as.data.frame(ode(y = state, times = times, 
                      func = model, parms = parameters, method = solver))
    
  })
 
  
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
  
  plot1 <- eventReactive(input$go,{
    parameters <- parameters()
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
  
  plot2<- eventReactive(input$go,{
    parameters <- parameters()
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
      add_markers(x = X_1, y = Y_1, z = Z_1, name = 'X0/Y0/Z0', marker = list(color = "#fcae1e")) %>% # initial position
      add_markers(x = 0, y = 0, z = 0, name = 'X0/Y0/Z0', marker = list(color = "#000000")) %>% # (0,0,0) steady state
      add_markers(x = sqrt(input$b*(input$c-1)), y = sqrt(input$b*(input$c-1)), 
                  z = input$c-1, name = 'X0/Y0/Z0', marker = list(color = "#000000")) %>% # other steady state
      add_markers(x = -sqrt(input$b*(input$c-1)), y = -sqrt(input$b*(input$c-1)), 
                  z = input$c-1, name = 'X0/Y0/Z0', marker = list(color = "#000000")) # other steady state
    
    a <- list(title = "AXIS TITLE")
      
    p <- subplot(p1,p2,p3,p4, nrows = 2, titleX = TRUE, titleY = TRUE) %>%
       layout(title = "",
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
  
  
  # Hopf Birfurcation
  
  hopf <- reactive({
    if(input$c < input$a*(input$a+input$b+3)/(input$a-input$b-1)){
      paste(input$c,"is lower than", input$a*(input$a+input$b+3)/(input$a-input$b-1), 
            "No Hopf-bifurcation expected")
    }
    else{paste(input$c,"is higher than", input$a*(input$a+input$b+3)/(input$a-input$b-1), 
               "Hopf-bifurcation is expected")}
    })
  
  output$hopf <- renderText({hopf()})

  
  # save and load a session of panel 1
  
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
  
  # reset all the values of panel 1 
  
  observeEvent(input$resetAll, {
    reset("input1")
  })
  
  # close id boxclose
  
  observeEvent(input$close, {
    hide("boxclose")
    # toggle("plot") if you want to alternate between hiding and showing
  })
  
  # Computation Statistics 
  
  elapsed_integrating <- reactive({
    elapsed_all <- system.time(out()[3])
    paste("Integration time:",elapsed_all[1])
  })
  
  output$elapsed_integrating <- renderText({elapsed_integrating()})
  
  
  # Sensitivity analysis
  
  parRanges <- reactiveValues()
  parRanges$df <- data.frame()
  
  observeEvent(input$gosensitivity,{
    
    minpar <- c(input$sliderrange1[1],input$sliderrange2[1],input$sliderrange3[1])
    maxpar <- c(input$sliderrange1[2],input$sliderrange2[2],input$sliderrange3[2])
    parRanges$df <- data.frame(minpar, maxpar)
    rownames(parRanges$df) <- c("a","b","c")
    
  })
  
  output$paramRanges <- renderTable({parRanges$df})
  
  numrun <- reactive({input$modelrun})
  
  summ.sR1 <- eventReactive(input$gosensitivity,{
    
    parameters <- parameters()
    numrun <- numrun()
    
    solvelorenz <- function (parameters){
      Lorenz<-function(t, state, parameters) {
        with(as.list(c(state, parameters)),{
          # rate of change
          dX<-a*(Y-X)
          dY<-X*(c-Z) - Y
          dZ<- X*Y - b*Z
          # return the rate of change
          list(c(dX, dY, dZ))
        })
      }
      state <- c(X=1, Y=1, Z=1)
      times <- seq(0,100, by = 0.01)
      return(as.data.frame(ode(y=state, times=times, func=Lorenz, parms = parameters)))
    }
    
    sens1 <- sensRange(func=solvelorenz, parms = parameters, dist="grid", sensvar = c("X","Y","Z"),
                       parRange = parRanges$df[1,], num = numrun)
    
    summ.sens1 <- summary(sens1)

  })

  output$sR1 <- renderDataTable({head(summ.sR1())})
  
  
  sens1plot <- eventReactive(input$gosensitivity,{
    
    summ.sR1 <- summ.sR1()
    par(mfrow=c(1,3))
    sens1plot <- plot(summ.sR1, xlab="time", ylab="", legpos="topright", mfrow=NULL)
    mtext(outer = TRUE, line = -1.5, side = 3, "Sensitivity to a", cex= 1.25)
  
    })
  
  output$sens1plot <- renderPlot({sens1plot()})
  
  summ.sR2 <- eventReactive(input$gosensitivity,{
    
    parameters <- parameters()
    numrun <- numrun()
    
    solvelorenz <- function (parameters){
      Lorenz<-function(t, state, parameters) {
        with(as.list(c(state, parameters)),{
          # rate of change
          dX<-a*(Y-X)
          dY<-X*(c-Z) - Y
          dZ<- X*Y - b*Z
          # return the rate of change
          list(c(dX, dY, dZ))
        })
      }
      state <- c(X=1, Y=1, Z=1)
      times <- seq(0,100, by = 0.01)
      return(as.data.frame(ode(y=state, times=times, func=Lorenz, parms = parameters)))
    }
    
    sens2 <- sensRange(func=solvelorenz, parms = parameters, dist="latin", sensvar = c("X","Y","Z"),
                       parRange = parRanges$df, num = numrun) # sensitivity for combination of parameters
    
    summ.sens2 <- summary(sens2)
    
  })
  
  output$sR2 <- renderDataTable({head(summ.sR2())})
  
  sens2plot <- eventReactive(input$gosensitivity,{
    
    summ.sR2 <- summ.sR2()
    par(mfrow=c(1,3))
    sens2plot <- plot(summ.sR2, main ="Sensitivity to a,b and c", xlab="time", ylab="", legpos="topright", mfrow=NULL)
    
  })
  
  output$sens2plot <- renderPlot({sens2plot()})
  
  #################### local sensitivity
  
  SnsLorenz <- eventReactive(input$gosensitivity,{
    
    parameters <- parameters()
    
    solvelorenz <- function (parameters){
      Lorenz<-function(t, state, parameters) {
        with(as.list(c(state, parameters)),{
          # rate of change
          dX<-a*(Y-X)
          dY<-X*(c-Z) - Y
          dZ<- X*Y - b*Z
          # return the rate of change
          list(c(dX, dY, dZ))
        })
      }
      state <- c(X=1, Y=1, Z=1)
      times <- seq(0,100, by = 0.01)
      return(as.data.frame(ode(y=state, times=times, func=Lorenz, parms = parameters)))
    }
    
    sns <- sensFun(func=solvelorenz, parms = parameters, varscale = 1) # local sensitivity of X
    
  })
  
  output$SnsLorenz <- renderDataTable({summary(SnsLorenz(), var=TRUE)})
  
  Snsplot <- eventReactive(input$gosensitivity,{
    
    SnsLorenz <- SnsLorenz()
    #par(mfrow=c(1,3))
    sns2plot <- plot(SnsLorenz)
    
  })
  
  output$Snsplot <- renderPlot({Snsplot()})
  
  Snspairs <- eventReactive(input$gosensitivity,{
    
    SnsLorenz <- SnsLorenz()
    #par(mfrow=c(1,3))
    sns2pairs <- pairs(SnsLorenz)
    
  })
  
  output$Snspairs <- renderPlot({Snspairs()})
  
  # Monte Carlo simulation
  
  SFMC <- eventReactive(input$gosensitivity,{
    
    parameters <- parameters()
    
    solvelorenz <- function (parameters){
      Lorenz<-function(t, state, parameters) {
        with(as.list(c(state, parameters)),{
          # rate of change
          dX<-a*(Y-X)
          dY<-X*(c-Z) - Y
          dZ<- X*Y - b*Z
          # return the rate of change
          list(c(dX, dY, dZ))
        })
      }
      state <- c(X=1, Y=1, Z=1)
      times <- seq(0,100, by = 0.01)
      return(as.data.frame(ode(y=state, times=times, func=Lorenz, parms = parameters)))
    }
    
    SF <- function (parameters) {
      out <- solvelorenz(parameters)
      return(out[nrow(out), 2:4])
    }
    
    CRL <- modCRL(func = SF, parms = parameters, parRange = parRanges$df[1,])
    
  })
  
  SFMCplot <- eventReactive(input$gosensitivity,{
    
    SFMC <- SFMC()
    #par(mfrow=c(1,3))
    sfmcplot <- plot(SFMC)
    
  })
  
  output$SFMCplot <- renderPlot({SFMCplot()})
  
  # Multivariate sensitivity analysis
  
  Coll <- eventReactive(input$gosensitivity,{
    
    parameters <- parameters()
    
    solvelorenz <- function (parameters){
      Lorenz<-function(t, state, parameters) {
        with(as.list(c(state, parameters)),{
          # rate of change
          dX<-a*(Y-X)
          dY<-X*(c-Z) - Y
          dZ<- X*Y - b*Z
          # return the rate of change
          list(c(dX, dY, dZ))
        })
      }
      state <- c(X=1, Y=1, Z=1)
      times <- seq(0,100, by = 0.01)
      return(as.data.frame(ode(y=state, times=times, func=Lorenz, parms = parameters)))
    }
    
    sns <- sensFun(func=solvelorenz, parms = parameters, varscale = 1) # local sensitivity of X
    coll <- collin(sns)
    
  })
  
  output$Coll <- renderDataTable({Coll()})
  
  # save and load a session of panel 2
  
  observeEvent(input$save2, {
    values <<- lapply(reactiveValuesToList(input), unclass)
  })
  
  observeEvent(input$load2, {
    if (exists("values")) {
      lapply(names(values),
             function(x) session$sendInputMessage(x, list(value = values[[x]]))
      )
    }
  })
  
  # reset all the values of panel 2 
  
  observeEvent(input$resetAll2, {
    reset("input2")
  })
  
  
  # ########################## #
  #                            #
  #  FEATURES WORK IN PROGRESS #
  #                            #
  # ########################## #
  
  
  # Uploading a new version of Lorenz model .... DOESN'T WORK FOR THE MOMENT

  output$contents <- renderPrint({
    
    inFile <- input$modelfile
    
    if (is.null(inFile))
      return(NULL)
    
    load(file='inFile')
  })
  
  
    
#       if (is.null(inFile))
#         return(NULL)
#       
#       source('inFile.r', local = T)
#       Lorenz.cmpf <- cmpfun(inFile) # compile the source function, otherwise it does not work!!!
#       as.data.frame(ode(y = state, times = times, 
#                         func = Lorenz.cmpf(), parms = parameters, method = solver))
#       
#     })
# 
# output$out_upload <- renderDataTable({out_upload()})
  
  

  
  
  # ########################## #
  #                            #
  #       BONUS FEATURES       #
  #                            #
  # ########################## #
  
  
  # # Webpage view counter
  # 
  # output$counter <- 
  #   
  #   renderText({
  #     
  #     if (!file.exists("counter.Rdata")) 
  #       
  #       counter <- 0
  #     
  #     else
  #       
  #       load(file="counter.Rdata")
  #     
  #     counter  <- counter + 1
  #     
  #     save(counter, file="counter.Rdata")     
  #     
  #     paste("Hits: ", counter)
  #     
  #   })
  
  
  
  
  # # Hide or show plot2
  # observeEvent(input$hideshow, {
  #   toggle("plot2")
  # })
  # 
  # # Hide or show table
  # observeEvent(input$hideshow2, {
  #   toggle("table")
  # })
  
  
  
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
  
  # Update button tweaks
  
  # observeEvent(input$go, {
  #   
  #   # When the button is clicked, wrap the code in a call to `withBusyIndicatorServer()`
  #   
  #   withBusyIndicatorServer("go", {
  #     
  #     Sys.sleep(1)
  #     
  #   })
  #   
  # })
  
})