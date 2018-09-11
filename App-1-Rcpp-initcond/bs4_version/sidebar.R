sidebar <- bs4DashSidebar(
  skin = "light",
  status = "primary",
  title = HTML("<small>Lorenz Parameters</small>"),
  brandColor = NULL,
  url = "",
  src = "https://upload.wikimedia.org/wikipedia/commons/f/f4/Lorenz_attractor.svg",
  elevation = 3,
  opacity = 0.8,
  
  # content
  bs4SidebarMenu(
    bs4SidebarMenuItem("App", tabName = "main", icon = "home"),
    bs4SidebarMenuItem("Info", tabName = "info", icon = "info")
  )
)
