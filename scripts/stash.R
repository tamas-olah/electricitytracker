# output$demandWAForecast <- renderPlotly( {
#   ggplotly( ggplot( data    = loadWAGer,
#                     mapping = aes( x = DateTime ) ) +
#               geom_ribbon( mapping = aes( ymin = Min, 
#                                           ymax = Max ),
#                            fill    = "#6663e7",
#                            alpha   = 0.2 ) +
#               geom_line( mapping = aes( y = Min ),
#                          color   = "#6663e7" ) +
#               geom_line( mapping = aes( y = Max ),
#                          color   = "#6663e7" ) +
#               scale_y_continuous( labels = label_number( suffix = "K", scale = 1e-3 ),
#                                   limits = c( 20000L, 80000L ) ) +
#               scale_x_datetime( breaks = "1 days", date_labels = "%b %d") +
#               theme_map() +
#               theme( legend.title = element_blank() ) ) %>% 
#     config( displayModeBar = FALSE ) %>%
#     style( hoverlabel = label ) %>%
#     layout( font = font ) } )

# output$demandDAForecast <- renderPlotly( {
#   ggplotly( ggplot( data = loadDAGer ) +
#               geom_line( mapping = aes( x = DateTime, 
#                                         y = LoadForecastDA ),
#                          color   = "#6663e7" ) +
#               scale_y_continuous( labels = label_number( suffix = "K", scale = 1e-3 ),
#                                   limits = c( 20000L, 80000L ) ) +
#               scale_x_datetime( breaks = "4 hours", date_labels = "%b %d %H:%M" ) +
#               theme_map() +
#               theme( legend.title = element_blank() ) ) %>%
#     config( displayModeBar = FALSE ) %>%
#     style( hoverlabel = label ) %>%
#     layout( font = font ) } )

# output$demandRT <- renderPlotly( {
#   ggplotly( ggplot( data = Germany[ DateTime > today( tzone = "CET" ) - 5L ] ) +
#               geom_line( mapping = aes( x     = DateTime,
#                                         y     = TotalLoad,
#                                         color = LoadType),
#                          na.rm = TRUE)  +
#               scale_y_continuous( labels = label_number( suffix = "K", scale = 1e-3 ),
#                                   limits = c( 0L, 95000L ) ) +
#               scale_x_datetime( breaks      = "1 days", 
#                                 date_labels = "%b %d %H:%M" ) +
#               scale_color_discrete( type         = c( "#ff004f", "#6663e7" ),
#                                     na.translate = TRUE ) +
#               theme_map() +
#               theme( legend.title    = element_blank(),
#                      legend.position = "bottom" ) ) %>%
#     config( displayModeBar = FALSE ) %>%
#     style( hoverlabel = label ) %>%
#     layout( font   = font,
#             legend = list( orientation = "h",
#                            x           = 0.25, 
#                            y           = -0.2 ) ) } )

# output$demandOverlay <- renderPlotly( {
#   ggplotly( ggplot() +
#               geom_line( data = Germany,
#                          mapping = aes( x     = Hour,
#                                         y     = TotalLoad,
#                                         group = Date,
#                                         color = Month ),
#                          size  = 0.1,
#                          na.rm = TRUE ) +
#               scale_y_continuous( labels = label_number( suffix = "K", scale = 1e-3 ),
#                                   limits = c( 20000L, 95000L ) ) +
#               # scale_y_continuous( labels = function( x ) format( x, big.mark = " ", scientific = FALSE ),
#               #                     limits = c( 20000L, 95000L ) ) +
#               scale_x_continuous( labels = xaxishours )  +
#               scale_color_discrete() +
#               theme_map() +
#               theme( legend.title = element_blank() ) ) %>% 
#     config( displayModeBar = FALSE ) %>%
#     style( hoverlabel = label ) %>%
#     layout( font = font ) } )

# output$demandTitle <- renderText( {
#   if ( input$dropdown == "Germany" ) {
#     return( "Germany" )
#   } else if ( input$dropdown == "France" ) {
#     return( "France" )
#   }
# } )

# output$generationRT <- renderPlotly( {
#   ggplotly( ggplot() +
#               geom_area( data    = Germany,
#                          mapping = aes( x    = DateTime, 
#                                         y    = GenerationValue,
#                                         fill = GenerationType ) ,
#                          alpha = 0.9 ) +
#               theme_map() +
#               theme( legend.title = element_blank() ) +
#               scale_y_continuous( labels = label_number( suffix = "K", scale = 1e-3 ) ) +
#               scale_x_datetime( breaks = "1 days", date_labels = "%b %d %H:%M" ) ) %>%
#     config( displayModeBar = FALSE ) %>%
#     style( hoverlabel = label ) %>%
#     layout( font = font ) } )

