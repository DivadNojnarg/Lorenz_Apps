plotLorenzUi <- function(id) {
  ns <- NS(id)
  uiOutput(ns("plotTabCard"))
}



plotLorenz <- function(input, output, session, mobile, datas, model_params, plot_params) {
  
  ns <- session$ns
  
  # Generate the plot of each variable as a function of time
  output$timeSerie <- renderPlotly({
    
    X <- datas()[, "X"]
    Y <- datas()[, "Y"]
    Z <- datas()[, "Z"]
    
    p1 <- plot_ly(
      datas(), 
      x = ~time, 
      y = ~X, 
      name = 'X', 
      type = 'scatter',
      mode = 'lines') %>%
      add_lines(y = ~Y, name = 'Y') %>%
      add_lines(y = ~Z, name = 'Z')
  })
  
  
  # Generate the 3D plot correspondint to out
  output$plot3D <- renderPlotly({
    
    eq1 <- c(
      sqrt(model_params()[["b"]] * (model_params()[["c"]] - 1)),
      sqrt(model_params()[["b"]] * (model_params()[["c"]] - 1)),
      model_params()[["c"]] - 1
    )
    
    eq2 <- c(-eq1[1], -eq1[2], model_params()[["c"]] - 1)
    
    p2 <- plot_ly(
      datas(), 
      x = datas()[, "X"], 
      y = datas()[, "Y"], 
      z = datas()[, "Z"], 
      type = 'scatter3d', 
      mode = 'lines', 
      line = list(width = 4)) %>%
      add_markers(
        x = datas()[1, "X"], 
        y = datas()[1, "Y"], 
        z = datas()[1, "Z"], 
        name = '(X0,Y0,Z0)') %>% # initial position
      add_markers(
        x = eq1[1], 
        y = eq1[2], 
        z = eq1[3], 
        marker = list(color = "#000000"), 
        name = "Non trivial Eq1") %>% # other steady state
      add_markers(
        x = eq2[1], 
        y = eq2[2], 
        z = eq2[3], 
        marker = list(color = "#000000"), 
        name = "Non trivial Eq2") %>% # other steady state
      layout(legend = list(orientation = 'h'))
    
  }) 
  
  # plot phase plan projection as a function of 2 selected values by the user
  output$phasePlane <- renderPlotly({
    
    xvar <- list(title = names(plot_params())[[1]])
    yvar <- list(title = names(plot_params())[[2]])
    
    p3 <- plot_ly(
      datas(), 
      x = ~datas()[, plot_params()[["xvar"]]], 
      y = ~datas()[, plot_params()[["yvar"]]], 
      type = 'scatter', 
      mode = 'lines') %>%
      layout(xaxis = xvar , yaxis = yvar)
  })
  
  
  # render the tab card containing all outputs
  # the content will depend on whether isMobile is TRUE
  output$plotTabCard <- renderUI({
    
    req(!is.null(mobile()))
    
    if (mobile()) {
      bs4TabCard(
        elevation = 4, 
        width = 12,
        side = "right",
        title = tagList(tagList(shiny::icon("area-chart"), "Outputs")),
        bs4TabPanel(
          tabName = "Graph 3D", 
          active = TRUE,
          withSpinner(
            plotlyOutput(ns("plot3D"), height = 500), 
            size = 2, 
            type = 8, 
            color = "#000000"
          )
        ),
        bs4TabPanel(
          tabName = "Phase Plane", 
          fluidRow(
            column(
              width = 12,
              align = "center",
              withSpinner(
                plotlyOutput(ns("phasePlane"), height = 400, width = "80%"), 
                size = 2, type = 8, color = "#000000"
              )
            )
          )
        ),
        bs4TabPanel(
          tabName = "Time Series",
          withSpinner(
            plotlyOutput(ns("timeSerie"), height = 400), 
            size = 2, 
            type = 8, 
            color = "#000000"
          )
        )
      )
    } else {
      introBox(
        bs4Card(
          elevation = 4, 
          closable = FALSE,
          width = 12,
          side = "right",
          title = tagList(tagList(shiny::icon("area-chart"), "Outputs")),
          fluidRow(
            column(
              width = 4,
              withSpinner(
                plotlyOutput(ns("plot3D"), height = 500), 
                size = 2, 
                type = 8, 
                color = "#000000"
              )
            ),
            column(
              width = 4,
              withSpinner(
                plotlyOutput(ns("phasePlane"), height = 400, width = "80%"), 
                size = 2, type = 8, color = "#000000"
              )
            ),
            column(
              width = 4,
              withSpinner(
                plotlyOutput(ns("timeSerie"), height = 400), 
                size = 2, 
                type = 8, 
                color = "#000000"
              )
            )
          )
        ),
        data.step = 1,
        data.intro = help_text[1]
      )
    }
  })
  
}