# Define UI 
dashboardPage(skin = "black", title = "Lorenz initial conditions", 
              collapse_sidebar = TRUE, header, sidebar, body,
              footerOutput(outputId = "dynamicFooter"), 
              div(id = "controlbar",
                  dashboardControlbar()
              )
)