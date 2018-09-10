# Define UI 
dashboardPage(
  skin = "black", 
  title = "Lorenz parameters", 
  collapse_sidebar = TRUE, 
  header, 
  sidebar, 
  body,
  footerOutput(outputId = "dynamicFooter"), 
  div(
    id = "controlbar",
    dashboardControlbar()
  )
)