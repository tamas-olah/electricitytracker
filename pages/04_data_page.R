data_page <- blueTabItem(
  
  tabName = "Data",
  
  blueCard(
    
    width        = 12L,
    src          = NULL,
    icon         = icon( "wrench" ),
    status       = "default",
    shadow       = TRUE,
    border_level = 2L,
    hover_shadow = TRUE,
    title        = "Data",
    "🚧 Under construction 🚧",
    
    blueRow(
      
      blueColumn(
        
        width = 6L,
        dataTableOutput( "GermanyData" )
        )
      )
    )
  )
