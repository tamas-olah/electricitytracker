library(SFTP)
library(data.table)
library(echarts4r)
library(magrittr)
library(stringr)
library(jsonlite)
library(fst)
data <- import_file("/home/analyst/Dropbox/ENTSO-E/Germany/PhysicalFlows.fst")

data$InAreaName <- str_replace_all(data$InAreaName, c( "DE CTY" = "Germany",
                                                   "AT CTY" = "Austria",
                                                   "FR CTY" = "France",
                                                   "NL CTY" = "Netherlands",
                                                   "CH CTY" = "Switzerland",
                                                   "DK CTY" = "Denmark",
                                                   "CZ CTY" = "Czechia",
                                                   "SE CTY" = "Sweded",
                                                   "NO CTY" = "Norway",
                                                   "BE CTY" = "Belgium",
                                                   "LU CTY" = "Luxembourg",
                                                   "PL CTY" = "Poland" ) )

data$OutAreaName <- str_replace_all(data$OutAreaName, c( "DE CTY" = "Germany",
                                                       "AT CTY" = "Austria",
                                                       "FR CTY" = "France",
                                                       "NL CTY" = "Netherlands",
                                                       "CH CTY" = "Switzerland",
                                                       "DK CTY" = "Denmark",
                                                       "CZ CTY" = "Czechia",
                                                       "SE CTY" = "Sweded",
                                                       "NO CTY" = "Norway",
                                                       "BE CTY" = "Belgium",
                                                       "LU CTY" = "Luxembourg",
                                                       "PL CTY" = "Poland" ) )


data <- data[DateTime %between% c( "2020-01-01", "2021-12-31") ]


write_fst(data, "data_static/eximp.fst")

import <- data[ i  = InAreaName == "Germany", # react
                j  = .( Value = abs( sum( FlowValue ) ) ),
                by = c( "OutAreaName", "InAreaName" )]

import %>% 
  e_charts() %>% 
  e_sankey(OutAreaName, InAreaName, Value)


export <- data[ i  = OutAreaName == "Germany" & # react
                  DateTime %between% c( "2020-01-01", "2021-12-31"), # react
                j  = .( Value = abs( sum( FlowValue ) ) ),
                by = c( "OutAreaName", "InAreaName" )]



export %>% 
  e_charts() %>% 
  e_sankey(OutAreaName, InAreaName, Value)
