demand_page <- blueTabItem(
  
  tabName = "Demand",
  
  blueRow(
  
    blueColumn(
      
      width = 12L,
      
      blueTabSet(
        
        id           = "tabDemand",
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
            
            blueColumn(
              
              width = 12L,
              
              blueRow(
                
                blueCard(
                  
                  title  = NULL,
                  width  = 12L,
                  icon   = NULL,
                  shadow = TRUE,
                
                  echarts4rOutput( "demandRT" ),
                  
                  br(),
                  
                  blueButton( name          = "What is this?",
                               status       = "danger",
                               icon         = icon("bell"),
                               size         = "sm",
                               toggle_modal = TRUE,
                               modal_id     = "modalDemandRT" ),
                  
                  blueModal( id        = "modalDemandRT",
                              title    = "What is “residual load”?",
                              status   = "default",
                              gradient = TRUE,
                              "Residual load refers to the demand for electrical power (“TotalLoad”) in a power grid after eliminating the share of fluctuating feed-in from supply-dependent generators such as wind farms and photovoltaic plants. The residual load thus represents the demand that must be met by the available, dispatchable power plants (such as storage power plants and thermal power plants)." )
                  )
                )
              )
            )
          ),
        
        blueTab(
          
          tabName = "Forecast",
          active  = FALSE,
          
          blueRow(
            
            blueColumn(
              
              width  = 12L,
              height = "200px",
              
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
                  
                  echarts4rOutput( "demandDAForecast", height = "300px" )
                )
              )
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
              
              echarts4rOutput( "demandWAForecast", height = "300px" )
            )
          )
        ),
        
        blueTab(
          
          tabName = "Long-term",
          active  = FALSE,
          
          blueRow(
            
            blueColumn(
              
              width = 12L,
              
              blueRow(
                
                blueCard(
                
                  title  = NULL,
                  width  = 12L,
                  icon   = NULL,
                  shadow = TRUE,
                  
                  echarts4rOutput( "demandOverlay2", height = "470px", width = "100%" ),
                  
                  br(),
                  
                  blueButton( name         = "What is this?",
                               status       = "danger",
                               icon         = icon("bell"),
                               size         = "sm",
                               toggle_modal = TRUE,
                               modal_id     = "modal2" ),
                  
                  blueModal( id       = "modal2",
                              title    = "What is a long term demand curve?",
                              status   = "default",
                              gradient = TRUE,
                              "" )
                  )
                )
              )
            )
          )
        )
      )
    )
  )
