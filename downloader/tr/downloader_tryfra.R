
Packages       <- c( "fst", "data.table", "tidyverse", "googledrive", "lubridate" )

InstPackages   <- rownames( installed.packages() )

UninstPackages <- Packages[ !Packages %in% InstPackages ]
if ( length( UninstPackages ) > 0L ) {
  install.packages( UninstPackages,
                    quiet = TRUE )
}

suppressPackageStartupMessages( sapply( Packages,
                                        library,
                                        character.only = TRUE,
                                        quietly        = TRUE,
                                        logical.return = TRUE ) )

library( entsoeapi    )

options( gargle_oauth_email = TRUE, gargle_oauth_cache = "/root/tr/tr/.secrets" )


source( "/root/tr/helper.R" )

countries  <- list( "10Y1001A1001A83F",  # Germany
                    "10YFR-RTE------C"   # France
                    )
tryCatch(
genRT      <- lapply( X            = countries,
                      FUN          = downloadGenRT,
                      period_start = ymd( today(), tz = "CET" ) - days( 200L ),
                      period_end   = ymd( today(), tz = "CET" ) + days( 1L ) ),
error = function(e) print("data error") )

tryCatch(
  genDA      <- lapply( X            = countries,
                        FUN          = downloadGenDA,
                        period_start = ymd( today(), tz = "CET" ),
                        period_end   = ymd( today(), tz = "CET" ) + days( 20L ) ),
  error = function(e) print("data error") )

tryCatch(
genDAWS    <- lapply( X            = countries,
                      FUN          = downloadGenDAWS,
                      period_start = ymd( today(), tz = "CET" ),
                      period_end   = ymd( today(), tz = "CET" ) + days( 20L ) ),
error = function(e) print("data error") )

tryCatch(
loadRT     <- lapply( X            = countries,
                      FUN          = downloadLoadRT,
                      period_start = ymd( today(), tz = "CET" ) - days( 200L ),
                      period_end   = ymd( today(), tz = "CET" ) + days( 20L ) ),
error = function(e) print("data error") )

tryCatch(
loadDA     <- lapply( X            = countries,
                      FUN          = downloadLoadDA,
                      period_start = ymd( today(), tz = "CET" ),
                      period_end   = ymd( today(), tz = "CET" ) + days( 20L ) ),
error = function(e) print("data error") )

tryCatch(
loadWA     <- lapply( X            = countries,
                      FUN          = downloadLoadWA,
                      period_start = ymd( today(), tz = "CET" ),
                      period_end   = ymd( today(), tz = "CET" ) + days( 20L ) ),
error = function(e) print("data error") )








tryCatch(
Germany    <- merge( x   = genRT[[ 1 ]],
                     y   = loadRT[[ 1 ]],
                     by  = c( "DateTime", "BiddingZone", "Date", "Year", "Month", "Hour" ),
                     all = TRUE ),
error = function(e) print("data error") )

tryCatch(
renewGen   <- Germany[ i  = AggregateType %in% list( "Solar" ,"Wind", "Other renewables" ),
                       j  = .( RenewableGen = sum( GenerationValue ) ),
                       by = c( "DateTime" ) ],
error = function(e) print("data error") )

tryCatch(
Germany    <- merge( x   = Germany,
                     y   = renewGen,
                     by  = "DateTime",
                     all = TRUE ),
error = function(e) print("data error") )

tryCatch(
Germany[ i  = ,
         j  = ResidualLoad := TotalLoad - RenewableGen ],
error = function(e) print("data error") )

tryCatch(
write_fst( Germany, "/root/tr/data/Germany0929.fst" ),
error = function(e) print("data error") )





tryCatch(
  France    <- merge( x   = genRT[[ 2 ]],
                      y   = loadRT[[ 2 ]],
                      by  = c( "DateTime", "BiddingZone", "Date", "Year", "Month", "Hour" ),
                      all = TRUE ),
  error = function(e) print("data error") )

tryCatch(
  renewGen   <- France[ i  = AggregateType %in% list( "Solar" ,"Wind", "Other renewables" ),
                        j  = .( RenewableGen = sum( GenerationValue ) ),
                        by = c( "DateTime" ) ],
  error = function(e) print("data error") )

tryCatch(
  France    <- merge( x   = France,
                      y   = renewGen,
                      by  = "DateTime",
                      all = TRUE ),
  error = function(e) print("data error") )

tryCatch(
  France[ i  = ,
          j  = ResidualLoad := TotalLoad - RenewableGen ],
  error = function(e) print("data error") )

tryCatch(
  write_fst( France, "/root/tr/data/France.fst" ),
  error = function(e) print("data error") )









tryCatch(
genDAGer   <- genDA[[ 1 ]],
error = function(e) print("data error") )
tryCatch(
write_fst( genDAGer, "/root/tr/data/genDAGer.fst" ),
error = function(e) print("data error") )
# genDAGer   <- read_fst("data/genDAGer.fst", as.data.table = TRUE )

tryCatch(
genDAWSGer <- genDAWS[[ 1 ]],
error = function(e) print("data error") )

tryCatch(
write_fst( genDAWSGer, "/root/tr/data/genDAWSGer.fst" ),
error = function(e) print("data error") )
# genDAWSGer <- read_fst("data/genDAWSGer.fst", as.data.table = TRUE )

tryCatch(
loadDAGer  <- loadDA[[ 1 ]],
error = function(e) print("data error") )

tryCatch(
write_fst( loadDAGer, "/root/tr/data/loadDAGer.fst" ),
error = function(e) print("data error") )
# loadDAGer  <- read_fst("data/loadDAGer.fst", as.data.table = TRUE )

tryCatch(
loadWAGer  <- loadWA[[ 1 ]],
error = function(e) print("data error") )

tryCatch(
write_fst( loadWAGer, "/root/tr/data/loadWAGer.fst" ),
error = function(e) print("data error") )
# loadWAGer  <- read_fst("data/loadWAGer.fst", as.data.table = TRUE )






tryCatch(
  genDAFra   <- genDA[[ 2 ]],
  error = function(e) print("data error") )
tryCatch(
  write_fst( genDAFra, "/root/tr/data/genDAFra.fst" ),
  error = function(e) print("data error") )

tryCatch(
  genDAWSFra <- genDAWS[[ 2 ]],
  error = function(e) print("data error") )

tryCatch(
  write_fst( genDAWSFra, "/root/tr/data/genDAWSFra.fst" ),
  error = function(e) print("data error") )
# genDAWSGer <- read_fst("data/genDAWSGer.fst", as.data.table = TRUE )

tryCatch(
  loadDAFra  <- loadDA[[ 2 ]],
  error = function(e) print("data error") )

tryCatch(
  write_fst( loadDAFra, "/root/tr/data/loadDAFra.fst" ),
  error = function(e) print("data error") )


tryCatch(
  loadWAFra  <- loadWA[[ 2 ]],
  error = function(e) print("data error") )

tryCatch(
  write_fst( loadWAFra, "/root/tr/data/loadWAFra.fst" ),
  error = function(e) print("data error") )







tryCatch(
drive_upload( media     = "/root/tr/data/Germany0929.fst", 
              path      = "Germany0929.fst",
              overwrite = TRUE ),
error = function(e) print("data error") )

tryCatch(
drive_upload( media     = "/root/tr/data/genDAGer.fst", 
              path      = "genDAGer.fst",
              overwrite = TRUE ),
error = function(e) print("data error") )

tryCatch(
drive_upload( media     = "/root/tr/data/genDAWSGer.fst", 
              path      = "genDAWSGer.fst",
              overwrite = TRUE ),
error = function(e) print("data error") )

tryCatch(
drive_upload( media     = "/root/tr/data/loadDAGer.fst", 
              path      = "loadDAGer.fst",
              overwrite = TRUE ),
error = function(e) print("data error") )

tryCatch(
drive_upload( media     = "/root/tr/data/loadWAGer.fst", 
              path      = "loadWAGer.fst",
              overwrite = TRUE ),
error = function(e) print("data error") )





tryCatch(
  drive_upload( media     = "/root/tr/data/France.fst", 
                path      = "France.fst",
                overwrite = TRUE ),
  error = function(e) print("data error") )

tryCatch(
  drive_upload( media     = "/root/tr/data/genDAFra.fst", 
                path      = "genDAFra.fst",
                overwrite = TRUE ),
  error = function(e) print("data error") )

tryCatch(
  drive_upload( media     = "/root/tr/data/genDAWSFra.fst", 
                path      = "genDAWSFra.fst",
                overwrite = TRUE ),
  error = function(e) print("data error") )

tryCatch(
  drive_upload( media     = "/root/tr/data/loadDAFra.fst", 
                path      = "loadDAFra.fst",
                overwrite = TRUE ),
  error = function(e) print("data error") )

tryCatch(
  drive_upload( media     = "/root/tr/data/loadWAFra.fst", 
                path      = "loadWAFra.fst",
                overwrite = TRUE ),
  error = function(e) print("data error") )







rm( list = ls() )
invisible( gc() )



