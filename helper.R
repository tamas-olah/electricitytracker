######## load downloader #########

downloadLoadRT <- function( eic_code, period_start, period_end ) {
  # loadRT <- en_load_actual_total_load( eic          = "10Y1001A1001A83F",
  #                                      period_start = as.POSIXct( today( tzone = "CET" ) - 369L ),
  #                                      period_end   = as.POSIXct( today( tzone = "CET" ) + 1 ) ) %>% setDT()

  loadRT <- en_load_actual_total_load( eic          = eic_code,
                                       period_start = period_start,
                                       period_end   = period_end ) %>% setDT()
  
  loadRT[ i = ,
          j = unit := NULL ]
  
  colnames( loadRT ) <- c( "DateTime", "LoadValue", "BiddingZone" )
  
  loadRT[ i = ,
          j = Date := as.Date( DateTime ) ]
  
  loadRT[ i = ,
          j = Year := as.factor( year( DateTime ) ) ]
  
  loadRT[ i = ,
          j = Month := as.factor( lubridate::month( DateTime, label = TRUE ) ) ]
  
  loadRT[ i = ,
          j = Hour := hour( DateTime ) ]

  loadRT[ i = ,
          j = DateTime := floor_date( DateTime, unit = "hours" ) ]
  
  loadRT[ i = ,
          j = LoadType := "TotalLoad" ]
  
  loadRT <- loadRT[ i       = ,
                    j       = lapply( X   = .SD,
                                      FUN = mean ),
                    by      = c( "DateTime", "BiddingZone", "Date", "Year", "Month", "Hour", "LoadType" ),
                    .SDcols = "LoadValue" ]
  
  round( loadRT$LoadValue, digits = 0L )
  
  return( loadRT )
}

downloadLoadDA <- function( eic_code, period_start, period_end ) {
  # loadDAhead <- en_load_day_ahead_total_load_forecast( eic          = "10Y1001A1001A83F",
  #                                                      period_start = as.POSIXct( today( tzone = "CET" ) ),
  #                                                      period_end   = as.POSIXct( today( tzone = "CET" ) + 3 ) ) %>% setDT()
  
  loadDAhead <- en_load_day_ahead_total_load_forecast( eic          = eic_code,
                                                       period_start = period_start,
                                                       period_end   = period_end ) %>% setDT()
  
  colnames( loadDAhead ) <- c( "DateTime", "LoadForecastDA", "Unit", "OutBiddingZone" )
  
  loadDAhead$DateTime    <- force_tz( loadDAhead$DateTime, tzone = "CET" )
  
  loadDAhead             <- loadDAhead[ DateTime > Sys.time() ]
  
  return( loadDAhead )
}

downloadLoadWA <- function( eic_code, period_start, period_end ) {
  # loadWA <- en_load_week_ahead_total_load_forecast( eic          = "10Y1001A1001A83F",
  #                                                   period_start = as.POSIXct( today( tzone = "CET" ) ),
  #                                                   period_end   = as.POSIXct( today( tzone = "CET" ) + 20 ) ) %>% setDT()

  loadWA <- en_load_week_ahead_total_load_forecast( eic          = eic_code,
                                                    period_start = period_start,
                                                    period_end   = period_end ) %>% setDT()
  
  colnames( loadWA ) <- c( "DateTime", "LoadForecastWA" )
  
  loadWA$DateTime    <- force_tz( loadWA$DateTime, tzone = "CET" )
  
  loadWA             <- loadWA[ DateTime > Sys.time() ]
  
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


######## generation real-time downloader #########

downloadGenRT  <- function( eic_code, period_start, period_end ) {
  genRT <- en_generation_agg_gen_per_type( eic          = eic_code,
                                           period_start = period_start,
                                           period_end   = period_end ) %>% setDT()
  
  # genRT <- en_generation_agg_gen_per_type( eic          = "10Y1001A1001A83F",
  #                                          period_start = as.POSIXct( Sys.Date() - 1 ),
  #                                          period_end   = as.POSIXct( Sys.Date() + 1 ) ) %>% setDT()
  
  dict  <- en_generation_codes()
  
  genRT <- merge( x     = genRT,
                  y     = dict,
                  by.x  = "MktPSRType",
                  by.y  = "codes",
                  all.x = TRUE )
  
  genRT[ i = ,
         j = MktPSRType := NULL ]
  
  genRT[ i = ,
         j = quantity_Measure_Unit.name := NULL ]
  
  genRT[ i = ,
         j = co2_g_kwh := NULL ]
  
  genRT[ i = ,
         j = efficiency := NULL ]
  
  colnames( genRT ) <- c( "InBiddingZone", "GenerationValue", "DateTime",
                          "OutBiddingZone", "GenerationType" )
  
  genRT <- genRT[ !( !is.na( OutBiddingZone ) & GenerationType %in% list( "Solar", "Wind Onshore" ) ), ]
  
  genRT[ !is.na( OutBiddingZone ), GenerationValue := -GenerationValue, ]
  genRT[ !is.na( OutBiddingZone ) & GenerationType == "Hydro Pumped Storage", GenerationType := "Hydro Pumped Storage In", ]
  genRT[  is.na( OutBiddingZone ) & GenerationType == "Hydro Pumped Storage", GenerationType := "Hydro Pumped Storage Out", ]
  
  genRT[ i = ,
         j = OutBiddingZone := NULL ]
  
  setnames( x   = genRT,
            old = "InBiddingZone",
            new = "BiddingZone" )
  
  genRT[ i = ,
         j = Date := as.Date( DateTime ) ]
  
  genRT[ i = ,
         j = Year := as.factor( year( DateTime ) ) ]
  
  genRT[ i = ,
         j = Month := as.factor( lubridate::month( DateTime, label = TRUE ) ) ]
  
  genRT[ i = ,
         j = Hour := hour( DateTime ) ]
  
  genRT[ i = ,
         j = DateTime := floor_date( DateTime, unit = "hours" ) ]
  
  genRT <- genRT[ i       = ,
                  j       = lapply( X   = .SD,
                                    FUN = mean ),
                  by      = c( "DateTime", "BiddingZone", "Date", "Year", "Month", 
                               "Hour", "GenerationType" ),
                  .SDcols = "GenerationValue" ]
  
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

  dt <- genRT[ i  = , 
               j  = .( stdev = sd( GenerationValue ) ), 
               by = "GenerationType" ]
  
  dt <- dt[ , GenerationType := reorder( GenerationType, -stdev ) ]
  
  genRT$GenerationType <- factor( x       = genRT$GenerationType,
                                  levels  = levels( dt$GenerationType ) )

  genRT <- genRT %>% fill( BiddingZone, .direction = "down" )
  
  round( genRT$GenerationValue, digits = 0L )

  return( genRT )
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




argonProfileTO <- function (..., title = NULL, subtitle = NULL, src = NULL, url = NULL, 
          url_1 = NULL, url_2 = NULL, stats) 
{
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


argonInfoCardTO <- function (value, title = NULL, stat = NULL, stat_icon = NULL, 
          description = NULL, icon, icon_background = "default", hover_lift = FALSE, 
          shadow = FALSE, background_color = NULL, gradient = FALSE, 
          width = 3) 
{
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
                                                                 shiny::fluidRow(argonR::argonColumn(shiny::tags$h5(class = paste0("card-title text-uppercase mb-0 ", 
                                                                                                                                   "text-gray"), title), shiny::span(class = paste0("h2 font-weight-bold mb-0 ", 
                                                                                                                                                                                        text_color), value)), shiny::tags$div(class = "col-auto", 
                                                                                                                                                                                                                         shiny::tags$div(class = iconCl, icon))), shiny::fluidRow(class = "mx-2 mt-3 mb-0 text-sm", 
                                                                                                                                                                                                                                                                                  if (!is.null(stat)) {
                                                                                                                                                                                                                                                                                    shiny::tagList(shiny::span(stat_icon, class = "mr-2"), 
                                                                                                                                                                                                                                                                                                   shiny::tagAppendAttributes(shiny::div(stat), 
                                                                                                                                                                                                                                                                                                                              class = "mr-2"))
                                                                                                                                                                                                                                                                                  }, shiny::span(class = paste0("mt-0 h5 ", "text-gray"), 
                                                                                                                                                                                                                                                                                                 description))))
  argonR::argonColumn(width = width, infoCardTag)
}






font <- list(
  family = "Arial Narrow",
  size = 19,
  color = "white"
)

label <- list(
  bordercolor = "transparent",
  font = font
)
# 
# monthStart <- function(x) {
#   x <- as.POSIXlt(x)
#   x$mday <- 1
#   as.Date(x)
# }


xaxishours <- function( x ){
  f <- paste0( x, ":00" )
  return( f )
}


