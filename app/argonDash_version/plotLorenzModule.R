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
      
      tagList(
        shiny::h1(shiny::icon("area-chart"), "Outputs"),
        argonTabSet(
          id = "tabPlot",
          card_wrapper = TRUE,
          horizontal = TRUE,
          circle = FALSE,
          size = "sm",
          width = 12,
          argonTab(
            tabName = "Graph 3D", 
            active = TRUE,
            withSpinner(
              plotlyOutput(ns("plot3D"), height = 500), 
              size = 2, 
              type = 8, 
              color = "#000000"
            )
          ),
          argonTab(
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
          argonTab(
            tabName = "Time Series",
            withSpinner(
              plotlyOutput(ns("timeSerie"), height = 400), 
              size = 2, 
              type = 8, 
              color = "#000000"
            )
          )
        ),
        fluidRow(
          column(
            width = 6,
            align = "center",
            solverInputsUi(id = "solver_inputs")
          ),
          column(
            width = 6,
            align = "center",
            computeLorenzUi(id = "compute") 
          )
        )
      )
    } else {
      introBox(
        argonCard(
          title = shiny::h1(shiny::icon("area-chart"), "Outputs"), 
          src = NULL, 
          hover_lift = FALSE,
          shadow = TRUE, 
          shadow_size = "md", 
          hover_shadow = TRUE,
          border_level = 0, 
          icon = NULL, 
          status = "primary",
          background_color = NULL, 
          gradient = FALSE, 
          floating = FALSE,
          width = 12,
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
          ),
          hr(),
          fluidRow(
            column(
              width = 6,
              align = "center",
              solverInputsUi(id = "solver_inputs")
            ),
            column(
              width = 6,
              align = "center",
              computeLorenzUi(id = "compute") 
            )
          )
        ),
        data.step = 1,
        data.intro = help_text[1]
      )
    }
  })
  
}