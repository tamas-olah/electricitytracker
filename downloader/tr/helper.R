######## load downloader #########

downloadLoadRT   <- function( eic_code, period_start, period_end ) {
  loadRT <- en_load_actual_total_load( eic          = eic_code,
                                       period_start = period_start,
                                       period_end   = period_end ) %>% setDT()
  
  # loadRT <- en_load_actual_total_load( eic          = "10Y1001A1001A83F",
  #                                      period_start = ymd( today(), tz = "CET" ) - days( 369L ),
  #                                      period_end   = ymd( today(), tz = "CET" ) + days( 1L ) ) %>% setDT()
  
  loadRT[ i = ,
          j = unit := NULL ]
  
  colnames( loadRT ) <- c( "DateTime", "TotalLoad", "BiddingZone" )
  
  loadRT$DateTime    <- with_tz( loadRT$DateTime, tzone = "CET" )
  
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
  
  # loadRT[ i = ,
  #         j = LoadType := "TotalLoad" ]
  
  loadRT <- loadRT[ i       = ,
                    j       = lapply( X   = .SD,
                                      FUN = mean ),
                    by      = c( "DateTime", "BiddingZone", "Date", "Year", "Month", "Hour"
                                 # , "LoadType" 
                                 ),
                    .SDcols = "TotalLoad" ]
  
  loadRT$TotalLoad <- round( loadRT$TotalLoad, digits = 0L )
  
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


######## generation downloader #########

downloadGenRT    <- function( eic_code, period_start, period_end ) {
  genRT <- en_generation_agg_gen_per_type( eic          = eic_code,
                                           period_start = period_start,
                                           period_end   = period_end ) %>% setDT()
  
  # genRT <- en_generation_agg_gen_per_type( eic          = "10Y1001A1001A83F",
  #                                          period_start = ymd( today(), tz = "CET" ) - days( 1L ),
  #                                          period_end   = ymd( today(), tz = "CET" ) + days( 1L ) ) %>% setDT()
  
  dict  <- en_generation_codes()
  
  genRT <- merge( x     = genRT,
                  y     = dict[ , c( "codes", "meaning" ) ],
                  by.x  = "MktPSRType",
                  by.y  = "codes",
                  all.x = TRUE )
  
  genRT[ i = ,
         j = MktPSRType := NULL ]
  
  genRT[ i = ,
         j = quantity_Measure_Unit.name := NULL ]
  
  colnames( genRT ) <- c( "InBiddingZone", "GenerationValue", "DateTime",
                          "OutBiddingZone", "GenerationType" )
  
  genRT$DateTime    <- with_tz( genRT$DateTime, tzone = "CET" )
  
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
                  by      = c( "DateTime", "BiddingZone", "Date", "Year", "Month", "Hour", "GenerationType" ),
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
                                  levels  = rev(levels( dt$GenerationType ) ) )

  genRT <- genRT %>% fill( BiddingZone, .direction = "down" )
  
  genRT$GenerationValue <- round( genRT$GenerationValue, digits = 0L )

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

