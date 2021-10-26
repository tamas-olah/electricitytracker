dashSidebar <- blueDashSidebar(
  
  vertical   = TRUE,
  skin       = "light",
  background = "secondary",
  size       = "md",
  side       = "left",
  id         = "my_sidebar",
  brand_url  = NULL,
  brand_logo = "https://i.ibb.co/4Y3Kt0n/trackerlogo3.png",
  # brand_logo = "https://i.ibb.co/gVrXZ1L/trackelogobeta.png",
  

  
  blueSidebarMenu(
    blueSidebarHeader( title = "Main Menu" ),
    
    blueSidebarItem( tabName = "Welcome",
                      icon    = icon( name = "door-open" ),
                      "Welcome" ),
    
    blueSidebarItem( tabName = "Generation",
                      icon    = icon( name = "plus-square" ),
                      "Generation" ),
    
    blueSidebarItem( tabName = "Demand",
                      icon    = icon( name = "minus-square" ),
                      "Demand" ),
    
    blueSidebarItem( tabName = "Exim",
                      icon    = icon( name = "exchange-alt" ),
                      "Export/import" ),
    
    blueSidebarItem( tabName = "Map",
                      icon    = icon( name = "map" ),
                      "Geospatial" ),
    
    blueSidebarItem( tabName = "Data",
                      icon    = icon( name = "database" ),
                      "Data" ),
    
    # blueSidebarItem( tabName = "Todo",
    #                   icon    = icon( name = "tasks" ),
    #                   "To-do" ),
    
    blueSidebarItem( tabName = "About",
                      icon    = icon( name = "address-card" ),
                      "About" )
    
    ),
  br(), br(),
  # blueSidebarDivider(),
  blueSidebarMenu(
    blueSidebarHeader( title = "Inputs"),
    blueSidebarItem( tabName = "Country",
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
