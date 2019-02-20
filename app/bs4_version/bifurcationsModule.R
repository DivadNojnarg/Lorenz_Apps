bifurcationsUi <- function(id) {
  ns <- NS(id)
  fluidRow(
    bs4InfoBoxOutput(ns("hopf"), width = 6),
    bs4InfoBoxOutput(ns("pitchfork"), width = 6) 
  )
}


bifurcations <- function(input, output, session, model_params, printInfos) {
  # Hopf bifurcation or not? 
  output$hopf <- renderbs4InfoBox({
    
    req(printInfos())
    
    no_hopf <- "model_params()[['c']] < model_params()[['a']] * (model_params()[['a']] + model_params()[['b']] + 3) / 
    (model_params()[['a']] - model_params()[['b']] - 1)"
    no_hopf <- eval(parse(text = no_hopf))
    
    res <- round(model_params()[['a']] * (model_params()[['a']] + model_params()[['b']] + 3) / 
                   (model_params()[['a']] - model_params()[['b']] - 1))
    
    if (no_hopf) {
      r1 <- paste(model_params()[['c']], "<", res, ": no Hopf-bifurcation")
    } else {
      r1 <- paste(model_params()[['c']], ">", res, ": Hopf-bifurcation")
    }
    
    bs4InfoBox(
      title = "Hopf Bifurcation?", 
      value = r1, 
      icon = "thumbs-up",
      status = "danger",  
      iconElevation = 4
    )
    
  })
  
  # pitchfork bifurcation or not?
  output$pitchfork <- renderbs4InfoBox({
    
    req(printInfos())
    
    if (0 < model_params()[['c']] && model_params()[['c']] <= 1) {
      r2 <- paste(0, "=<", model_params()[['c']], "=<", 1, ": (0,0,0) is the only one equilibrium")
    } else {
      r2 <- paste(model_params()[['c']], ">", 1, ": 3 equilibrium, (0,0,0) is unstable")
    }
    
    bs4InfoBox(
      title = "Pitchfork Bifurcation?", 
      value = r2, 
      icon = "thumbs-up", 
      status = "danger",
      iconElevation = 4
    )
    
  })
}