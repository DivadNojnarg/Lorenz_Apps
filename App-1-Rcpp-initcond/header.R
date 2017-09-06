header <- dashboardHeader(
  title="Lorenz Model App1",
  tags$li(
    title = "",
    class = "dropdown",
    actionButton(class="fa fa-floppy-o fa-5x", inputId="save",
                 label=" Save", class="btn btn-primary"),
    actionButton(class="fa fa-refresh fa-5x", inputId="load",
                 label=" Load", class="btn btn-primary"),
    actionButton(class="fa fa-trash fa-5x", inputId="resetAll",
                 label=" Reset", class="btn btn-danger"),
    actionButton(class="fa fa-close fa-5x", inputId="close",
                 label=" Close", class="btn btn-danger")
  ),
  dropdownMenu(type = "tasks", badgeStatus = "success",
               taskItem(value = 60, color = "orange",
                        "Design"
               ),
               taskItem(value = 80, color = "green",
                        "Features"
               )
  )
)