library(shiny)
library(DT)
library(readxl)
library(dplyr)
library(openxlsx)
library(tidyxl)

dfmaindb <- read_excel("db.xlsx", col_types = "text")

ui <- navbarPage(
  
  title = "User Access Review Dashboard",
  tabPanel("Overview",
           
           ),
  tabPanel("Data",
           
           sidebarLayout(
             
             sidebarPanel(
               
               fileInput("files", "Choose Files to update Data",
                         multiple = TRUE,
                         accept = c(".xlsx")),
               
               actionButton("updatefile", "Update Database"),
               
               hr(),
               
               checkboxGroupInput("show_vars", "Columns in Database to show:",
                                  names(dfmaindb), selected = c("Application Name",
                                                                "Employee ID",
                                                                "Employee Name",
                                                                "Profile/Acceess Level/Role",
                                                                "Manager Email",
                                                                "Access Decision",
                                                                "Comments")),
               
               width = 2
               
             ),
             
             mainPanel(

               DTOutput('db'),
               
               hr(),
               
               actionButton("savebutton", "Update Database"),
               
               hr(),
               
               downloadButton("dl", "Download Filtered Data"),
               
               width = 10
             )
             
           )
           
           
           
           )#,
  #tabPanel("Component 3")
  
)

server <- function(input, output, session) {
  
  output$db <- renderDT(dfmaindb[, input$show_vars, drop = FALSE], 
                        editable = list(target = 'row', disable = list(columns = c(1))),
                        filter = "top",
                        )
  
  #dfuploaded <- reactive({
   # rbindlist(lapply(input$files$datapath, readxl::read_excel),use.names = TRUE, fill = TRUE)
              #use.names = TRUE, fill = TRUE)
  #})
  
  observeEvent(input$updatefile, {
    if(!is.null(input$files)){
      
      dffiles <- lapply(input$files$datapath, function(i){
                              read_excel(i, sheet="Access Review", col_types = "text")
                          })
      dfuploaded <- bind_rows(dffiles)
      
      dfmaindb <- dfmaindb %>%
      filter(! UID %in% dfuploaded$UID) %>%
      bind_rows(dfuploaded)
    
      wbupdated = createWorkbook()
      addWorksheet(wbupdated, "Access Review")
      writeData(wbupdated, sheet = "Access Review", dfmaindb)
      saveWorkbook(wbupdated, "db.xlsx", overwrite = TRUE)
      #Sys.sleep(2)
      dfmaindb <- read_excel("db.xlsx", col_types = "text")
      #dfmaindb <- NULL
      #session$reload()
      output$db <- renderDT(dfmaindb[, input$show_vars, drop = FALSE], 
                            editable = list(target = 'row', disable = list(columns = c(1))),
                            filter = "top",
      )
    }
    else
      return(NULL)
    
  })
  
  observeEvent(input$db_row_edit, {
    dfmaindb[input$db_row_edit$row,] <<- input$db_row_edit$value
  })
  
  observeEvent(input$savebutton, {
    
    dfupdated <- dfmaindb[input$db_rows_all,]
    dfmaindb <- dfmaindb %>%
      filter(! UID %in% dfupdated$UID) %>%
      bind_rows(dfupdated)
    
    wbupdated = createWorkbook()
    addWorksheet(wbupdated, "Access Review")
    writeData(wbupdated, sheet = "Access Review", dfmaindb)
    saveWorkbook(wbupdated, "db.xlsx", overwrite = TRUE)
    #Sys.sleep(2)
    dfmaindb <- read_excel("db.xlsx", col_types = "text")
    #dfmaindb <- NULL
    #session$reload()
    output$db <- renderDT(dfmaindb[, input$show_vars, drop = FALSE], 
                          editable = list(target = 'row', disable = list(columns = c(1))),
                          filter = "top",
    )
    
  })
  
  output$dl <- downloadHandler(
    filename = "toSend.xlsx",
    content = function(file) {
      wb <- createWorkbook()
      addWorksheet(wb, "Access Review")
      writeData(wb, "Access Review", dfmaindb[input$db_rows_all,])
      saveWorkbook(wb, file, overwrite = TRUE)
    }
  )
  session$allowReconnect(TRUE)
  
}

shinyApp(ui, server)