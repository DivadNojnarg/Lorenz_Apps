body <- argonDashBody(
  
  # load useful libraries
  useShinyjs(),
  withMathJax(),
  useShinyFeedback(),
  introjsUI(),
  
  # load custom javascript
  includeScript(path = "www/js/find-navigator.js"),
  
  # load custom css
  includeCSS(path = "www/css/lorenz-app.css"),
  
  # unleash shinyEffects
  setZoom(class = "info-box", scale = 1.02),
  # unleash shinyWidgets
  
  argonTabItems(
    argonTabItem(
      tabName = "main",
      # plots
      bifurcationsUi(id = "bifurc"),
      br(),
      plotLorenzUi(id = "plot")
    ),
    argonTabItem(
      tabName = "datas",
      dataTableUi(id = "datatable")
    ),
    argonTabItem(
      tabName = "analysis",
      aboutLorenzUi(id = "about")
    )
  )
)