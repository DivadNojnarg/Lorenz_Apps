# Define UI 
bs4DashPage(
  old_school = FALSE,
  title = "Lorenz parameters", 
  sidebar_collapsed = TRUE, 
  navbar = navbar, 
  sidebar = sidebar, 
  body = body,
  controlbar = controlbar,
  footer = bs4DashFooter(
    copyrights = tagList(
      "by David Granjon.",
      "Built with",
      img(src = "https://www.rstudio.com/wp-content/uploads/2014/04/shiny.png", height = "30"),
      "by",
      img(src = "https://www.rstudio.com/wp-content/uploads/2014/07/RStudio-Logo-Blue-Gray.png", height = "30"),
      "and with", img(src = "love.png", height = "30"),
      "."
    ),
    right_text = HTML(
      paste(
        "2018,", 
        a(href = "https://divadnojnarg.github.io/bs4Dash/index.html", "bs4Dash powered", target = "_blank")
      )
    )
  )
)