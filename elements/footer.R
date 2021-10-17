dashFooter <- argonDashFooter(
  
  copyrights = "Created by Tamas Olah in 2021",
  src        = NULL,
  
  argonFooterMenu(

    argonFooterItem( h6( p( "Last data refresh: ",
                            textOutput( "updateDate", inline = TRUE ) ) ) )
    )
  )
