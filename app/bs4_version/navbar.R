navbar <- bs4DashNavbar(
  status = "white",
  skin = "light",
  rightUi = lapply(
    tagList(
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
    ),
    # add horizontal margin between buttons
    tagAppendAttributes,
    class = "mx-2"
  ),
  leftUi = tagList(
    tagAppendAttributes(
      prettySwitch(
        inputId = "print_infoboxes",
        label = "Print Info Boxes?",
        status = "danger",
        value = TRUE,
        fill = TRUE,
        bigger = TRUE
      ),
      class = "my-2"
    )
  )
)