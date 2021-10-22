map_page <- blueTabItem(

  tabName = "Map",
  
  blueRow(
    br(),
    "🚧 Under construction 🚧",
    br(), br(),
    
  # map_data %>%
  #   e_charts(lon) %>%
  #   e_leaflet()  %>%
  #   e_leaflet_tile() %>%
  #   e_scatter(lat, size = value, coord_system = "leaflet")
  

  
  leafletOutput("Explorer_Map", height = "600px")
    # Print the map
  
  # map_data %>%
  #   e_charts(lon) %>%
  #   e_mapbox( token = Sys.getenv("MAPBOX_TOK" ) ) %>%
  #   e_bar_3d(lat, value, coord_system = "mapbox") %>%
  #   e_visual_map(value)

) )
