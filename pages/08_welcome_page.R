welcome_page <- blueTabItem(

  tabName = "Welcome",

  blueCard(

    width        = 12L,
    src          = NULL,
    icon         = icon( "door-open" ),
    status       = "default",
    shadow       = TRUE,
    border_level = 2L,
    hover_shadow = TRUE,
    title        = "Welcome!",
    
    h3( "About this site" ),
    "⚡️   This dashboard allows you to monitor near real-time data on European electricity generation, demand, and cross-border transmission.",
    
    br(),br(),
    
    "⚡️   All data come from ", tags$a( href = "https://www.entsoe.eu", strong( "ENTSO-E" ) ), ", the European Network of Transmission System Operators for Electricity. Fresh data is fetched from ENTSO-E servers every 30 minutes. There is a ~4-hour lag in most datasets.",
    
    br(),br(),
    
    "⚡️   The dashboard is developed in the author’s free time, to practice R programming, data cleaning, visualization, and Shiny. It is in development stage. Much of the planned functionality is yet to be implemented. The 🚧 Under construction 🚧 sign means that the given functionality hasn't been implemented yet.",
    
    br(),br(),
    
    "⚡️   So far, only German and French data are included. Please be patient while the data is fetched from the servers and the visuals load. Time formats are in local, Central European Time.",
    
    br(),br(),br(),
    
    h3( "Code" ),
    
    "⚡️   Code used to generate this Shiny dashboard is available on ", tags$a( href = "https://github.com/tamas-olah/electricitytracker", strong( "GitHub" ) ), ".",
    
    br(),br(),br(),
    
    h3( "Author" ),
    
    "⚡️   Tamas Balazs Olah, analyst at Callis Energy. More information on the", strong( "About" ), "page.",
    
    br(),br(),br(),br(),br(),
    
    div( img( src = "joint.png" ), style = "text-align: center;" ),
    
    br()
    
    )
  )

