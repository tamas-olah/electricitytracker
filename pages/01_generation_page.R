generation_page <- argonTabItem(
  
  tabName = "Generation",
  
  argonRow(
    
    argonColumn(
      
      width = 12L,
      
      argonTabSet(
        
        id           = "tabGeneration",
        card_wrapper = FALSE,
        horizontal   = TRUE,
        circle       = FALSE,
        size         = "sm",
        width        = 12L,
        iconList     = lapply( X   = list( "pin-3", "sound-wave", "curved-next"),
                               FUN = argonIcon ),
        
        argonTab(
          
          tabName = "Real-time",
          active  = TRUE,
          
          argonRow(
            
            argonInfoCardTO(
              
              value            = textOutput( "windGen" ), 
              title            = "WIND", 
              stat             = textOutput( "windPerc" ), 
              stat_icon        = icon( "percent" ),
              description      = "of total", 
              icon             = icon( "wind", color = "secondary" ), 
              icon_background  = "primary",
              hover_lift       = FALSE,
              shadow           = TRUE,
              gradient         = TRUE
              ),
            
            argonInfoCardTO(
              
              value            = textOutput( "solarGen" ), 
              title            = "SOLAR", 
              stat             = textOutput( "solarPerc" ), 
              stat_icon        = icon( "percent" ),
              description      = "of total", 
              icon             = icon( "solar-panel", color = "secondary" ), 
              icon_background  = "primary",
              hover_lift       = FALSE,
              shadow           = TRUE,
              gradient         = TRUE
            ),
            
            argonInfoCardTO(
              value            = textOutput( "fossilGen" ), 
              title            = "FOSSIL", 
              stat             = textOutput( "fossilPerc" ), 
              stat_icon        = icon( "percent" ),
              description      = "of total", 
              icon             = icon( "industry", color = "secondary" ), 
              icon_background  = "primary",
              hover_lift       = FALSE,
              shadow           = TRUE,
              gradient         = TRUE
            ),
            
            argonInfoCardTO(
              value            = textOutput( "nuclearGen" ), 
              title            = "NUCLEAR", 
              stat             = textOutput( "nuclearPerc" ), 
              stat_icon        = icon( "percent" ),
              description      = "of total", 
              icon             = icon( "atom", color = "secondary" ), 
              icon_background  = "primary",
              hover_lift       = FALSE,
              shadow           = TRUE,
              gradient         = TRUE
              )
            ),
          
          br(),br(),
          
          argonRow(
            
            plotlyOutput( "generationRT", height = "580px" )
            )
          ),
        
        argonTab(
          
          tabName = "Long-term",
          active  = FALSE,
          
          argonCard(
            
            width        = 12L,
            src          = NULL,
            icon         = icon( "cogs" ),
            status       = "default",
            shadow       = TRUE,
            border_level = 2L,
            hover_shadow = TRUE,
            title        = "Long-term",
            
            argonRow(
              
              argonColumn(
                
                width = 6L,
                "🚧 Under construction 🚧"
                )
              )
            )
          ),
        
        argonTab(
          
          tabName = "Forecast",
          active  = FALSE,
          
          argonCard(
            
            width        = 12L,
            src          = NULL,
            icon         = icon(name = "cogs"),
            status       = "default",
            shadow       = TRUE,
            border_level = 2L,
            hover_shadow = TRUE,
            title        = "Forecast",
            
            argonRow(
              
              argonColumn(
                
                width = 6L,
                "🚧 Under construction 🚧"
                )
              )
            )
          )
        )
      )
    )
  )
