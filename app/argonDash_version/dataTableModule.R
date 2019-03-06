dataTableUi <- function(id) {
  ns <- NS(id)
  fluidRow(
    column(
      width = 12,
      align = "center",
      
      argonCard(
        title = tagList(shiny::icon("table"), "Table"), 
        src = NULL, 
        hover_lift = FALSE,
        shadow = TRUE, 
        shadow_size = "md", 
        hover_shadow = TRUE,
        border_level = 0, 
        icon = NULL, 
        status = "primary",
        background_color = NULL, 
        gradient = FALSE, 
        floating = FALSE,
        width = 12,
        downloadButton(
          outputId = ns("downloadData"), 
          label = " Download Table"
        ),
        withSpinner(
          tagAppendAttributes(
            dataTableOutput(ns("table")),
            style = "overflow-x: scroll;"
          ), 
          size = 2, 
          type = 8, 
          color = "#000000"
        )
      )
    )
  )
}



dataTable <- function(input, output, session, datas) {
  # Generate the output table
  output$table <- renderDataTable(datas(), options = list(pageLength = 5))
  
  # download data
  output$downloadData <- downloadHandler(
    filename = function() {
      paste0("lorenzOutput-", Sys.Date(), ".csv")
    },
    content = function(file) {
      write.csv(datas(), file)
    })
}