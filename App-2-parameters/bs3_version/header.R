header <- dashboardHeader(
  title = HTML(paste0(
    '<span class = "logo-lg">Lorenz Parameters</span>',
    '<img src= "lorenz_attractor.svg">'
  )),
  
  titleWidth = 300,
  tags$li(
    title = "",
    class = "dropdown",
    #actionButton(inputId="go", label="Update"),
    actionBttn(
      icon = icon("floppy"), 
      inputId = "save", 
      label = " Save", 
      color = "primary", 
      style = "fill"
    ),
    actionBttn(
      icon = icon("refresh"), 
      inputId = "load", 
      label = " Load", 
      color = "primary", 
      style = "fill"
    ),
    actionBttn(
      icon = icon("trash"), 
      inputId = "resetAll", 
      label = " Reset", 
      color = "danger", 
      style = "fill"
    )
  )
)