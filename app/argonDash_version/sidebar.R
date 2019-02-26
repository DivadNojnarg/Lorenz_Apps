sidebar <- argonDashSidebar(
  id = "sidebar",
  side = "left",
  vertical = TRUE,
  size = "md",
  skin = "light",
  background = "white",
  brand_url = NULL,
  brand_logo = "https://upload.wikimedia.org/wikipedia/commons/f/f4/Lorenz_attractor.svg",

  argonSidebarHeader(title = "Menu"),
  
  # content
  argonSidebarMenu(
    argonSidebarItem("App", tabName = "main", icon = "home", icon_color = NULL),
    argonSidebarItem("Datas", tabName = "datas", icon = "table", icon_color = NULL),
    argonSidebarItem("Analysis", tabName = "analysis", icon = "superscript", icon_color = NULL)
  ),
  
  # help button
  helpLorenzUi(id = "help")
)

