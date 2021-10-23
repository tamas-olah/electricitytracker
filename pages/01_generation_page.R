generation_page <- blueTabItem(
  
  tabName = "Generation",
  
  blueRow(
    
    blueColumn(
      
      width = 12L,
      
      blueTabSet(
        
        id           = "tabGeneration",
        card_wrapper = FALSE,
        horizontal   = TRUE,
        circle       = FALSE,
        size         = "sm",
        width        = 12L,
        iconList     = lapply( X   = list( "pin-3", "curved-next", "sound-wave"),
                               FUN = blueIcon ),
        
        blueTab(
          
          tabName = "Real-time",
          active  = TRUE,
          
          blueRow(
            
            blueInfoCardTO(
              value            = textOutput( "windGen" ), 
              title            = "WIND", 
              stat             = textOutput( "windPerc" ), 
              stat_icon        = icon( "percent" ),
              description      = "of total", 
              icon             = icon( "wind", color = "secondary" ), 
              icon_background  = "primary",
              hover_lift       = FALSE,
              shadow           = TRUE,
              gradient         = TRUE ),
            
            blueInfoCardTO(
              value            = textOutput( "solarGen" ), 
              title            = "SOLAR", 
              stat             = textOutput( "solarPerc" ), 
              stat_icon        = icon( "percent" ),
              description      = "of total", 
              icon             = icon( "solar-panel", color = "secondary" ), 
              icon_background  = "primary",
              hover_lift       = FALSE,
              shadow           = TRUE,
              gradient         = TRUE ),
            
            blueInfoCardTO(
              value            = textOutput( "fossilGen" ), 
              title            = "FOSSIL", 
              stat             = textOutput( "fossilPerc" ), 
              stat_icon        = icon( "percent" ),
              description      = "of total", 
              icon             = icon( "industry", color = "secondary" ), 
              icon_background  = "primary",
              hover_lift       = FALSE,
              shadow           = TRUE,
              gradient         = TRUE ),
            
            blueInfoCardTO(
              value            = textOutput( "nuclearGen" ), 
              title            = "NUCLEAR", 
              stat             = textOutput( "nuclearPerc" ), 
              stat_icon        = icon( "percent" ),
              description      = "of total", 
              icon             = icon( "atom", color = "secondary" ), 
              icon_background  = "primary",
              hover_lift       = FALSE,
              shadow           = TRUE,
              gradient         = TRUE )
            ),
          
          br(),
          
          blueRow( blueColumn(sliderTextInput( inputId = "genslider",
                                    label   = NULL,
                                    width = "100%",
                                    choices = seq.Date( from = today() - days( 20L ),
                                                        to   = today() + days( 1 ),
                                                        by   = "day" ),
                                    selected = c( today() - days( 2L ), today() + days( 1 ) ),
                                    grid = TRUE
                                    )
          )),
          
          blueRow(
            
            blueCard(
              
              width = 12L,
              
              echarts4rOutput( "generationRT", height = "580px" )
              
              )
            )
          ),
        
        blueTab(
          
          tabName = "Forecast",
          active  = FALSE,
          
          blueRow(
            
            blueColumn(
              
              width = 12L,
              
              blueRow(
                
                blueCard(
                  
                  width        = 12L,
                  src          = NULL,
                  icon         = NULL,
                  status       = NULL,
                  shadow       = TRUE,
                  border_level = 8L,
                  hover_shadow = TRUE,
                  title        = NULL,
                  
                  echarts4rOutput( "GenDAWSGerPlot", width = "100%")
                )
              ),
              
              blueRow(
                
                blueCard(
                  
                  width        = 12L,
                  src          = NULL,
                  icon         = NULL,
                  status       = NULL,
                  shadow       = TRUE,
                  border_level = 8L,
                  hover_shadow = TRUE,
                  title        = NULL,
                  
                  echarts4rOutput( "GenDAGerPlot", width = "100%"),
                  textOutput('legend_selected')
                )
              )
            )
          )
        ),
        
        blueTab(
          
          tabName = "Long-term",
          active  = FALSE,
          
          blueCard(
            
            width        = 12L,
            src          = NULL,
            icon         = icon( "cogs" ),
            status       = "default",
            shadow       = TRUE,
            border_level = 8L,
            hover_shadow = TRUE,
            title        = "Long-term",
            
            blueRow(
              
              blueColumn(
                
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
