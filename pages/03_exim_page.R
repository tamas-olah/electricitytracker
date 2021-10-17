exim_page <- argonTabItem(
  
  tabName = "Exim",
  
  argonRow(

    argonColumn(

      width = 12L,

      argonTabSet(

        id           = "tabExim",
        card_wrapper = FALSE,
        horizontal   = TRUE,
        circle       = FALSE,
        size         = "sm",
        width        = 12L,
        iconList     = lapply( X   = list( "network-wired", "exchange-alt" ),
                               FUN = icon ),

        argonTab(

          tabName = "Graph",
          active  = TRUE,

          argonRow(

            argonColumn(

              width = 12L,

              argonRow(

                argonCard(

                  width        = 12L,
                  src          = NULL,
                  icon         = icon( "exchange-alt" ),
                  status       = "default",
                  shadow       = TRUE,
                  border_level = 2L,
                  hover_shadow = TRUE,
                  title        = NULL,

                  echarts4rOutput("graph", height = "550px"),

                  br(),

                  argonButton( name         = "Click me",
                               status       = "danger",
                               icon         = icon("bell"),
                               size         = "sm",
                               toggle_modal = TRUE,
                               modal_id     = "modalGraph" ),

                  argonModal( id       = "modalGraph",
                              title    = "What is this?",
                              status   = "default",
                              gradient = TRUE,
                              "" )
                  )
                )
              )
            )
          ),

        argonTab(

          tabName = "Sankey",
          active  = FALSE,

          argonRow(

            argonColumn(

              width = 12L,

              argonRow(

                argonCard(

                  title  = NULL,
                  width  = 12L,
                  icon   = NULL,
                  shadow = TRUE,

                  argonRow(

                    argonColumn(

                      width = 6L,

                      echarts4rOutput("import", height = "550px"),

                      br(),

                      argonButton( name         = "Click me",
                                   status       = "danger",
                                   icon         = icon("bell"),
                                   size         = "sm",
                                   toggle_modal = TRUE,
                                   modal_id     = "modalSankey" ),

                      argonModal( id       = "modalSankey",
                                  title    = "What is this?",
                                  status   = "default",
                                  gradient = TRUE,
                                  "" )
                      ),

                    argonColumn(

                      width = 6L,

                      echarts4rOutput("export", height = "550px")
                      )
                    )
                  )
                )
              )
            )
          )
        )
      )
    )
  )
