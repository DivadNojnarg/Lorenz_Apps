body <- bs4DashBody(
  
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
  
  bs4TabItems(
    bs4TabItem(
      tabName = "main",
      # plots
      bifurcationsUi(id = "bifurc"),
      br(),
      plotLorenzUi(id = "plot"),
      br(),
      stabilityUi(id = "stability")
    ),
    bs4TabItem(
      tabName = "datas",
      dataTableUi(id = "datatable")
    ),
    bs4TabItem(
      tabName = "analysis",
      aboutLorenzUi(id = "about")
    )
  )
)