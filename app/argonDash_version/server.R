# Server code
server <- function(input, output, session) {
  
  # check whether we are on mobile or desktop/laptop
  isMobile <- reactive(input$isMobile)
  
  solver_params <- callModule(module = solverInputs, id = "solver_inputs")
  out <- callModule(module = computeLorenz, id = "compute", solver_params = solver_params)
  callModule(module = bifurcations, id = "bifurc", model_params = out$model_params, printInfos = out$print_infos)
  callModule(module = stability, id = "stability", model_params = out$model_params, printInfos = out$print_infos)
  callModule(module = dataTable, id = "datatable", datas = out$res)
  callModule(module = utils, id = "utils")
  callModule(
    module = plotLorenz, 
    id = "plot", 
    mobile = isMobile, 
    datas = out$res, 
    model_params = out$model_params,
    plot_params = out$plot_params
  )
  
  callModule(module = aboutLorenz, id = "about")
  callModule(module = helpLorenz, id = "help")
  
  #-------------------------------------------------------------------------
  #
  #  Useful tasks such as save, reset, load ...
  #
  #-------------------------------------------------------------------------
  
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