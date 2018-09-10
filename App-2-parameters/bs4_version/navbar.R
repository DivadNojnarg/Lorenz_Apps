navbar <- bs4DashNavbar(
  status = "white",
  skin = "light",
  rightUi = tagList(
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