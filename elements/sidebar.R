dashSidebar <- argonDashSidebar(
  
  vertical   = TRUE,
  skin       = "light",
  background = "secondary",
  size       = "md",
  side       = "left",
  id         = "my_sidebar",
  brand_url  = NULL,
  brand_logo = "https://i.ibb.co/2cqRGpy/trackerlogo2.png",
  
  argonSidebarHeader( title = "Main Menu" ),
  
  argonSidebarMenu(
    
    argonSidebarItem( tabName = "Generation",
                      icon    = icon( name = "plus-square" ),
                      "Generation" ),
    
    argonSidebarItem( tabName = "Demand",
                      icon    = icon( name = "minus-square" ),
                      "Demand" ),
    
    argonSidebarItem( tabName = "Exim",
                      icon    = icon( name = "exchange-alt" ),
                      "Export/import" ),
    
    argonSidebarItem( tabName = "Data",
                      icon    = icon( name = "database" ),
                      "Data" ),
    
    argonSidebarItem( tabName = "Todo",
                      icon    = icon( name = "tasks" ),
                      "To-do" ),
    
    argonSidebarItem( tabName = "About",
                      icon    = icon( name = "address-card" ),
                      "About" )
    )
  )
