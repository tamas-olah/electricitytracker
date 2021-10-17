library(echarts4r)
library(data.table)
library(scales)
library(fst)
library(magrittr)

flows <- fread( cmd       = sprintf( "grep --text 'CTY' %s",
                                    paste( list.files( path = "~/Desktop/dir",
                                                       full.names = TRUE ),
                                           collapse = " " ) ),
               drop      = c( 2:4, 6:8, 10, 12 ),
               col.names = c( "DateTime",   "OutAreaName", "InAreaName", "FlowValue" ) )

flows <- flows[ i  = ,
                j  = .( Value = round( abs( sum( FlowValue ) ) ) ),
                by = c( "OutAreaName", "InAreaName" ) ]

codes <- read.csv("data_static/code.csv") %>% setDT()

flows <- merge( x     = flows,
                 y     = codes[, .(code, name)],
                 by.x  = "OutAreaName",
                 by.y  = "code",
                 all.x = TRUE )

setnames( x   = flows,
          old = "name",
          new = "name.out" )

flows <- merge( x     = flows,
                 y     = codes[, .(code, name)],
                 by.x  = "InAreaName",
                 by.y  = "code",
                 all.x = TRUE )

setnames( x   = flows,
          old = "name",
          new = "name.in" )

flows[ , InAreaName := NULL][ , OutAreaName := NULL]

write_fst(flows, "data_static/flows.fst")
flows <- read_fst("data_static/flows.fst", as.data.table = TRUE)

flows$Value <- rescale( flows$Value, to = c( 1L, 10L ) )
colnames(flows) <- c( "weight", "from", "to" )
edges <- flows




nodes <- data.frame( name = levels( as.factor( flows$from ) ) )

nodes <- lapply( X   = levels(as.factor(nodes$name)),
                   FUN = function( x ) {
                     selcols <- c("from", "to", "weight")
                     valami  <- flows[ flows[ ,
                                              Reduce( `|`, lapply(.SD, `==`, x ) ),
                                              .SDcols = selcols ],
                                       ..selcols ]
                     sums    <- data.frame( name  = x,
                                            value = valami[,
                                                           .( value = sum( weight ) ) ] )
                     return( sums )
                   } ) %>%
  rbindlist()


nodes$weight <- nodes$value

nodes <- merge( x     = nodes,
                y     = codes[ , .( name, region ) ],
                by    = "name",
                all.x = TRUE )

colnames(nodes) <- c("name", "value", "size", "grp" )

net <- list( nodes = nodes, edges = edges )

saveRDS(net, file = "data_static/net.rds")

rm( list = ls() )
invisible( gc() )

  

