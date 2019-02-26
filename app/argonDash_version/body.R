body <- argonDashBody(
  
  # load useful libraries
  useShinyjs(),
  withMathJax(),
  useShinyFeedback(),
  introjsUI(),
  
  # load custom javascript
  includeScript(path = "www/js/find-navigator.js"),
  
  # custom jquery to hide the header based on the selected tag
  # actually argonDash would need a custom input/output binding
  # to solve this issue once for all
  tags$head(
    tags$script(
      "$(function () {
        $('#sidebar-menu .nav-link:eq(0)').click(function() {
          $('.header').show();
          $('#utils-save').show();
          $('#utils-load').show();
          $('#resetAll').show();
        });
        $('#sidebar-menu .nav-link:not(:eq(0))').click(function() {
          $('.header').hide();
          $('#utils-save').hide();
          $('#utils-load').hide();
          $('#resetAll').hide();
        });
      });"
    )
  ),
  
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