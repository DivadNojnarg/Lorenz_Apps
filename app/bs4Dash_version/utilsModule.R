utilsUi <- function(id) {
  ns <- NS(id)
  lapply(
    tagList(
      introBox(
        actionBttn(
          icon = icon("floppy"), 
          inputId = ns("save"), 
          label = " Save", 
          color = "primary", 
          style = "simple",
          size = "xs"
        ),
        actionBttn(
          icon = icon("refresh"), 
          inputId = ns("load"), 
          label = " Load", 
          color = "primary", 
          style = "simple",
          size = "xs"
        ),
        data.step = 6,
        data.intro = help_text[6]
      )
    ),
    # add horizontal margin between buttons
    tagAppendAttributes,
    class = "mx-2"
  )
}



utils <- function(input, output, session) {
  
  # save input parameters into the global values
  observeEvent(input$save, {
    values <<- lapply(reactiveValuesToList(input), unclass)
  })
  
  # restore inputs when click on load
  observeEvent(input$load, {
    if (exists("values")) {
      lapply(names(values), function(x) {
        session$sendInputMessage(x, list(value = values[[x]]))
      }) 
    }
  })
}