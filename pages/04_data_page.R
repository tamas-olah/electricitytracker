data_page <- argonTabItem(
  
  tabName = "Data",
  
  argonCard(
    
    width        = 12L,
    src          = NULL,
    icon         = icon( "wrench" ),
    status       = "default",
    shadow       = TRUE,
    border_level = 2L,
    hover_shadow = TRUE,
    title        = "Data",
    "🚧 Under construction 🚧",
    
    argonRow(
      
      argonColumn(
        
        width = 6L,
        dataTableOutput( "GermanyData" )
        )
      )
    )
  )
