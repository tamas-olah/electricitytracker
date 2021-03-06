# devtools::install_github("tamas-olah/blueDash")
# devtools::install_github("tamas-olah/blueR")

library( shiny        )
library( shinyWidgets )
library( blueDash     )
library( blueR        )
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
library( leaflet      )
library( sf           )
library( rcartocolor  )



# mapData <- read_fst( "data_static/map_data.fst" )

# Google Drive authorization
options( gargle_oauth_email = TRUE, gargle_oauth_cache = "electricitytracker/.secrets" )

# Load helper functions and static data files
source( "scripts/helper.R" )
eximp      <- read_fst( path = "data_static/eximp.fst", as.data.table = TRUE )
net        <- readRDS( file = "data_static/net.rds" )

# Load dashboard elements and pages
lapply( X   = list.files( path = "elements", full.names = TRUE ),
        FUN = source )
lapply( X   = list.files( path = "pages",    full.names = TRUE ),
        FUN = source )

# Set design elements
e_common( font_family = "Barlow" )
theme_palette <- "#36648b"
carto_palette <- head( x = carto_pal( 12L, "Pastel" ), n = -1L )

# App
shiny::shinyApp(
  
  ui = blueDashPage(
    
    title       = "Electricity tracker",
    author      = "Tamas",
    description = NULL,
    sidebar     = dashSidebar,
    header      = dashHeader,
    body        = blueDashBody(
      use_font("barlow", "www/css/barlow.css", css = "font-family: 'Barlow', sans-serif;"),
      setSliderColor( color = "#36648b", sliderId = 1L ),
      chooseSliderSkin( skin = "Flat" ),
      blueTabItems( welcome_page,
                    generation_page,
                    demand_page,
                    exim_page,
                    map_page,
                    data_page,
                    about_page ) ),
    footer      = dashFooter ),
  
  server = function( input, output ) {
    
    # Fetch files from Google Drive to local folder
    lapply( X         = drive_find( pattern = "fst" )$name,
            FUN       = function( i ) { drive_download( file      = i,
                                                        path      = paste0( "data_dynamic/", i ),
                                                        overwrite = TRUE ) } )

    # List fetched files in local folder
    fileList <- list.files( path = "data_dynamic", pattern = "*.fst", full.names = TRUE )
    
    # Read fetched files into environment
    list2env( lapply( X = setNames( object = fileList,
                                    nm     = make.names( stri_replace_all_regex( str         = fileList,
                                                                                 pattern     = c( "^data_dynamic/", ".fst$" ), 
                                                                                 replacement = c( "", "" ), 
                                                                                 vectorize   = FALSE ) ) ),
                      FUN           = read_fst,
                      as.data.table = TRUE ), 
              envir = .GlobalEnv )
    
    setnames( x = Germany, old = "TotalLoad",    new = "Total Demand" )
    setnames( x = Germany, old = "ResidualLoad", new = "Residual Demand" )
    setnames( x = France,  old = "TotalLoad",    new = "Total Demand" )
    setnames( x = France,  old = "ResidualLoad", new = "Residual Demand" )
    
    # Get time of last data refresh:
    # List files on Google Drive, get first row (any row would work), get the 
    # creation time from the list that is the third element in the row, format
    updateDate <- format( ymd_hms( drive_ls()[ 1, ]$drive_resource[[ 1 ]][ "createdTime" ], tz = "CET" ),
                          "%B %d, %H:%M %Z" )
    output$updateDate <- renderText( { updateDate } )
    
    
    ######################################################################
    #####                GENERATION REAL-TIME                        #####
    ######################################################################
    
    dataGenLoadRT <- reactive ( {
      if ( input$dropdown12 == "Germany" ) 
        { dataGenLoadRT <- Germany } 
      else if ( input$dropdown12 == "France" ) 
        { dataGenLoadRT <- France }
      return( dataGenLoadRT ) } )
    
    output$generationRT <- renderEcharts4r( {
      unique( dataGenLoadRT()[ i = DateTime %between% input$genslider,
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
        # e_datazoom( type  = "slider",
        #             start = 50L, 
        #             end   = 100L ) %>% 
        e_legend( orient   = "vertical",
                  right    = "0%",
                  top      = "center",
                  selector = list( list( type = "inverse", title = "Invert" ),
                                   list( type = "all", title = "Reset" ) ) ) %>% 
        e_title( text    = "Generation by Type", 
                 subtext = "Total generation, MWh" ) %>% 
        e_show_loading()
        } )
    
        
    
    
    
    
    ######################################################################
    #####                GENERATION FORECAST DAY-AHEAD               #####
    ######################################################################
    
    dataGenDA <- reactive ( {
      if ( input$dropdown12 == "Germany" )
        { dataGenDA <- genDAGer }
      else if ( input$dropdown12 == "France" )
        { dataGenDA <- genDAFra }
      return( dataGenDA ) } )
    
    output$GenDAGerPlot <- renderEcharts4r( {
      dataGenDA() %>% 
        e_charts( x = DateTime ) %>% 
        e_line( serie = GenerationValue, smooth = TRUE ) %>% 
        e_tooltip( trigger = "axis" ) %>% 
        e_legend( show = FALSE ) %>% 
        e_title( text    = "Day-ahead generation forecast", 
                 subtext = "Total generation, MWh" ) %>% 
        e_color( carto_palette ) %>% 
        e_datazoom( type  = "inside" ) %>% 
        e_show_loading() } )
    
    output$legend_selected <- renderText( { 
      input$GenDAGerPlot_mouseover_data
      } )
    
    
    ######################################################################
    #####                GENERATION FORECAST WIND & SOLAR            #####
    ######################################################################
    
    dataGenDAWS <- reactive ( {
      if ( input$dropdown12 == "Germany" )
        { dataGenDAWS <- genDAWSGer } 
      else if ( input$dropdown12 == "France" ) 
        { dataGenDAWS <- genDAWSFra }
      return( dataGenDAWS ) } )
    
    output$GenDAWSGerPlot <- renderEcharts4r( {
      dataGenDAWS() %>% 
        group_by( GenerationType ) %>% 
        e_charts( x = DateTime ) %>% 
        e_line( serie = GenerationValue, smooth = TRUE ) %>% 
        e_tooltip( trigger = "axis" ) %>% 
        e_legend( right = "10%" ) %>% 
        e_title( text    = "Day-ahead generation forecast", 
                 subtext = "Wind and solar generation, MWh" ) %>% 
        e_color( carto_palette[ c( 2, 1, 6 ) ] ) %>% 
        e_datazoom( type  = "inside" )%>% 
        e_show_loading() } )
    

    ######################################################################
    #####                LOAD LONG-TERM CURVE                        #####
    ######################################################################
    
    output$demandOverlay2 <- renderEcharts4r( {
      unique( dataGenLoadRT()[ i = ,
                           j = .( `Total Demand`, Date, Month, Hour ) ] ) %>% 
        mutate( width = 0.01 ) %>% 
        group_by( Date, Month ) %>% 
        e_charts( x = Hour ) %>% 
        e_line( serie  = `Total Demand`,
                symbol = "none",
                smooth = TRUE,
                lineStyle = list( width = 0.5 ) ) %>% 
        e_legend( show = FALSE ) %>% 
        e_tooltip( trigger = "item" ) %>% 
        e_title( text    = "Long-term demand curve", 
                 subtext = "Total demand, MW" ) %>% 
        e_datazoom( type  = "inside" ) %>% 
        e_add_nested( "lineStyle", width )%>% 
        e_show_loading() } )
    

    ######################################################################
    #####                LOAD REAL-TIME                              #####
    ######################################################################
    
    output$demandRT <- renderEcharts4r( {
      unique( dataGenLoadRT()[ i = DateTime > ymd( today() ) - days ( 30 ),
                           j = .( DateTime, `Total Demand`, `Residual Demand` ) ] ) %>%
        e_charts( x = DateTime ) %>% 
        e_line( serie = `Total Demand`, 
                symbol = "none",
                smooth = TRUE ) %>% 
        e_line( serie = `Residual Demand`, smooth = TRUE, symbol = "none" ) %>%
        # e_mark_area( data = list( list(xAxis = "min", yAxis = "min"),
        #                           list(xAxis = "max", yAxis = "max") ) ) %>% 
        e_legend( right = "10%" ) %>% 
        e_tooltip( trigger = "axis" ) %>% 
        e_title( text    = "Real-time demand", 
                 subtext = "Total demand, MWh" ) %>% 
        e_color( c( theme_palette[ 1 ], carto_palette[ 7 ] ) ) %>% 
        e_datazoom( type  = "slider",
                    start = 80L,
                    end   = 100L )%>% 
        e_show_loading() } )
    
    
    ######################################################################
    #####                LOAD FORECAST DAY-AHEAD                     #####
    ######################################################################
    
    dataLoadDA <- reactive ( {
      if ( input$dropdown12 == "Germany" ) 
        { dataLoadDA <- loadDAGer }
      else if ( input$dropdown12 == "France" )
        { dataLoadDA <- loadDAFra }
      return( dataLoadDA ) } )
    
    output$demandDAForecast <- renderEcharts4r( {
      dataLoadDA() %>%
        e_charts( x = DateTime ) %>% 
        e_line( serie = LoadForecastDA, smooth = TRUE ) %>% 
        e_tooltip( trigger = "axis" ) %>% 
        e_legend( show = FALSE ) %>% 
        e_title( text    = "Day-ahead demand forecast", 
                 subtext = "Total demand, MW" ) %>% 
        e_color( theme_palette[ 1 ] ) %>% 
        e_datazoom( type  = "inside" ) %>%
        e_show_loading() } )
    
    
    ######################################################################
    #####                LOAD FORECAST WEEK-AHEAD                    #####
    ######################################################################
    
    dataLoadWA <- reactive ( {
      if ( input$dropdown12 == "Germany" )
        { dataLoadWA <- loadWAGer } 
      else if ( input$dropdown12 == "France" ) 
        { dataLoadWA <- loadWAFra }
      return( dataLoadWA ) } )
    
    output$demandWAForecast <- renderEcharts4r( {
      dataLoadWA() %>%
        e_charts( x = DateTime ) %>% 
        e_line( serie  = Min, 
                smooth = TRUE ) %>% 
        e_line( serie  = Max, 
                smooth = TRUE ) %>% 
        e_tooltip( trigger = "axis" ) %>% 
        e_legend( right = "10%" ) %>% 
        e_title( text    = "Week-ahead demand forecast", 
                 subtext = "Total demand, MW" ) %>% 
        e_color( c( theme_palette[ 1 ], carto_palette[ 7 ] ) ) %>% 
        e_datazoom( type  = "inside" )%>% 
        e_show_loading() } )
    
    
    ######################################################################
    #####                GENERATION INFO BOXES                       #####
    ######################################################################
    
    output$windGen  <- renderText( {
      expr = paste0( round( dataGenLoadRT()[ AggregateType == "Wind" & DateTime %between% input$genslider,
                                     sum( GenerationValue ) ] / 1000000L, digits = 1L ), " TWh" ) } )
    output$windPerc <- renderText( {
      expr = paste0( round( dataGenLoadRT()[ AggregateType == "Wind" & DateTime %between% input$genslider,
                                     sum( GenerationValue ) ] / sum( dataGenLoadRT()[DateTime %between% input$genslider]$GenerationValue, na.rm = TRUE ) * 100L, digits = 1L ) ) } )
    
    output$solarGen  <- renderText( {
      expr = paste0( round( dataGenLoadRT()[ AggregateType == "Solar" & DateTime %between% input$genslider,
                                     sum( GenerationValue ) ] / 1000000L, digits = 1L ), " TWh" ) } )
    output$solarPerc <- renderText( {
      expr = paste0( round( dataGenLoadRT()[ AggregateType == "Solar" & DateTime %between% input$genslider,
                                     sum( GenerationValue ) ] / sum( dataGenLoadRT()[DateTime %between% input$genslider]$GenerationValue, na.rm = TRUE ) * 100L, digits = 1L ) ) } )

    output$fossilGen  <- renderText( {
      expr = paste0( round( dataGenLoadRT()[ AggregateType == "Fossil" & DateTime %between% input$genslider,
                                     sum( GenerationValue ) ] / 1000000L, digits = 1L ), " TWh" ) } )
    output$fossilPerc <- renderText( {
      expr = paste0( round( dataGenLoadRT()[ AggregateType == "Fossil" & DateTime %between% input$genslider,
                                     sum( GenerationValue ) ] / sum( dataGenLoadRT()[DateTime %between% input$genslider]$GenerationValue, na.rm = TRUE ) * 100L, digits = 1L ) ) } )

    output$nuclearGen <- renderText( {
      expr = paste0( round( dataGenLoadRT()[ AggregateType == "Nuclear" & DateTime %between% input$genslider,
                                     sum( GenerationValue ) ] / 1000000L, digits = 1L ), " TWh" ) } )
    output$nuclearPerc <- renderText( {
      expr = paste0( round( dataGenLoadRT()[ AggregateType == "Nuclear" & DateTime %between% input$genslider,
                                     sum( GenerationValue ) ] / sum( dataGenLoadRT()[DateTime %between% input$genslider]$GenerationValue, na.rm = TRUE ) * 100L, digits = 1L ) ) } )
    
    
    ######################################################################
    #####                DATA TABLE                                  #####
    ######################################################################
    
    output$GermanyData <- renderDataTable( {
      
      datatable( dataGenLoadRT()[ i = ,
                          j = .( DateTime, `Total Demand`, GenerationType, GenerationValue ) ],
                 options  = list( dom = "t" ), 
                 filter   = list( position = "top" ),
                 rownames = FALSE,
                 style    = "bootstrap" ) } )
    

    
    ######################################################################
    #####                EXPORT / IMPORT SANKEY                      #####
    ######################################################################
    
    # Imports
    importData <- reactive ( {
      if ( input$dropdown12 == "Germany" ) 
        { hello <- eximp[ i  = InAreaName == "Germany",
                          j  = .( Value = abs( sum( FlowValue ) ) ),
                          by = c( "OutAreaName", "InAreaName" ) ] } 
      else if ( input$dropdown12 == "France" ) 
        { hello <- eximp[ i  = InAreaName == "Germany",
                          j  = .( Value = abs( sum( FlowValue ) ) ),
                          by = c( "OutAreaName", "InAreaName" ) ] }
      return( hello ) } )
    
    output$import <- renderEcharts4r( {
      importData() %>% 
        e_charts() %>% 
        e_sankey( source    = OutAreaName,
                  target    = InAreaName,
                  value     = Value,
                  lineStyle = list( color = "gradient" ) ) %>% 
        e_color( carto_palette ) %>% 
        e_tooltip( trigger = "item" ) %>% 
        e_show_loading() } )
    
    # Exports
    exportData <- reactive ( {
      if ( input$dropdown12 == "Germany" ) 
        { hello <- eximp[ i  = OutAreaName == "Germany",
                          j  = .( Value = abs( sum( FlowValue ) ) ),
                          by = c( "OutAreaName", "InAreaName" ) ] }
      else if ( input$dropdown12 == "France" ) 
        { hello <- eximp[ i  = OutAreaName == "Germany",
                          j  = .( Value = abs( sum( FlowValue ) ) ),
                          by = c( "OutAreaName", "InAreaName" ) ] }
      return( hello ) } )
    
    output$export <- renderEcharts4r( {
      exportData() %>% 
        e_charts() %>% 
        e_sankey( source    = OutAreaName, 
                  target    = InAreaName,
                  value     = Value,
                  lineStyle = list( color = "gradient" ) ) %>% 
        e_color( carto_palette ) %>% 
        e_tooltip( trigger = "item" ) %>%
        e_show_loading() } )
    
    
    ######################################################################
    #####                EXPORT / IMPORT NETWORK                     #####
    ######################################################################
    
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
                                   fontSize   = 10L,
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
        e_color( carto_palette )
      } )
    

    # boundingBox <- reactive ( {
    #   if ( input$dropdown12 == "Germany" )
    #   { boundingBox <- c(5.98865807458, 47.3024876979, 15.0169958839, 54.983104153) }
    #   else if ( input$dropdown12 == "France" )
    #   { boundingBox <- c( -5.22, 41.33, 9.55, 51.2 ) }
    #   return( boundingBox ) } )

    output$Explorer_Map <- renderLeaflet({
      leaflet() %>%
        fitBounds(5.98865807458, 47.3024876979, 15.0169958839, 54.983104153) %>% 
        addTiles() %>%  
        addProviderTiles(providers$CartoDB.Positron)
      })

    # leafletProxy("Explorer_Map") %>% 
    #   clearGroup("Links") %>% 
    #   clearGroup("HEX") %>%
    #   clearGroup("Selected_Links") %>% 
    #   removeControl("HEXLegend") %>%
    #   removeControl("Links_Legend") %>%
    #   
    #   addPolylines(data=arrange(Data_to_Display_Dual_Direction(),Passengers),
    #                group = "Links",
    #                label = ~paste0(stri_trans_general(First_Location, id = "Title")," to/from ",stri_trans_general(Second_Location, id = "Title"),": ",Passengers," Trip(s)"),
    #                color = ~dirPal(Passengers),
    #                opacity = 1,
    #                weight = ~sqrt(scale(Passengers,center = -10, log10(max(Passengers))))/2,
    #                highlightOptions = highlightOptions(color = "Black",weight = 4, bringToFront = F, opacity = 1),
    #                options = pathOptions(pane = "Links_All")) %>% 
    #   leafl
    
    }
  )


