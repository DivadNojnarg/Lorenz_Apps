dataTableUi <- function(id) {
  ns <- NS(id)
  fluidRow(
    column(
      width = 12,
      align = "center",
      bs4Card(
        title = tagList(shiny::icon("table"), "Table"), 
        width = 9,
        style = "overflow-x: scroll;",
        collapsible = TRUE, 
        solidHeader = TRUE, 
        downloadButton(
          outputId = ns("downloadData"), 
          label = " Download Table"
        ),
        withSpinner(
          dataTableOutput(ns("table")), 
          size = 2, 
          type = 8, 
          color = "#000000"
        ),
        elevation = 4
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