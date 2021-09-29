library( shiny        )
library( shinyWidgets )
library( argonR       )
library( argonDash    )
library( fst          )
library( data.table   )
library( tidyverse    )
library( lubridate    )
library( plotly       )
library( gfonts       )
library( scales       )
library( DT           )
library( entsoeapi    )

source( "helper.R" )

countries <- list( "10Y1001A1001A83F"   # Germany
                   # "10YFR-RTE------C"
                   )  # France

# genRT   <- lapply( X            = countries,
#                    FUN          = downloadGenRT,
#                    period_start = as.POSIXct( Sys.Date() - 5 ),
#                    period_end   = as.POSIXct( Sys.Date() + 1 ) )
# 
# loadRT  <- lapply( X            = countries,
#                    FUN          = downloadLoadRT,
#                    period_start = as.POSIXct( today( tzone = "CET" ) - 360 ),
#                    period_end   = as.POSIXct( today( tzone = "CET" ) + 1 ) )
# 
# Germany   <- merge( x   = genRT[[ 1 ]],
#                     y   = loadRT[[ 1 ]],
#                     by  = c( "DateTime", "BiddingZone", "Date", "Year", "Month", "Hour" ),
#                     all = TRUE )

# write_fst(Germany, "data/Germany0928.fst")
Germany <- read_fst("data/Germany0928.fst", as.data.table = TRUE )

Germany[ i  = AggregateType %in% list( "Solar" ,"Wind", "Other renewables" ),
         j  = RenewGen := sum( GenerationValue ),
         by = DateTime ]

resLoad <- Germany[ i  = ,
                    j  = .( LoadValue = LoadValue - RenewGen ),
                    by = DateTime ]

resLoad <- na.omit(resLoad)

resLoad <- resLoad[ i       = ,
                    j       = lapply( X = .SD, FUN = mean ),
                    by      = "DateTime",
                    .SDcols = "LoadValue" ]

resLoad[ i = ,
         j = LoadType := "ResidualLoad" ]

Germany <- merge( x   = Germany,
                  y   = resLoad,
                  by  = c( "DateTime", "LoadValue", "LoadType" ),
                  all = TRUE )


# France    <- merge( x   = genRT[[ 2 ]],
#                     y   = loadRT[[ 2 ]],
#                     by  = c( "DateTime", "Date", "Year", "Month", "Hour" ),
#                     all = TRUE )

# loadDAhead <- lapply( X            = countries,
#                       FUN          = downloadLoadDA,
#                       period_start = as.POSIXct( today( tzone = "CET" ) ),
#                       period_end   = as.POSIXct( today( tzone = "CET" ) + 3 ) )
# 
# loadDAGer <- loadDAhead[[ 1 ]]
# loadDAFra <- loadDAhead[[ 2 ]]
# write_fst(loadDAGer, "data/loadDAGer.fst")
loadDAGer <- read_fst("data/loadDAGer.fst", as.data.table = TRUE )


# loadWA <- lapply( X            = countries,
#                   FUN          = downloadLoadWA,
#                   period_start = as.POSIXct( today( tzone = "CET" ) ),
#                   period_end   = as.POSIXct( today( tzone = "CET" ) + 20 ) )
# 
# loadWAGer <- loadWA[[ 1 ]]
# loadWAFra <- loadWA[[ 2 ]]
# write_fst(loadWAGer, "data/loadWAGer.fst")
loadWAGer <- read_fst("data/loadWAGer.fst", as.data.table = TRUE )

rm( Packages, InstPackages, UninstPackages, countries, loadRT, genRT, loadDAhead, loadWA )
invisible( gc() )

updateDate <- format ( file.info( "app.R" )$mtime, "%b %d, %I:%M%P %Z" )

lapply( X   = list.files( path = "elements", full.names = TRUE ),
        FUN = source )

lapply( X   = list.files( path = "pages", full.names = TRUE ),
        FUN = source )


shiny::shinyApp(
  
  ui = argonDashPage(
    
    chooseSliderSkin( skin = "Flat", color = "#6663e7" ),
    title       = "Electricity tracker",
    author      = "Tamas",
    description = NULL,
    sidebar     = dashSidebar,
    header      = dashHeader,
    body        = argonDashBody( argonTabItems( generation_page,
                                                demand_page,
                                                exim_page,
                                                data_page,
                                                todo_page,
                                                about_page ) ),
    footer      = dashFooter ),
  
  server = function( input, output ) {
    
    output$Refresh1 <- renderText( { updateDate } )
    
    # data_source <- reactive ( {
    #   if ( input$radio1 == "Germany" ) {
    #     data <- Germany
    #   } else if ( input$radio1 == "France" ) {
    #     data <- France
    #   }
    #   return( data )
    # } )
    
    # output$demandTitle <- renderText( {
    #   if ( input$dropdown == "Germany" ) {
    #     return( "Germany" )
    #   } else if ( input$dropdown == "France" ) {
    #     return( "France" )
    #   }
    # } )
    
    output$generationRT <- renderPlotly( {
      ggplotly( ggplot() +
                  geom_area( data    = Germany,
                             mapping = aes( x    = DateTime, 
                                            y    = GenerationValue,
                                            fill = GenerationType ) ,
                             alpha = 0.9 ) +
                  theme_map() +
                  theme( legend.title = element_blank() ) +
                  scale_y_continuous( labels = label_number( suffix = "K", scale = 1e-3 ) ) +
                  scale_x_datetime( breaks = "1 days", date_labels = "%b %d %H:%M" ) ) %>%
        config( displayModeBar = FALSE ) %>%
        style( hoverlabel = label ) %>%
        layout( font = font ) } )
    
    output$demandOverlay <- renderPlotly( {
      ggplotly( ggplot() +
                  geom_line( data = Germany,
                             mapping = aes( x     = Hour,
                                            y     = LoadValue,
                                            group = Date,
                                            color = Month ),
                             size  = 0.1,
                             na.rm = TRUE ) +
                  scale_y_continuous( labels = label_number( suffix = "K", scale = 1e-3 ),
                                      limits = c( 20000L, 95000L ) ) +
                  # scale_y_continuous( labels = function( x ) format( x, big.mark = " ", scientific = FALSE ),
                  #                     limits = c( 20000L, 95000L ) ) +
                  scale_x_continuous( labels = xaxishours )  +
                  scale_color_discrete() +
                  theme_map() +
                  theme( legend.title = element_blank() ) ) %>% 
        config( displayModeBar = FALSE ) %>%
        style( hoverlabel = label ) %>%
        layout( font = font ) } )
    
    output$demandRT <- renderPlotly( {
      ggplotly( ggplot( data = Germany[ DateTime > today( tzone = "CET" ) - 5L ] ) +
                  geom_line( mapping = aes( x     = DateTime,
                                            y     = LoadValue,
                                            color = LoadType),
                             na.rm = TRUE)  +
                  scale_y_continuous( labels = label_number( suffix = "K", scale = 1e-3 ),
                                      limits = c( 0L, 95000L ) ) +
                  scale_x_datetime( breaks      = "1 days", 
                                    date_labels = "%b %d %H:%M" ) +
                  scale_color_discrete( type         = c( "#ff004f", "#6663e7" ),
                                        na.translate = TRUE ) +
                  theme_map() +
                  theme( legend.title    = element_blank(),
                         legend.position = "bottom" ) ) %>%
        config( displayModeBar = FALSE ) %>%
        style( hoverlabel = label ) %>%
        layout( font   = font,
                legend = list( orientation = "h",
                               x           = 0.25, 
                               y           = -0.2 ) ) } )
    
    output$demandDAForecast <- renderPlotly( {
      ggplotly( ggplot( data = loadDAGer ) +
                  geom_line( mapping = aes( x = DateTime, 
                                            y = LoadForecastDA ),
                             color   = "#6663e7" ) +
                  scale_y_continuous( labels = label_number( suffix = "K", scale = 1e-3 ),
                                      limits = c( 20000L, 80000L ) ) +
                  scale_x_datetime( breaks = "4 hours", date_labels = "%b %d %H:%M" ) +
                  theme_map() +
                  theme( legend.title = element_blank() ) ) %>%
        config( displayModeBar = FALSE ) %>%
        style( hoverlabel = label ) %>%
        layout( font = font ) } )
    
    output$demandWAForecast <- renderPlotly( {
      ggplotly( ggplot( data    = loadWAGer,
                        mapping = aes( x = DateTime ) ) +
                  geom_ribbon( mapping = aes( ymin = Min, 
                                              ymax = Max ),
                               fill    = "#6663e7",
                               alpha   = 0.2 ) +
                  geom_line( mapping = aes( y = Min ),
                             color   = "#6663e7" ) +
                  geom_line( mapping = aes( y = Max ),
                             color   = "#6663e7" ) +
                  scale_y_continuous( labels = label_number( suffix = "K", scale = 1e-3 ),
                                      limits = c( 20000L, 80000L ) ) +
                  scale_x_datetime( breaks = "1 days", date_labels = "%b %d") +
                  theme_map() +
                  theme( legend.title = element_blank() ) ) %>% 
        config( displayModeBar = FALSE ) %>%
        style( hoverlabel = label ) %>%
        layout( font = font ) } )
    
    output$windGen  <- renderText( {
      expr = paste0( round( Germany[ AggregateType == "Wind", sum( GenerationValue ) ] / 1000L, digits = 0L ), " GW" ) } )
    output$windPerc <- renderText( {
      expr = paste0( round( Germany[ AggregateType == "Wind", sum( GenerationValue ) ] / sum( Germany$GenerationValue, na.rm = TRUE ) * 100L, digits = 1L ) ) } )
    
    output$solarGen  <- renderText( {
      expr = paste0( round( Germany[ AggregateType == "Solar", sum( GenerationValue ) ] / 1000L, digits = 0L ), " GW" ) } )
    output$solarPerc <- renderText( {
      expr = paste0( round( Germany[ AggregateType == "Solar", sum( GenerationValue ) ] / sum( Germany$GenerationValue, na.rm = TRUE ) * 100L, digits = 1L ) ) } )

    output$fossilGen  <- renderText( {
      expr = paste0( round( Germany[ AggregateType == "Fossil", sum( GenerationValue ) ] / 1000L, digits = 0L ), " GW" ) } )
    output$fossilPerc <- renderText( {
      expr = paste0( round( Germany[ AggregateType == "Fossil", sum( GenerationValue ) ] / sum( Germany$GenerationValue, na.rm = TRUE ) * 100L, digits = 1L ) ) } )

    output$nuclearGen <- renderText( {
      expr = paste0( round( Germany[ AggregateType == "Nuclear", sum( GenerationValue ) ] / 1000L, digits = 0L ), " GW" ) } )
    output$nuclearPerc <- renderText( {
      expr = paste0( round( Germany[ AggregateType == "Nuclear", sum( GenerationValue ) ] / sum( Germany$GenerationValue, na.rm = TRUE ) * 100L, digits = 1L ) ) } )
    
    output$GermanyData <- renderDataTable( {
      
      datatable( Germany[ i = ,
                          j = .( DateTime, LoadValue, LoadType, 
                                 GenerationType, GenerationValue ) ],
                 options  = list( dom = "t" ), 
                 filter   = list( position = "top" ),
                 rownames = FALSE,
                 style    = "bootstrap" ) } 
      ) 
    }
  )


