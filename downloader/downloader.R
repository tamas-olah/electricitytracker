library( fst          )
library( data.table   )
library( tidyverse    )
library( googledrive  )
library( lubridate    )
library( entsoeapi    )
library( googledrive  )

options( gargle_oauth_email = TRUE, gargle_oauth_cache = "electricitytracker/.secrets" )


source( "scripts/helper.R" )

countries  <- list( "10Y1001A1001A83F"   # Germany
                    # "10YFR-RTE------C"   # France
                    )

genRT      <- lapply( X            = countries,
                      FUN          = downloadGenRT,
                      period_start = ymd( today(), tz = "CET" ) - days( 200L ),
                      period_end   = ymd( today(), tz = "CET" ) + days( 1L ) )

genDA      <- lapply( X            = countries,
                      FUN          = downloadGenDA,
                      period_start = ymd( today(), tz = "CET" ),
                      period_end   = ymd( today(), tz = "CET" ) + days( 20L ) )

genDAWS    <- lapply( X            = countries,
                      FUN          = downloadGenDAWS,
                      period_start = ymd( today(), tz = "CET" ),
                      period_end   = ymd( today(), tz = "CET" ) + days( 20L ) )

loadRT     <- lapply( X            = countries,
                      FUN          = downloadLoadRT,
                      period_start = ymd( today(), tz = "CET" ) - days( 200L ),
                      period_end   = ymd( today(), tz = "CET" ) + days( 20L ) )

loadDA     <- lapply( X            = countries,
                      FUN          = downloadLoadDA,
                      period_start = ymd( today(), tz = "CET" ),
                      period_end   = ymd( today(), tz = "CET" ) + days( 20L ) )

loadWA     <- lapply( X            = countries,
                      FUN          = downloadLoadWA,
                      period_start = ymd( today(), tz = "CET" ),
                      period_end   = ymd( today(), tz = "CET" ) + days( 20L ) )

Germany    <- merge( x   = genRT[[ 1 ]],
                     y   = loadRT[[ 1 ]],
                     by  = c( "DateTime", "BiddingZone", "Date", "Year", "Month", "Hour" ),
                     all = TRUE )

renewGen   <- Germany[ i  = AggregateType %in% list( "Solar" ,"Wind", "Other renewables" ),
                       j  = .( RenewableGen = sum( GenerationValue ) ),
                       by = c( "DateTime" ) ]

Germany    <- merge( x   = Germany,
                     y   = renewGen,
                     by  = "DateTime",
                     all = TRUE )

Germany[ i  = ,
         j  = ResidualLoad := TotalLoad - RenewableGen ]

write_fst( Germany, "data_dynamic/Germany.fst" )
# Germany    <- read_fst("data_dynamic/Germany.fst", as.data.table = TRUE )

# resLoad[ i = ,
#          j = LoadType := "ResidualLoad" ]
# 
# Germany    <- merge( x   = Germany,
#                      y   = resLoad,
#                      by  = c( "DateTime", "TotalLoad", "LoadType" ),
#                      all = TRUE )


genDAGer   <- genDA[[ 1 ]]
write_fst( genDAGer, "data_dynamic/genDAGer.fst" )
# genDAGer   <- read_fst("data_dynamic/genDAGer.fst", as.data.table = TRUE )

genDAWSGer <- genDAWS[[ 1 ]]
write_fst( genDAWSGer, "data_dynamic/genDAWSGer.fst" )
# genDAWSGer <- read_fst("data_dynamic/genDAWSGer.fst", as.data.table = TRUE )

loadDAGer  <- loadDA[[ 1 ]]
write_fst( loadDAGer, "data_dynamic/loadDAGer.fst" )
# loadDAGer  <- read_fst("data_dynamic/loadDAGer.fst", as.data.table = TRUE )

loadWAGer  <- loadWA[[ 1 ]]
write_fst( loadWAGer, "data_dynamic/loadWAGer.fst" )
# loadWAGer  <- read_fst("data_dynamic/loadWAGer.fst", as.data.table = TRUE )





drive_upload( media     = "data_dynamic/Germany0929.fst", 
              path      = "Germany0929.fst",
              overwrite = TRUE )

drive_upload( media     = "data_dynamic/genDAGer.fst", 
              path      = "genDAGer.fst",
              overwrite = TRUE )

drive_upload( media     = "data_dynamic/genDAWSGer.fst", 
              path      = "genDAWSGer.fst",
              overwrite = TRUE )

drive_upload( media     = "data_dynamic/loadDAGer.fst", 
              path      = "loadDAGer.fst",
              overwrite = TRUE )

drive_upload( media     = "data_dynamic/loadWAGer.fst", 
              path      = "loadWAGer.fst",
              overwrite = TRUE )

rm( list = ls() )
invisible( gc() )



