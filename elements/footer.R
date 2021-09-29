dashFooter <- argonDashFooter(
  
  copyrights = "Created by Tamas Olah in 2021",
  src        = NULL,
  
  argonFooterMenu(
    
    argonFooterItem( h6( p( "Last refreshed on ", 
                            textOutput( "Refresh1", inline = TRUE ) ) ) )
    )
  )
