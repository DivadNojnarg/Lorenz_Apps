# Define UI 
argonDashPage(
  title = "Lorenz parameters", 
  description = "A Lorenz analyzer", 
  author = "David Granjon",
  navbar = navbar, 
  sidebar = sidebar, 
  header = header,
  body = body,
  footer = argonDashFooter(
    copyrights = tagList(
      "by David Granjon.",
      "Built with",
      img(src = "https://www.rstudio.com/wp-content/uploads/2014/04/shiny.png", height = "30"),
      "by",
      img(src = "https://www.rstudio.com/wp-content/uploads/2014/07/RStudio-Logo-Blue-Gray.png", height = "30"),
      "and with", img(src = "love.png", height = "30"),
      "."
    ),
    HTML(
      paste(
        "2018,", 
        a(href = "https://divadnojnarg.github.io/bs4Dash/index.html", "bs4Dash powered", target = "_blank")
      )
    )
  )
)