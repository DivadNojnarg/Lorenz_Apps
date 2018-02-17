header <- dashboardHeader(
  title="Lorenz Parameters",
  tags$li(
    title = "",
    class = "dropdown",
    #actionButton(inputId="go", label="Update"),
    actionButton(class = "fa fa-floppy-o fa-5x", inputId = "save",
                 label = " Save", class = "btn btn-primary"),
    actionButton(class = "fa fa-refresh fa-5x", inputId = "load",
                 label = " Load", class = "btn btn-primary"),
    actionButton(class = "fa fa-trash fa-5x", inputId = "resetAll",
                 label = " Reset", class = "btn btn-danger")
  )
)