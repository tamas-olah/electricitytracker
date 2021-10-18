dashSidebar <- argonDashSidebar(
  
  vertical   = TRUE,
  skin       = "light",
  background = "secondary",
  size       = "md",
  side       = "left",
  id         = "my_sidebar",
  brand_url  = NULL,
  brand_logo = "https://i.ibb.co/2cqRGpy/trackerlogo2.png",
  
  
  
  argonSidebarMenu(
    argonSidebarHeader( title = "Main Menu" ),
    
    # argonSidebarItem( tabName = "Welcome",
    #                   icon    = icon( name = "door-open" ),
    #                   "Welcome!" ),
    
    argonSidebarItem( tabName = "Generation",
                      icon    = icon( name = "plus-square" ),
                      "Generation" ),
    
    argonSidebarItem( tabName = "Demand",
                      icon    = icon( name = "minus-square" ),
                      "Demand" ),
    
    argonSidebarItem( tabName = "Exim",
                      icon    = icon( name = "exchange-alt" ),
                      "Export/import" ),
    
    argonSidebarItem( tabName = "Map",
                      icon    = icon( name = "map" ),
                      "Map" ),
    
    argonSidebarItem( tabName = "Data",
                      icon    = icon( name = "database" ),
                      "Data" ),
    
    # argonSidebarItem( tabName = "Todo",
    #                   icon    = icon( name = "tasks" ),
    #                   "To-do" ),
    
    argonSidebarItem( tabName = "About",
                      icon    = icon( name = "address-card" ),
                      "About" )
    
    ),
  br(), br(),
  # argonSidebarDivider(),
  argonSidebarMenu(
    argonSidebarHeader( title = "Inputs"),
    argonSidebarItem( tabName = "Country",
                      icon    = icon( name = "flag" ),
                      "Country",
                      br(),
                      tags$style( type='text/css', ".selectize-input { font-size: 12px; line-height: 22px;} .selectize-dropdown { font-size: 12px; line-height: 28px; }" ),
                      br(),
                      pickerInput( inputId  = "dropdown12",
                                   width    = 120L,
                                   label    = NULL,
                                   selected = "Germany",
                                   choices  = c( #"Albania"          = "Albania",
                                                 # "Austria"          = "Austria",
                                                 # "Belgium"          = "Belgium",
                                                 # "Bosnia and Herz." = "Bosnia and Herz.",
                                                 # "Bulgaria"         = "Bulgaria",
                                                 # "Croatia"          = "Croatia",
                                                 # "Cyprus"           = "Cyprus",
                                                 # "Czechia"          = "Czechia",
                                                 # "Denmark"          = "Denmark",
                                                 # "Estonia"          = "Estonia",
                                                 # "Finland"          = "Finland",
                                                 "France"           = "France",
                                                 # "Georgia"          = "Georgia",
                                                 "Germany"          = "Germany"
                                                 # "Greece"           = "Greece",
                                                 # "Hungary"          = "Hungary",
                                                 # "Ireland"          = "Ireland",
                                                 # "Italy"            = "Italy",
                                                 # "Kosovo"           = "Kosovo",
                                                 # "Latvia"           = "Latvia",
                                                 # "Lithuania"        = "Lithuania",
                                                 # "Luxembourg"       = "Luxembourg",
                                                 # "Malta"            = "Malta",
                                                 # "Moldova"          = "Moldova",
                                                 # "Montenegro"       = "Montenegro",
                                                 # "Netherlands"      = "Netherlands",
                                                 # "North Macedonia"  = "North Macedonia",
                                                 # "Norway"           = "Norway",
                                                 # "Poland"           = "Poland",
                                                 # "Portugal"         = "Portugal",
                                                 # "Romania"          = "Romania",
                                                 # "Serbia"           = "Serbia",
                                                 # "Slovakia"         = "Slovakia",
                                                 # "Slovenia"         = "Slovenia",
                                                 # "Spain"            = "Spain",
                                                 # "Sweden"           = "Sweden",
                                                 # "Switzerland"      = "Switzerland",
                                                 # "Turkey"           = "Turkey",
                                                 # "Ukraine"          = "Ukraine",
                                                 # "United Kingdom"   = "United Kingdom" 
                                                 ),
                                   options = list( size          = 5L,
                                                   style         = "btn-secondary",
                                                   `live-search` = TRUE ) )
    )
  )
  )
