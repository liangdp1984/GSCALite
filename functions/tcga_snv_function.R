snvOutput <- function() {
  # ns <- NS(id)
  column(
    width = 12, offset = 0,
    shinydashboard::tabBox(
      id = "snv_plot", title = "", width = 12,
      # bubble plot for tumor vs. normal
      tabPanel(title= "SNV percentage profile",PlotInput(id="snv_percentage")),
      tabPanel(title="SNV summary",imagePlotInput("snv_summary",width="100%",height="100%")),
      tabPanel(title="SNV oncoplot",imagePlotInput("snv_oncoplot",width="100%",height="100%")),
      tabPanel(title="SNV survival",PlotInput("snv_survival"))
    )
  )
}

fn_snv_result <- function(.snv){
  if (.snv == TRUE) {
    snvOutput()
  } else{
    column(
      width = 12 , offset = 0,
      shiny::tags$div(style = "height=500px;", class = "jumbotron", shiny::tags$h2("This analysis is not selected"))
    )
  }
}