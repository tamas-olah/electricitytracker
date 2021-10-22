dashFooter <- blueDashFooter(
  
  copyrights = "Created by Tamas Olah in 2021",
  src        = NULL,
  
  blueFooterMenu(

    blueFooterItem( h6( p( "Last data refresh: ",
                            textOutput( "updateDate", inline = TRUE ) ) ) )
    )
  )
