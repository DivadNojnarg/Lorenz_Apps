sidebar <- dashboardSidebar(
  width = 300,
  
  sidebarMenu(
    
    id = "sidebar_main",
    
    menuItem("Info", tabName = "info", icon = icon("info")),
    menuItem("App", tabName = "main", icon = icon("home"), selected = TRUE),
    menuItem("Solver Settings", tabName = "solve_settings", icon = icon("cogs")
             
             
    ),
    menuItem("Initial conditions", tabName = "init_settings", icon = icon("flask")
             
             
    )
  )
)

