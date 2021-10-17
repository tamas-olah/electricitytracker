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
library( echarts4r    )
library( googledrive  )
library( stringi      )

# Google Drive authorization
options( gargle_oauth_email = TRUE, gargle_oauth_cache = "electricitytracker/.secrets" )

# Load helper functions and static data files
source( "scripts/helper.R" )
eximp      <- read_fst( path = "data_static/eximp.fst", as.data.table = TRUE )
net        <- readRDS( file = "data_static/net.rds" )

# Load dashboard elements and pages
lapply( X   = list.files( path = "elements", full.names = TRUE ),
        FUN = source )
lapply( X   = list.files( path = "pages", full.names = TRUE ),
        FUN = source )

# Set design elements
e_common( font_family = "Barlow" )
pal1 <- c( "#5e72e4", "#5eb5e4", "#8d5ee4" )

# App
shiny::shinyApp(
  
  ui = argonDashPage(
    # chooseSliderSkin( skin = "Flat", color = "#6663e7" ),
    use_font("barlow", "www/css/barlow.css", css = "font-family: 'Barlow', sans-serif;"),
    title       = "Electricity tracker",
    author      = "Tamas",
    description = NULL,
    sidebar     = dashSidebar,
    header      = dashHeader,
    body        = argonDashBody( argonTabItems( generation_page,
                                                demand_page,
                                                exim_page,
                                                data_page,
                                                map_page,
                                                # todo_page,
                                                about_page ) ),
    footer      = dashFooter ),
  
  server = function( input, output ) {
    
    # Download files from Google Drive to local folder
    lapply( X         = drive_find( pattern = "fst" )$name, 
            FUN       = function( i ) { drive_download( file      = i,
                                                        path      = paste0( "data_dynamic/", i ),
                                                        overwrite = TRUE ) } )
    
    # List downloaded files in local folder
    fileList <- list.files( path = "data_dynamic", pattern = "*.fst", full.names = TRUE )
    
    # Read downloaded files into environment (while also cleaning them up)
    list2env( lapply( X = setNames( object = fileList,
                                    nm     = make.names( stri_replace_all_regex( str         = fileList,
                                                                                 pattern     = c( "^data_dynamic/", ".fst$" ), 
                                                                                 replacement = c( "", "" ), 
                                                                                 vectorize   = FALSE ) ) ),
                      FUN           = read_fst,
                      as.data.table = TRUE ), 
              envir = .GlobalEnv )
    
    # Get time of last data refresh:
    # List files on Google Drive, get first row (any row would work), get the 
    # creation time from the list that is the third element in the row, format
    updateDate <- format( ymd_hms( drive_ls()[ 1, ]$drive_resource[[ 1 ]][ "createdTime" ], tz = "CET" ),
                          "%B %d, %H:%M %Z" )
    output$updateDate <- renderText( { updateDate } )
    
    
    
    dataGenRT <- reactive ( {
      if ( input$dropdown12 == "Germany" ) {
        genRT <- Germany
      } else if ( input$dropdown12 == "France" ) {
        genRT <- France
      }
      return( genRT )
    } )
    
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
    
    output$generationRT <- renderEcharts4r( {
      unique( dataGenRT()[ i = DateTime > ymd( today() ) - days ( 4L ),
                           j = .( DateTime, GenerationValue, GenerationType ) ] ) %>%
        group_by( GenerationType ) %>%
        e_charts( x = DateTime ) %>%
        e_area(# name   = "Generation by Type",
                # type   = "line",
                smooth = TRUE,
                symbol = "none",
                serie  = GenerationValue,
                stack  = "Total" ) %>% 
        e_grid( right = "31%" ) %>% 
        e_tooltip( trigger = "axis" ) %>% 
        e_datazoom( type  = "slider",
                    start = 50L, 
                    end   = 100L ) %>% 
        e_legend( orient   = "vertical",
                  right    = "0%",
                  top      = "center",
                  selector = list( list( type = "inverse", title = "Invert" ),
                                   list( type = "all", title = "Reset" ) ) ) %>% 
        e_title( text    = "Generation by Type", 
                 subtext = "Total generation, MWh" ) %>% 
        e_show_loading()
        } )
    
    dataGenDA <- reactive ( {
      if ( input$dropdown12 == "Germany" ) {
        genDA <- genDAGer
      } else if ( input$dropdown12 == "France" ) {
        genDA <- genDAFra
      }
      return( genDA )
    } )
    output$GenDAGerPlot <- renderEcharts4r( {
      dataGenDA() %>% 
        e_charts( x = DateTime ) %>% 
        e_line( serie = GenerationValue, smooth = TRUE ) %>% 
        e_tooltip( trigger = "axis" ) %>% 
        e_legend( show = FALSE ) %>% 
        e_title( text    = "Day-ahead generation forecast", 
                 subtext = "Total generation, MWh" ) %>% 
        e_color(pal1) %>% 
        e_datazoom( type  = "inside" )%>% 
        e_show_loading() } )
    
    dataGenDAWS <- reactive ( {
      if ( input$dropdown12 == "Germany" ) {
        genDAWS <- genDAWSGer
      } else if ( input$dropdown12 == "France" ) {
        genDAWS <- genDAWSFra
      }
      return( genDAWS )
    } )
    output$GenDAWSGerPlot <- renderEcharts4r( {
      dataGenDAWS() %>% 
        group_by( GenerationType ) %>% 
        e_charts( x = DateTime ) %>% 
        e_line( serie = GenerationValue, smooth = TRUE ) %>% 
        e_tooltip( trigger = "axis" ) %>% 
        e_legend( right = "10%" ) %>% 
        e_title( text    = "Day-ahead generation forecast", 
                 subtext = "Wind and solar generation, MWh" ) %>% 
        e_color(pal1) %>% 
        e_datazoom( type  = "inside" )%>% 
        e_show_loading() } )
    
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

    
    output$demandOverlay2 <- renderEcharts4r( {
      unique( dataGenRT()[ i = ,
                           j = .( TotalLoad, Date, Month, Hour ) ] ) %>% 
        mutate( width = 0.01 ) %>% 
        group_by( Date, Month ) %>% 
        
        e_charts( x = Hour ) %>% 
        e_line( serie  = TotalLoad,
                symbol = "none",
                smooth = TRUE,
                lineStyle = list( width = 0.5 ) ) %>% 
        e_legend( show = FALSE ) %>% 
        e_tooltip( trigger = "item" ) %>% 
        e_title( text    = "Long-term demand curve", 
                 subtext = "Total demand, MWh" ) %>% 
        e_datazoom( type  = "inside" ) %>% 
        e_add_nested( "lineStyle", width )%>% 
        e_show_loading() } )
    
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
    

    
    output$demandRT <- renderEcharts4r( {
      unique( dataGenRT()[ i = DateTime > ymd( today() ) - days ( 30 ),
                           j = .( DateTime, TotalLoad, ResidualLoad ) ] ) %>%
        e_charts( x = DateTime ) %>% 
        e_line( serie = TotalLoad, 
                symbol = "none",
                smooth = TRUE ) %>% 
        e_line( serie = ResidualLoad, smooth = TRUE, symbol = "none" ) %>%
        # e_mark_area( data = list( list(xAxis = "min", yAxis = "min"),
        #                           list(xAxis = "max", yAxis = "max") ) ) %>% 
        e_legend( right = "10%" ) %>% 
        e_tooltip( trigger = "axis" ) %>% 
        e_title( text    = "Real-time demand", 
                 subtext = "Total demand, MWh" ) %>% 
        e_color(pal1) %>% 
        e_datazoom( type  = "slider",
                    start = 80L,
                    end   = 100L )%>% 
        e_show_loading() } )
    
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
    dataLoadDA <- reactive ( {
      if ( input$dropdown12 == "Germany" ) {
        loadDA <- loadDAGer
      } else if ( input$dropdown12 == "France" ) {
        loadDA <- loadDAFra
      }
      return( loadDA )
    } )
    output$demandDAForecast <- renderEcharts4r( {
      dataLoadDA() %>%
        e_charts( x = DateTime ) %>% 
        e_line( serie = LoadForecastDA, smooth = TRUE ) %>% 
        e_tooltip( trigger = "axis" ) %>% 
        e_legend( show = FALSE ) %>% 
        e_title( text    = "Day-ahead forecast", 
                 subtext = "Total demand, MWh" ) %>% 
        e_color(pal1) %>% 
        e_datazoom( type  = "inside" )%>% 
        e_show_loading() } )
    
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
    dataLoadWA <- reactive ( {
      if ( input$dropdown12 == "Germany" ) {
        loadWA <- loadWAGer
      } else if ( input$dropdown12 == "France" ) {
        loadWA <- loadWAFra
      }
      return( loadWA )
    } )
    output$demandWAForecast <- renderEcharts4r( {
      dataLoadWA() %>%
        e_charts( x = DateTime ) %>% 
        e_line( serie  = Min, 
                smooth = TRUE ) %>% 
        e_line( serie  = Max, 
                smooth = TRUE ) %>% 
        e_tooltip( trigger = "axis" ) %>% 
        e_legend( right = "10%" ) %>% 
        e_title( text    = "Week-ahead forecast", 
                 subtext = "Total demand, MWh" ) %>% 
        e_color(pal1) %>% 
        e_datazoom( type  = "inside" )%>% 
        e_show_loading() } )
    
    output$windGen  <- renderText( {
      expr = paste0( round( dataGenRT()[ AggregateType == "Wind" & DateTime > ymd( today() ) - days ( 4L ),
                                     sum( GenerationValue ) ] / 1000000L, digits = 1L ), " TW" ) } )
    output$windPerc <- renderText( {
      expr = paste0( round( dataGenRT()[ AggregateType == "Wind" & DateTime > ymd( today() ) - days ( 4L ),
                                     sum( GenerationValue ) ] / sum( dataGenRT()[DateTime > ymd( today() ) - days ( 4L )]$GenerationValue, na.rm = TRUE ) * 100L, digits = 1L ) ) } )
    
    output$solarGen  <- renderText( {
      expr = paste0( round( dataGenRT()[ AggregateType == "Solar" & DateTime > ymd( today() ) - days ( 4L ),
                                     sum( GenerationValue ) ] / 1000000L, digits = 1L ), " TW" ) } )
    output$solarPerc <- renderText( {
      expr = paste0( round( dataGenRT()[ AggregateType == "Solar" & DateTime > ymd( today() ) - days ( 4L ),
                                     sum( GenerationValue ) ] / sum( dataGenRT()[DateTime > ymd( today() ) - days ( 4L )]$GenerationValue, na.rm = TRUE ) * 100L, digits = 1L ) ) } )

    output$fossilGen  <- renderText( {
      expr = paste0( round( dataGenRT()[ AggregateType == "Fossil" & DateTime > ymd( today() ) - days ( 4L ),
                                     sum( GenerationValue ) ] / 1000000L, digits = 1L ), " TW" ) } )
    output$fossilPerc <- renderText( {
      expr = paste0( round( dataGenRT()[ AggregateType == "Fossil" & DateTime > ymd( today() ) - days ( 4L ),
                                     sum( GenerationValue ) ] / sum( dataGenRT()[DateTime > ymd( today() ) - days ( 4L )]$GenerationValue, na.rm = TRUE ) * 100L, digits = 1L ) ) } )

    output$nuclearGen <- renderText( {
      expr = paste0( round( dataGenRT()[ AggregateType == "Nuclear" & DateTime > ymd( today() ) - days ( 4L ),
                                     sum( GenerationValue ) ] / 1000000L, digits = 1L ), " TW" ) } )
    output$nuclearPerc <- renderText( {
      expr = paste0( round( dataGenRT()[ AggregateType == "Nuclear" & DateTime > ymd( today() ) - days ( 4L ),
                                     sum( GenerationValue ) ] / sum( dataGenRT()[DateTime > ymd( today() ) - days ( 4L )]$GenerationValue, na.rm = TRUE ) * 100L, digits = 1L ) ) } )
    
    output$GermanyData <- renderDataTable( {
      
      datatable( Germany[ i = ,
                          j = .( DateTime, TotalLoad, GenerationType, GenerationValue ) ],
                 options  = list( dom = "t" ), 
                 filter   = list( position = "top" ),
                 rownames = FALSE,
                 style    = "bootstrap" ) } )
    
    # 
    # importData <- reactive( {
    #   
    # })

    importData <- reactive ( {
      if ( input$dropdown12 == "Germany" ) {
        hello <- eximp[ i  = InAreaName == "Germany",
                        j  = .( Value = abs( sum( FlowValue ) ) ),
                        by = c( "OutAreaName", "InAreaName" ) ]
      } else if ( input$dropdown12 == "France" ) {
        hello <- eximp[ i  = InAreaName == "Germany",
                        j  = .( Value = abs( sum( FlowValue ) ) ),
                        by = c( "OutAreaName", "InAreaName" ) ]
      }
      return( hello )
    } )
    output$import <- renderEcharts4r( {
      importData() %>% 
        e_charts() %>% 
        e_sankey( source    = OutAreaName,
                  target    = InAreaName,
                  value     = Value,
                  lineStyle = list( color = "gradient" ) ) %>% 
        e_color(pal1)%>% 
        e_tooltip(trigger = "item" ) %>% 
        e_show_loading() } )
    
    exportData <- reactive ( {
      if ( input$dropdown12 == "Germany" ) {
        hello <- eximp[ i  = OutAreaName == "Germany",
                        j  = .( Value = abs( sum( FlowValue ) ) ),
                        by = c( "OutAreaName", "InAreaName" ) ]
      } else if ( input$dropdown12 == "France" ) {
        hello <- eximp[ i  = OutAreaName == "Germany",
                        j  = .( Value = abs( sum( FlowValue ) ) ),
                        by = c( "OutAreaName", "InAreaName" ) ]
      }
      return( hello )
    } )
    output$export <- renderEcharts4r( {
      exportData() %>% 
        e_charts() %>% 
        e_sankey( source    = OutAreaName, 
                  target    = InAreaName,
                  value     = Value,
                  lineStyle = list( color = "gradient" ) ) %>% 
        e_color( pal1 ) %>% 
        e_tooltip(trigger = "item" ) %>%
        e_show_loading() } )
    
    
    
    output$graph <- renderEcharts4r( {
      e_charts() %>% 
        e_graph( layout    = "force",
                 force     = list( repulsion = 300,
                                   gravity   = 0.01,
                                   friction  = 0.1 ),
                 roam      = TRUE,
                 draggable = TRUE,
                 lineStyle = list( color      = "source",
                                   curveness  = 0.3 ),
                 label     = list( show       = TRUE,
                                   position   = "inside",
                                   formatter  = "{b}",
                                   color      = "#464646",
                                   fontWeight = "bold",
                                   fontSize   = 9L,
                                   textBorderColor = "white" ) ) %>%
        e_graph_nodes( nodes    = net$nodes,
                       names    = name,
                       value    = value, 
                       size     = size,
                       category = grp ) %>% 
        e_graph_edges( edges    = net$edges, 
                       source   = from,
                       target   = to,
                       value    = weight ) %>% 
        e_tooltip() %>% 
        e_toolbox_feature( "dataZoom" ) %>% 
        e_toolbox_feature( "dataView" ) %>% 
        e_toolbox_feature( "saveAsImage" ) %>% 
        e_title( text    = "European transmission network", 
                 subtext = "Bigger node means more exchange\nShorter edge means more exchange" ) %>% 
        e_legend( orient   = "vertical",
                  right    = "0%",
                  top      = "center" ) %>% 
        e_color( c("#5e72e4", "#5eb5e4", "#e45e72", "#8d5ee4" ) )
    })
    
    
    }
  )


