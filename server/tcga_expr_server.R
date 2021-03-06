# source by "server.R"

source(file.path(config$wd, "functions", "data_function.R"))
source(file.path(config$wd, "functions", "tcga_expr_function.R"))

expr_clean <- NULL
survival_clean <- NULL


# toga expr welcome -------------------------------------------------------
output$ui_expr_welcome <- shiny::renderUI({fn_expr_welcome()})

output$ui_expr_help <- shiny::renderUI({fn_expr_help()})

# expr analysis result ----------------------------------------------------

output$ui_expr_result <- shiny::renderUI({fn_expr_result(selected_analysis$expr)})



# Start analysis ----------------------------------------------------------

expr_start_analysis <- function(input, output, session, .expr_clean, .survival_clean, .subtype_clean, .msg, .msg_no_result) {
  output$expr_dt_comparison <- DT::renderDataTable({expr_clean_datatable(.expr_clean)})
  if(nrow(.expr_clean)>0){
    exp_plot_height <- .expr_clean$symbol %>% unique() %>% length()*20
    output$expr_bubble_plot <- renderPlot({
    .expr_clean %>% expr_buble_plot()
    } ,height = function(){ifelse(exp_plot_height<200,200,exp_plot_height)})
    
  output$`de-picdownload` <- downloadHandler(
    filename = function() {
      paste("Differential_Expression", ".", input$`de-pictype`, sep = "")
    },
    content = function(file){
      print(file)
      ggsave(file,expr_buble_plot(.expr_clean),device = input$`de-pictype`,width = input$`de-d_width`,height = input$`de-d_height`)
    }
  )
  .msg_de_massage <- NULL
  } else {
    .msg_de_massage <- .msg
    output$expr_bubble_plot <- renderPlot({NULL})
    output$`de-picdownload` <- downloadHandler(NULL)
  }
  
  
  # survival
  if(nrow(.survival_clean)>0){
    sur_plot_height <- .survival_clean$symbol %>% unique() %>% length()*20
    output$survival <- renderPlot({.survival_clean %>% survival_bubble_plot()},height = function(){ifelse(sur_plot_height<200,200,sur_plot_height)})
    output$`sur-picdownload` <- downloadHandler(
      filename = function() {
        paste("Expression_Survival", ".", input$`sur-pictype`, sep = "")
      },
      content = function(file){
        print(file)
        ggsave(file,survival_bubble_plot(.survival_clean),device = input$`sur-pictype`,width = input$`sur-d_width`,height = input$`sur-d_height`)
      }
    )
    .msg_sur_massage <- NULL
  } else {
    .msg_sur_massage <- .msg_no_result
    output$survival <- renderPlot({NULL})
    output$`sur-picdownload` <- downloadHandler(NULL)
  }
  
  
  # subtype
  if(nrow(.subtype_clean)>0){
    sub_plot_height <- .subtype_clean$symbol %>% unique() %>% length()*20
    output$subtype <- renderPlot({.subtype_clean %>% subtype_bubble_plot()},height = function(){ifelse(sub_plot_height<200,200,sub_plot_height)})
    output$`sub-picdownload` <- downloadHandler(
      filename = function() {
        paste("Subtype", ".", input$`sub-pictype`, sep = "")
      },
      content = function(file){
        print(file)
        ggsave(file,subtype_bubble_plot(.subtype_clean),device = input$`sub-pictype`,width = input$`sub-d_width`,height = input$`sub-d_height`)
      }
    )
    .msg_sub_massage <- NULL
  } else {
    .msg_sub_massage <- .msg_no_result
    output$subtype <- renderPlot({NULL})
    output$`sub-picdownload` <- downloadHandler(NULL)
  }
  
  # message output ----
  output[["de_massage"]] <- renderUI({
    tagList(
      shiny::tags$p(.msg_de_massage, style = "color:#CD3700")
    )
  })
  output[["sur_massage"]] <- renderUI({
    tagList(
      shiny::tags$p(.msg_sur_massage, style = "color:#CD3700")
    )
  })
  output[["sub_massage"]] <- renderUI({
    tagList(
      shiny::tags$p(.msg_sub_massage, style = "color:#CD3700")
    )
  })
}


# From start analysis -----------------------------------------------------
expr_analysis <- eventReactive(
  eventExpr = status$analysis,
  ignoreNULL = TRUE,
  valueExpr = {
    # be sure the following code run after start analysis
    if (status$analysis == TRUE) {
        # load data expr ----
        processing$start_loading_start <- TRUE
        
        # Cancer types value box selection ----------------------------------------
        
        callModule(module = cancerTypesSelect, id = "expr", .sctps = intersect(selected_ctyps(), tcga_data))
        
        # Check box ---------------------------------------------------------------
        
        callModule(module = selectAndAnalysis, id = "expr", .id = "expr")
        
        updateProgressBar(session = session, id = "progressbar", value = 40, status = "danger")
        session$onFlushed(function() {progress$expr_loading <- TRUE})
        observeEvent(eventExpr = progress$expr_loading, handlerExpr = {
            if (progress$expr_loading == TRUE) {
              # load data
              load_data_expr()
              processing$start_loading_end <- TRUE
            }
          })
        
        observeEvent(processing$start_loading_end, {
          if (processing$start_loading_end == TRUE) {
            updateProgressBar(session = session, id = "progressbar", value = 70, status = "warning")
            session$onFlushed(function() {
              progress$expr_calc <- TRUE
            })
          }
        })
        
        observeEvent(eventExpr = progress$expr_calc, handlerExpr = {
            if (progress$expr_calc == TRUE) {
              
              .valid_ctps <- intersect(paired_cancer_types, selected_ctyps())
              .invalid_ctps <- setdiff(selected_ctyps(), paired_cancer_types)
              .msg_valid_ctps <- ""
              .msg_invalid_ctps <- ""
              if (length(.valid_ctps) > 1) {
                .msg_valid_ctps <- glue::glue("only {paste0(.valid_ctps, collapse = ', ')} have paired samples")
              } else if (length(.valid_ctps) == 1) {
                .msg_valid_ctps <- glue::glue("only {.valid_ctps} has paired samples")
              } else{
                .msg_valid_ctps <- "no cancer types have paired samples"
              }
              if (length(.invalid_ctps) > 1) {
                .msg_invalid_ctps <- glue::glue("The cancer types {paste0(.invalid_ctps, collapse = ', ')} don't have paired samples.")
              } else if (length(.invalid_ctps) == 1) {
                .msg_invalid_ctps <- glue::glue("The cancer type {.invalid_ctps} doesn't have paired samples.")
              } else {
                .msg_invalid_ctps <- ""
              }
              .msg <- glue::glue("In Tumor vs. Normal module, the analysis is based on paired samples in each cancer types. In your selected cancer types, {.msg_valid_ctps}. {.msg_invalid_ctps}")
              .msg_no_result <- glue::glue("No significant result of gene set in your selected cancer types: {selected_ctyps()}.")
              
              shinyBS::createAlert(
                session = session, anchorId = "expr-no_gene_set", title = "Information", style = "info",
                content = .msg, append = FALSE
              )
              
              expr %>%
                dplyr::filter(cancer_types %in% paired_cancer_types) %>%
                dplyr::filter(cancer_types %in% selected_ctyps()) %>% 
                dplyr::filter(symbol %in% gene_set$match) ->> expr_clean
              expr_survival %>% 
                dplyr::filter(cancer_types %in% selected_ctyps()) %>% 
                dplyr::filter(symbol %in% gene_set$match) ->> survival_clean
              expr_subtype %>% 
                dplyr::filter(cancer_types %in% selected_ctyps()) %>% 
                dplyr::filter(symbol %in% gene_set$match) ->> subtype_clean
              
              print(glue::glue("{paste0(rep('-', 10), collapse = '')} clean data complete @ {Sys.time()} {paste0(rep('-', 10), collapse = '')}"))
              # call module
              callModule(module = expr_start_analysis, id = "expr", .expr_clean = expr_clean, .survival_clean = survival_clean, .subtype_clean = subtype_clean, .msg = .msg, .msg_no_result=.msg_no_result)
              print(glue::glue("{paste0(rep('-', 10), collapse = '')} expr bubble plot complete @ {Sys.time()} {paste0(rep('-', 10), collapse = '')}"))
              
              processing$expr_calc_end <- TRUE
            }
          })
        
        observeEvent(processing$expr_calc_end, {
          if (processing$expr_calc_end == TRUE) {
            updateProgressBar(session = session, id = "progressbar", value = 100, status = "info")
            progress$progress_end <- TRUE
          }
        })
    }
  }
)

observe(expr_analysis())
