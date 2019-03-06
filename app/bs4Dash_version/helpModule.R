helpLorenzUi <- function(id) {
  
  ns <- NS(id)
  
  tagAppendAttributes(
    actionBttn(
      inputId = ns("help"),
      label = "Help",
      icon = NULL,
      style = "simple",
      color = "danger",
      size = "sm",
      block = FALSE,
      no_outline = TRUE
    ),
    class = "helpBttn"
  )
}





helpLorenz <- function(input, output, session) {
  connection <- reactiveVal(0)
  
  # print an alert only once
  observe({
    if (connection() == 0) {
      
      newNumber <- connection() + 1
      connection(newNumber)
      
      shinyjs::delay(3000, {
        sendSweetAlert(
          session = session,
          title = "Success !!",
          text = "Welcome on the Lorenz Model Simulator. 
        The Lorenz model is a super famous attractor,
        like the Van der Pol oscillator. If it's your first time,
        go through the help section. Good exploration!",
          html = TRUE,
          closeOnClickOutside = FALSE,
          type = "success"
        )
        
        runjs("$('.helpBttn').addClass('blinking-button')")
      })
      
    }
  })
  
  
  # help animation with introjs
  # options are provided to control the size of the help
  # Do not forget to wrap the event content in I('my_function')
  # otherwise it will fail
  observeEvent(input$help, {
    
    runjs("$('.helpBttn').removeClass('blinking-button')")
    runjs("$('body').addClass('control-sidebar-slide-open')")
    
    introjs(
      session,
      options = list(
        "nextLabel" = "Next step!",
        "prevLabel" = "Did you forget something?",
        "tooltipClass" = "newClass",
        #"highlightClass" = "newClass",
        "showProgress" = TRUE,
        "showBullets" = FALSE
      ),
      events = list(
        # reset the session to hide sliders and back/next buttons
        #"oncomplete" = I('history.go(0)'),
        "onbeforchange" = I("function(steps) { Shiny.onInputChange('current_step', data-stepnumber); }"),
        "onbeforechange" = I('$(".newClass").css("max-width", "500px").css("min-width","500px");')
      )
    )
  })
  
}