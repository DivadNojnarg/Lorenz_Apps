body <- bs4DashBody(
  useShinyjs(),
  withMathJax(),
  useShinyFeedback(),
  
  # load custom javascript
  includeScript(path = "www/js/find-navigator.js"),
  
  # unleash shinyEffects
  setZoom(class = "info-box", scale = 1.02),
  # unleash shinyWidgets
  chooseSliderSkin(skin = "Flat"),
  
  bs4TabItems(
    bs4TabItem(
      tabName = "main",
      # plots
      bifurcationsUi(id = "bifurc"),
      br(),
      computeLorenzUi(id = "compute"),
      plotLorenzUi(id = "plot"),
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