demand_page <- argonTabItem(
  
  tabName = "Demand",
  
  argonRow(
  
    argonColumn(
      
      width = 12L,
      
      argonTabSet(
        
        id           = "tabDemand",
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
          
          # argonCard(
          #   
          #   title  = "Inputs",
          #   width  = 12L,
          #   icon   = icon( "cogs" ),
          #   status = "default",
          #   
          #   argonRow(
          #   
          #     argonColumn(
          #       
          #       width = 2L,
          #       tags$style( type='text/css', ".selectize-input { font-size: 12px; line-height: 22px;} .selectize-dropdown { font-size: 12px; line-height: 28px; }" ),
          #       selectInput( inputId = "dropdown",
          #                    label   = h5("COUNTRY"),
          #                    choices = c( "Germany" = "Germany",
          #                                 "France"  = "France" ) )
          #       ),
          #     
          #     argonColumn( width = 1L ),
          #     
          #     argonColumn(
          #       
          #       width = 9L,
          #       
          #       sliderInput(
          #         
          #         inputId    = "Id096",
          #         label      = h5("DATES"),
          #         min        = as.Date( "2017-01-01" ),
          #         max        = as.Date( "2021-09-28" ),
          #         value      = as.Date( c("2020-01-01", "2021-09-28") ),
          #         step       = 1L,
          #         width      = "100%",
          #         timeFormat = "%b %Y"
          #         )
          #       )
          #     )
          #   ),
          
          argonRow(
            
            argonColumn(
              
              width = 12L,
              
              argonRow(
              
              argonCard(
                
                title = NULL, #"real-time demand",
                width = 12L,
                icon  = NULL, #argonIcon( "pin-3" ),
                shadow = TRUE,
                # sliderInput(
                #   
                #   inputId    = "loadRTSelector",
                #   label      = NULL,
                #   min        = as.Date( "2017-01-01" ),
                #   max        = as.Date( "2021-09-28" ),
                #   value      = as.Date( c("2020-01-01", "2021-09-28") ),
                #   step       = 1L,
                #   width      = "100%",
                #   timeFormat = "%b %Y"
                # ),
                
                echarts4rOutput( "demandRT" )
                )
              ) )
            )
          ),
        
        argonTab(
          
          tabName = "Long-term",
          active  = FALSE,
          
          argonRow(
            
            argonColumn(
              
              width = 12L,
              
              argonRow(
              
              argonCard(
                
                title = NULL, #"Long-term demand curve",
                width = 12L,
                icon  = NULL, #argonIcon("sound-wave"),
                shadow = TRUE,
                # plotlyOutput( "demandOverlay", height = "470px", width = "100%" ),
                echarts4rOutput( "demandOverlay2", height = "470px", width = "100%" )
                )
              ) )
            
            # argonColumn(
            #   
            #   width = 3L,
            #   
            #   argonCard(
            #     
            #     title            = "Inputs",
            #     width            = 12L,
            #     icon             = icon("cogs"),
            #     status           = "default",
            #     background_color = "secondary",
            #     selectInput( inputId = "dropdown", 
            #                  label   = h5( "COUNTRY", align = "center" ), 
            #                  choices = c( "Germany" = "Germany",
            #                               "France"  = "France" ) ),
            #     sliderInput( inputId    = "Id096",
            #                  label      = h5("DATES"),
            #                  min        = as.Date( "2017-01-01" ),
            #                  max        = as.Date( "2021-09-28" ),
            #                  value      = as.Date( c("2020-01-01", "2021-09-28") ),
            #                  step       = 1L,
            #                  width      = "100%",
            #                  timeFormat = "%b %Y"
            #       ),
            #     "🚧 Under construction 🚧"
            #     )
            #   )
            )
          ),
        
        argonTab(
          
          tabName = "Forecast",
          active  = FALSE,
          
          argonRow(
            
            argonColumn(
              
              width  = 12L,
              height = "200px",
              
              argonRow(
                
                argonCard(
                  
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
            
            # argonColumn(
            #   
            #   width = 3L,
            #   
            #   argonCard(
            #     
            #     title            = "Inputs",
            #     width            = 12L,
            #     icon             = icon( "cogs" ),
            #     status           = "default",
            #     background_color = "secondary",
            #     selectInput( inputId = "dropdown", 
            #                  label   = h5( "COUNTRY", align = "center" ), 
            #                  choices = c( "Germany" = "Germany",
            #                               "France"  = "France" ) ),
            #     sliderInput(
            #       inputId    = "Id096",
            #       label      = h5("DATES"),
            #       min        = as.Date( "2017-01-01" ),
            #       max        = as.Date( "2021-09-28" ),
            #       value      = as.Date( c("2020-01-01", "2021-09-28") ),
            #       step       = 1L,
            #       width      = "100%",
            #       timeFormat = "%b %Y"
            #       ),
            #     "🚧 Under construction 🚧"
            #     )
            #   )
            ),
          
          argonRow(
            
            argonCard(
              
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
          )
        )
      )
    )
  )
