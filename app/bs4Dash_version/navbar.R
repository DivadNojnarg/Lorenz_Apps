navbar <- bs4DashNavbar(
  status = "white",
  skin = "light",
  rightUi = fluidRow(
    utilsUi(id = "utils"),
    # reset is not included in the module
    # shinyjs does not work in that specific case
    actionBttn(
      icon = icon("trash"), 
      inputId = "resetAll", 
      label = " Reset", 
      color = "danger", 
      style = "simple",
      size = "xs"
    )
  ),
  leftUi = computeLorenzUi(id = "compute")
)