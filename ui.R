# save as 'ui.R'
# shiny ui


# Load library ------------------------------------------------------------
library(magrittr)
library(ggplot2)
library(tibble)

# For shiny
library(shiny)
library(shinyjs)
library(shinyBS)
library(shinyWidgets)
library(shinycssloaders)
library(shinydashboard)


# For front end
library(DT)
library(grid)
# library(highcharter)

# For network
library(igraph)
library(networkD3)

# For analysis
# library(GSVA)
# library(maftools)


# Load configuration ------------------------------------------------------

source(file = "config.R", local = TRUE)

# Load ui function --------------------------------------------------------

source(file = file.path(config$ui, "functions_ui.R"), local = TRUE)

# Header Start ------------------------------------------------------------

header <- dashboardHeader(
  # Title
  title = HTML(paste(
    img(
      src = "./imgs/01.GSCA_logo_01.png",
      align = "middle",
      class = "img-responsvie",
      style = "height:55px !important;"
    ), ""
  )),

  dropdownMenuOutput("infoMenu"),

  dropdownMenuOutput("logMenu")
)

# Header End --------------------------------------------------------------


# Sidebar Start -----------------------------------------------------------

sidebar <- dashboardSidebar(
  sidebarMenu(
    # Welcome ----
    menuItem("Welcome", tabName = "welcome", icon = icon("home")),

    # TCGA ----
    menuItem(
      "TCGA Cancer",
      tabName = "tcga",
      icon = icon("user-md"),
      collapsible = TRUE,
      menuSubItem("mRNA Expression", tabName = "tcga_expr"),
      menuSubItem("Single Nucleotide Variation", tabName = "tcga_snv"),
      menuSubItem("Copy Number Variation", tabName = "tcga_cnv"),
      menuSubItem("Methylation", tabName = "tcga_meth"),
      menuSubItem("Pathway Activity", tabName = "tcga_rppa"),
      menuSubItem("miRNA Network", tabName = "tcga_mirna")
    ),

    # Drug ----
    menuItem(
      "Drug Sensitivity",
      tabName = "drug",
      icon = icon("medkit")
    ),

    # GTEx ----
    menuItem(
      "GTEx Normal Tissue",
      tabName = "gtex",
      icon = icon("suitcase"),
      collapsible = TRUE,
      menuSubItem("GTEx Expression", tabName = "gtex_expr"),
      menuSubItem("GTEx eQTL", tabName = "gtex_eqtl")
    ),

    # Downloads ----
    # menuItem("Report", tabName = "downloads", icon = icon("floppy-o")),
    
    # Tutorial ----
    menuItem("Help", tabName = "help", icon = icon("rocket")),
    
    # Help ----
    # menuItem("Document", tabName = "document", icon = icon('file-text')),

    # About ----
    menuItem("Contact", tabName = "contact", icon = icon("address-book"))
  )
)

# Sidebar End -------------------------------------------------------------

# Body Start --------------------------------------------------------------

body <- dashboardBody(
  
  # for html head 
  shiny::tags$head(
    shinyWidgets::useSweetAlert(), # For sweet alert
    shinyjs::useShinyjs(), # For shinyjs
    shinyjs::extendShinyjs(script = file.path(config$wd, "www", "js", "gscalite.js")),
    shiny::tags$link(rel = "stylesheet", type = "text/css", href = "css/main.css"),
    shiny::tags$script(type = "text/javascript", src = "js/main.js")
  ),

  # Main body ----
  tabItems(

    # Welcome ----
    source(file = file.path(config$wd, "ui", "welcome_ui.R"), local = TRUE)$value,


    # GTEx ----
    source(file = file.path(config$wd, "ui", "GTEx_exp_ui.R"), local = TRUE)$value,
    source(file = file.path(config$wd, "ui", "GTEx_eqtl_ui.R"), local = TRUE)$value,

    # TCGA ----
    # expr ----
    source(file = file.path(config$wd, "ui", "tcga_expr_ui.R"), local = TRUE)$value,
    # cnv ----
    source(file = file.path(config$wd, "ui", "tcga_cnv_ui.R"), local = TRUE)$value,
    # snv ----
    source(file = file.path(config$wd, "ui", "tcga_snv_ui.R"), local = TRUE)$value,

    # meth ----
    source(file = file.path(config$wd, "ui", "tcga_meth_ui.R"), local = TRUE)$value,

    # rppa ----
    source(file = file.path(config$wd, "ui", "tcga_rppa_ui.R"), local = TRUE)$value,
    # mirna ----
    source(file = file.path(config$wd, "ui", "tcga_mirna_ui.R"), local = TRUE)$value,
    # Drug ----
    source(file = file.path(config$wd, "ui", "drug_ui.R"), local = TRUE)$value,

    # Tutorial ----
    source(file = file.path(config$wd, "ui", "tutorial_ui.R"), local = TRUE)$value,
    
    # Document ----
    # source(file = file.path(config$wd, "ui", "document_ui.R"), local = TRUE)$value,

    # About ----
    source(file = file.path(config$wd, "ui", "contact_ui.R"), local = TRUE)$value
  )
)


# Body End ----------------------------------------------------------------


# dashboadpage ------------------------------------------------------------
page <- dashboardPage(
  title = "GSCA - Gene Set Cancer Analysis",
  header = header,
  sidebar = sidebar,
  body = body
)

# Shiny UI ----------------------------------------------------------------
ui <- tagList(
  div(id = "loading-content",h2("Loading...")),
  shinyjs::hidden(div(id = "app-content", page))
)

shinyUI(ui = ui)
