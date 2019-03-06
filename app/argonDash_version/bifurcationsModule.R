bifurcationsUi <- function(id) {
  ns <- NS(id)
  
  introBox(
    fluidRow(
      uiOutput(ns("hopf"), width = 6),
      uiOutput(ns("pitchfork"), width = 6) 
    ),
    data.step = 5,
    data.intro = help_text[5]
  )
}


bifurcations <- function(input, output, session, model_params, printInfos) {
  # Hopf bifurcation or not? 
  output$hopf <- renderUI({
    
    req(!is.null(printInfos()), !is.null(model_params()))
    
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
    
    argonInfoCard(
      title = "Hopf Bifurcation?", 
      value = r1, 
      icon = "thumbs-up",
      shadow = TRUE,
      gradient = TRUE,
      background_color = if (no_hopf) "red" else "green",
      width = 12
    )
    
  })
  
  # pitchfork bifurcation or not?
  output$pitchfork <- renderUI({
    
    req(!is.null(printInfos()), !is.null(model_params()))
    
    if (0 < model_params()[['c']] && model_params()[['c']] <= 1) {
      r2 <- paste(0, "=<", model_params()[['c']], "=<", 1, ": (0,0,0) is the only one equilibrium")
    } else {
      r2 <- paste(model_params()[['c']], ">", 1, ": 3 equilibrium, (0,0,0) is unstable")
    }
    
    argonInfoCard(
      title = "Pitchfork Bifurcation?", 
      value = r2, 
      icon = "thumbs-up", 
      shadow = TRUE,
      gradient = TRUE,
      background_color = "blue",
      width = 12
    )
    
  })
}