######## generation downloader #########

downloadGenRT    <- function( eic_code, period_start, period_end ) {
  # Call function from downloader script
  genRT <- en_generation_agg_gen_per_type( eic          = eic_code,
                                           period_start = period_start,
                                           period_end   = period_end ) %>% setDT()
  # Call function from here (for testing)
  # genRT <- en_generation_agg_gen_per_type( eic          = "10Y1001A1001A83F",
  #                                          period_start = ymd( today(), tz = "CET" ) - days( 1L ),
  #                                          period_end   = ymd( today(), tz = "CET" ) + days( 1L ) ) %>% setDT()
  
  # Load EIC code dictionary
  dict  <- en_generation_codes()
  
  # Merge data table with code dictionary
  genRT <- merge( x     = genRT,
                  y     = dict[ , c( "codes", "meaning" ) ],
                  by.x  = "MktPSRType",
                  by.y  = "codes",
                  all.x = TRUE )
  
  # Remove not needed columns
  genRT[ i = ,
         j = ":=" ( MktPSRType                 = NULL, 
                    quantity_Measure_Unit.name = NULL ) ]
  
  # Renam columns
  colnames( genRT ) <- c( "InBiddingZone", "GenerationValue", "DateTime",
                          "OutBiddingZone", "GenerationType" )
  
  # Set time zone
  genRT$DateTime    <- with_tz( genRT$DateTime, tzone = "CET" )
  
  # Remove lines where OutBiddingZone variable has values AND GenerationType is Solar or Wind
  # This is necessary because these values are duplicates
  genRT <- genRT[ !( !is.na( OutBiddingZone ) & 
                       GenerationType %in% list( "Solar", "Wind Onshore" ) ), ]
  
  # Change sign of GenerationValue where OutBiddingZone is not empty
  # This is necessary because these lines denote  pumped storage consumption values
  # On plots they should be denoted as negative (as the plant is not producing but consuming electricity)
  genRT[ !is.na( OutBiddingZone ), GenerationValue := -GenerationValue, ]
  
  # Rename variable values to correspond to production or consumption
  genRT[ !is.na( OutBiddingZone ) & GenerationType == "Hydro Pumped Storage", GenerationType := "Hydro Pumped Storage In", ]
  genRT[  is.na( OutBiddingZone ) & GenerationType == "Hydro Pumped Storage", GenerationType := "Hydro Pumped Storage Out", ]
  
  # Remove and rename col since all values are now in one column (both positive and negative)
  genRT$OutBiddingZone <- NULL
  
  setnames( x   = genRT,
            old = "InBiddingZone",
            new = "BiddingZone" )
  
  # Create new date and time variables for grouping by later
  genRT[ i = ,
         j = ":=" ( Date  = as.Date( DateTime, tz = "CET" ),
                    Year  = as.factor( year( DateTime ) ),
                    Month = as.factor( month( DateTime, label = TRUE ) ),
                    Day   = as.factor( day( DateTime) ),
                    Hour  = hour( DateTime) ) ]
  
  # Flooring DateTime variable to aggregate later
  genRT[ i = ,
         j = DateTime := floor_date( DateTime, unit = "hours" ) ]
  
  # Do hourly aggregation (mean, not sum, because we're converting MW to MWh)
  genRT <- genRT[ i       = ,
                  j       = lapply( X   = .SD,
                                    FUN = mean ),
                  by      = c( "DateTime", "BiddingZone", "Date", "Year", "Month", "Day", "Hour", "GenerationType" ),
                  .SDcols = "GenerationValue" ]
  
  # Create aggregate types for display in Generation page on the dashboard
  genRT[ GenerationType %in% c( "Wind Offshore", "Wind Onshore" ), 
         AggregateType := "Wind" ]
  
  genRT[ GenerationType %in% c( "Solar" ), 
         AggregateType := "Solar" ]
  
  genRT[ GenerationType %in% c( "Biomass", "Geothermal", "Hydro Pumped Storage Out", 
                                "Hydro Run-of-river and poundage", "Hydro Water Reservoir", 
                                "Marine", "Other renewable", "Waste" ), 
         AggregateType := "Other renewables" ]
  
  genRT[ GenerationType %in% c( "Fossil Brown coal/Lignite", "Fossil Coal-derived gas", 
                                "Fossil Gas", "Fossil Hard coal", "Fossil Oil", 
                                "Fossil Oil shale", "Fossil Peat" ), 
         AggregateType := "Fossil" ]
  
  genRT[ GenerationType %in% c( "Nuclear" ), 
         AggregateType := "Nuclear" ]
  
  genRT[ GenerationType %in% c( "Other" ), 
         AggregateType := "Other" ]
  
  # Calculate standard deviation of gfeneration values
  # This is necessary because I will rank series on the plot by their standard deviation
  dt <- genRT[ i  = , 
               j  = .( stdev = sd( GenerationValue ) ), 
               by = "GenerationType" ]
  
  dt <- dt[ i = ,
            j = GenerationType := reorder( GenerationType, -stdev ) ]
  
  # Assign a factor level to each Generation type ranked by std dev
  genRT$GenerationType <- factor( x       = genRT$GenerationType,
                                  levels  = rev(levels( dt$GenerationType ) ) )
  
  genRT <- genRT %>% tidyr::fill( BiddingZone, .direction = "down" )
  
  # Round values
  genRT$GenerationValue <- round( genRT$GenerationValue, digits = 0L )
  
  # Remove not needed columns
  genRT[ i = ,
         j = ":=" ( Date  = NULL, 
                    Year  = NULL,
                    Month = NULL,
                    Day   = NULL,
                    Hour  = NULL ) ]
  
  return( genRT )
}

downloadGenDA    <- function( eic_code, period_start, period_end ) {
  genDA <- en_generation_day_ahead_agg_gen( eic          = eic_code,
                                            period_start = period_start,
                                            period_end   = period_end ) %>% setDT()
  
  # genDA <- en_generation_day_ahead_agg_gen( eic          = "10Y1001A1001A83F",
  #                                           period_start = ymd( today(), tz = "CET" ),
  #                                           period_end   = ymd( today(), tz = "CET" ) + days( 2L ) ) %>% setDT()
  
  colnames( genDA ) <- c( "BiddingZone", "Unit", "GenerationValue", "DateTime" )
  
  genDA$DateTime    <- with_tz( genDA$DateTime, tzone = "CET" )
  
  genDA             <- genDA[ DateTime > today( tzone = "CET" ) ]
  
  return( genDA )
  
}

downloadGenDAWS  <- function( eic_code, period_start, period_end ) {
  genDAWS <- en_generation_day_ahead_gen_forecast_ws( eic          = eic_code,
                                                      period_start = period_start,
                                                      period_end   = period_end ) %>% setDT()
  
  # genDAWS <- en_generation_day_ahead_gen_forecast_ws( eic          = "10Y1001A1001A83F",
  #                                                     period_start = ymd( today(), tz = "CET" ),
  #                                                     period_end   = ymd( today(), tz = "CET" ) + days( 3L ) ) %>% setDT()
  
  dict    <- en_generation_codes()
  
  genDAWS <- merge( x     = genDAWS,
                    y     = dict[ , c( "codes", "meaning" ) ],
                    by.x  = "MktPSRType",
                    by.y  = "codes",
                    all.x = TRUE )
  genDAWS[ i = ,
           j = MktPSRType := NULL ]
  
  genDAWS[ i = ,
           j = quantity_Measure_Unit.name := NULL ]
  
  colnames( genDAWS ) <- c( "BiddingZone", "GenerationValue", "DateTime", "GenerationType" )
  
  genDAWS$DateTime    <- with_tz( genDAWS$DateTime, tzone = "CET" )
  
  genDAWS             <- genDAWS[ DateTime > today( tzone = "CET" ) ]
  
  return( genDAWS )
  
}

######## load downloader #########

downloadLoadRT   <- function( eic_code, period_start, period_end ) {
  # Call function from downloader script
  loadRT <- en_load_actual_total_load( eic          = eic_code,
                                       period_start = period_start,
                                       period_end   = period_end ) %>% setDT()
  
  # Call function from here (for testing)
  # loadRT <- en_load_actual_total_load( eic          = "10Y1001A1001A83F",
  #                                      period_start = ymd( today(), tz = "CET" ) - days( 369L ),
  #                                      period_end   = ymd( today(), tz = "CET" ) + days( 1L ) ) %>% setDT()
  
  # Remove not needed column and rename others
  loadRT$unit <- NULL
  colnames( loadRT ) <- c( "DateTime", "TotalLoad", "BiddingZone" )
  
  # Set time zone
  loadRT$DateTime    <- with_tz( loadRT$DateTime, tzone = "CET" )
  
  # Create new date and time variables for grouping by later
  loadRT[ i = ,
          j = ":=" ( Date  = as.Date( DateTime, tz = "CET" ),
                     Year  = as.factor( year( DateTime ) ),
                     Month = as.factor( month( DateTime, label = TRUE ) ),
                     Day   = as.factor( day( DateTime) ),
                     Hour  = hour( DateTime) ) ]
  
  # Flooring DateTime variable to aggregate later
  loadRT[ i = ,
          j = DateTime := floor_date( DateTime, unit = "hours" ) ]
  
  # Do hourly aggregation
  loadRT <- loadRT[ i       = ,
                    j       = lapply( X   = .SD,
                                      FUN = mean ),
                    by      = c( "DateTime", "BiddingZone", "Date", 
                                 "Year", "Month", "Day", "Hour" ),
                    .SDcols = "TotalLoad" ]
  
  # Round results
  loadRT$TotalLoad <- round( loadRT$TotalLoad, digits = 0L )
  
  # Remove not needed columns
  loadRT[ i = ,
          j = ":=" ( Date  = NULL, 
                     Year  = NULL,
                     Month = NULL,
                     Day   = NULL,
                     Hour  = NULL ) ]
  
  return( loadRT )
}

downloadLoadDA   <- function( eic_code, period_start, period_end ) {
  loadDAhead <- en_load_day_ahead_total_load_forecast( eic          = eic_code,
                                                       period_start = period_start,
                                                       period_end   = period_end ) %>% setDT()
  
  # loadDAhead <- en_load_day_ahead_total_load_forecast( eic          = "10Y1001A1001A83F",
  #                                                      period_start = ymd( today(), tz = "CET" ),
  #                                                      period_end   = ymd( today(), tz = "CET" ) + days( 3L ) ) %>% setDT()
  
  colnames( loadDAhead ) <- c( "DateTime", "LoadForecastDA", "Unit", "OutBiddingZone" )
  
  loadDAhead$DateTime    <- with_tz( loadDAhead$DateTime, tzone = "CET" )
  
  loadDAhead             <- loadDAhead[ DateTime > today( tzone = "CET" ) ]
  
  return( loadDAhead )
}

downloadLoadWA   <- function( eic_code, period_start, period_end ) {
  loadWA <- en_load_week_ahead_total_load_forecast( eic          = eic_code,
                                                    period_start = period_start,
                                                    period_end   = period_end ) %>% setDT()
  
  # loadWA <- en_load_week_ahead_total_load_forecast( eic          = "10Y1001A1001A83F",
  #                                                   period_start = ymd( today(), tz = "CET" ),
  #                                                   period_end   = ymd( today(), tz = "CET" ) + days( 20L ) ) %>% setDT()

  colnames( loadWA ) <- c( "DateTime", "LoadForecastWA" )
  
  loadWA$DateTime    <- with_tz( loadWA$DateTime, tzone = "CET" )
  
  loadWA             <- loadWA[ DateTime > today( tzone = "CET" ) ]
  
  setorder( x = loadWA, cols = DateTime )
  
  loadWA[ i = ,
          j = minmax := as.data.frame( as.vector( replicate( n = length( loadWA$DateTime ) / 2, 
                                                             c( "Min", "Max" ) ) ) ) ] # @@@ replicate programmatically
  
  loadWA <- dcast( loadWA, DateTime ~ minmax, value.var = "LoadForecastWA")
  
  # loadWA <- dcast( data      = loadWA,
  #                      formula   = DateTime ~ minmax,
  #                      value.var = "LoadForecastWA" )

  return( loadWA )
}




######## ggplot theme #########
theme_map <- function(...) {
  theme_minimal() +
    theme(
      text = element_text( family = "Arial Narrow", color = "grey40" ),
      title = element_text( family = "Arial Narrow", color = "grey30" ),
      axis.line = element_blank(),
      # axis.text.x = element_blank(),
      # axis.text.y = element_blank(),
      axis.ticks = element_blank(),
      axis.title.x = element_blank(),
      axis.title.y = element_blank(),
      # panel.grid.minor = element_line(color = "grey80", size = 0.2),
      panel.grid.major = element_line(color = "grey90", size = 0.15),
      panel.grid.minor = element_blank(),
      plot.background = element_rect(fill = "transparent", color = NA), 
      panel.background = element_rect(fill = "transparent", color = NA), 
      legend.background = element_rect(fill = "transparent", color = NA),
      panel.border = element_blank(),
      ...
    )
}

# paletta1 <- c( "#66C5CC", "#F6CF71", "#F89C74", "#DCB0F2", "#87C55F", "#9EB9F3", "#FE88B1", "#C9DB74", "#8BE0A4", "#B497E7", "#D3B484", "#B3B3B3", "#66C5CC", "#F6CF71", "#F89C74", "#DCB0F2" )
# paletta2 <- c( "#E58606", "#5D69B1", "#52BCA3", "#99C945", "#CC61B0", "#24796C", "#DAA51B", "#2F8AC4", "#764E9F", "#ED645A", "#CC3A8E", "#A5AA99", "#E58606", "#5D69B1", "#52BCA3", "#99C945" )
# paletta3  <- hcl.colors(365, palette = "teal", rev = TRUE)



######## custom blue functions #########

blueProfileTO  <- function ( ..., title = NULL, subtitle = NULL, src = NULL, 
                              url = NULL, url_1 = NULL, url_2 = NULL, stats ) {
  htmltools::tags$div(class = "card card-profile shadow", 
                      htmltools::tags$div(class = "px-4", htmltools::tags$div(class = "row justify-content-center", 
                                                                              htmltools::tags$div(class = "col-lg-3 order-lg-2", 
                                                                                                  htmltools::tags$div(class = "card-profile-image", 
                                                                                                                      htmltools::a(href = NULL, htmltools::img(src = src, 
                                                                                                                                                               class = "rounded-circle")))), htmltools::tags$div(class = "col-lg-4 order-lg-3 text-lg-right align-self-lg-center", 
                                                                                                                                                                                                                 htmltools::tags$div(class = "card-profile-actions py-4 mt-lg-0", 
                                                                                                                                                                                                                                     htmltools::a(href = url_1, target = "_blank", 
                                                                                                                                                                                                                                                  class = "btn btn-sm btn-info mr-4", "LinkedIn"), 
                                                                                                                                                                                                                                     htmltools::a(href = url_2, target = "_blank", 
                                                                                                                                                                                                                                                  class = "btn btn-sm btn-default float-right", 
                                                                                                                                                                                                                                                  "GitHub"))), stats), htmltools::tags$div(class = "text-center mt-5", 
                                                                                                                                                                                                                                                                                           htmltools::h3(title), htmltools::tags$div(class = "h6 font-weight-300", 
                                                                                                                                                                                                                                                                                                                                     subtitle)), htmltools::tags$div(class = "mt-5 py-5 border-top text-center", 
                                                                                                                                                                                                                                                                                                                                                                     htmltools::tags$div(class = "row justify-content-center", 
                                                                                                                                                                                                                                                                                                                                                                                         htmltools::tags$div(class = "col-lg-9", htmltools::p(...)
                                                                                                                                                                                                                                                                                                                                                                                                             # , htmltools::a(href = url, target = "_blank", "More")
                                                                                                                                                                                                                                                                                                                                                                                                             )))))
}


blueInfoCardTO <- function ( value, title = NULL, stat = NULL, stat_icon = NULL, 
                              description = NULL, icon, icon_background = "default", 
                              hover_lift = FALSE, shadow = FALSE, background_color = NULL, 
                              gradient = FALSE, width = 3 ) {
  iconCl <- "icon icon-shape text-white rounded-circle shadow"
  if (!is.null(icon_background)) 
    iconCl <- paste0(iconCl, " bg-", icon_background)
  cardCl <- "card card-stats mb-4 mb-xl-0"
  if (hover_lift) 
    cardCl <- paste0(cardCl, " card-lift--hover")
  if (shadow) 
    cardCl <- paste0(cardCl, " shadow")
  if (gradient) {
    if (!is.null(background_color)) 
      cardCl <- paste0(cardCl, " bg-gradient-", background_color)
  }
  else {
    if (!is.null(background_color)) 
      cardCl <- paste0(cardCl, " bg-", background_color)
  }
  if (!is.null(background_color)) 
    if (background_color == "default") 
      text_color <- "text-white"
  else text_color <- NULL
  else text_color <- NULL
  infoCardTag <- shiny::tags$div(class = cardCl, shiny::tags$div(class = "card-body", 
                                                                 shiny::fluidRow(blueR::blueColumn(shiny::tags$h5(class = paste0("card-title text-uppercase mb-0 ", 
                                                                                                                                   "text-gray"), title), shiny::span(class = paste0("h2 font-weight-bold mb-0 ", 
                                                                                                                                                                                        text_color), value)), shiny::tags$div(class = "col-auto", 
                                                                                                                                                                                                                         shiny::tags$div(class = iconCl, icon))), shiny::fluidRow(class = "mx-2 mt-3 mb-0 text-sm", 
                                                                                                                                                                                                                                                                                  if (!is.null(stat)) {
                                                                                                                                                                                                                                                                                    shiny::tagList(shiny::span(stat_icon, class = "mr-2"), 
                                                                                                                                                                                                                                                                                                   shiny::tagAppendAttributes(shiny::div(stat), 
                                                                                                                                                                                                                                                                                                                              class = "mr-2"))
                                                                                                                                                                                                                                                                                  }, shiny::span(class = paste0("mt-0 h5 ", "text-gray"), 
                                                                                                                                                                                                                                                                                                 description))))
  blueR::blueColumn(width = width, infoCardTag)
}

######## misc #########

font  <- list( family = "Arial Narrow",
               size   = 19,
               color  = "white" )

label <- list( bordercolor = "transparent",
               font        = font )
# 
# monthStart <- function(x) {
#   x <- as.POSIXlt(x)
#   x$mday <- 1
#   as.Date(x)
# }


xaxishours <- function( x ) {
  f <- paste0( x, ":00" )
  return( f )
}

######## 