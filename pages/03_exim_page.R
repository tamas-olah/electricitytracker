exim_page <- blueTabItem(
  
  tabName = "Exim",
  
  blueRow(

    blueColumn(

      width = 12L,

      blueTabSet(

        id           = "tabExim",
        card_wrapper = FALSE,
        horizontal   = TRUE,
        circle       = FALSE,
        size         = "sm",
        width        = 12L,
        iconList     = lapply( X   = list( "network-wired", "exchange-alt" ),
                               FUN = icon ),

        blueTab(

          tabName = "Graph",
          active  = TRUE,

          blueRow(

            blueColumn(

              width = 12L,

              blueRow(

                blueCard(

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

                  blueButton( name         = "Click me",
                               status       = "danger",
                               icon         = icon("bell"),
                               size         = "sm",
                               toggle_modal = TRUE,
                               modal_id     = "modalGraph" ),

                  blueModal( id       = "modalGraph",
                              title    = "What is this?",
                              status   = "default",
                              gradient = TRUE,
                              "" )
                  )
                )
              )
            )
          ),

        blueTab(

          tabName = "Sankey",
          active  = FALSE,

          blueRow(

            blueColumn(

              width = 12L,

              blueRow(

                blueCard(

                  title  = NULL,
                  width  = 12L,
                  icon   = NULL,
                  shadow = TRUE,

                  blueRow(

                    blueColumn(

                      width = 6L,

                      echarts4rOutput("import", height = "550px"),

                      br(),

                      blueButton( name         = "Click me",
                                   status       = "danger",
                                   icon         = icon("bell"),
                                   size         = "sm",
                                   toggle_modal = TRUE,
                                   modal_id     = "modalSankey" ),

                      blueModal( id       = "modalSankey",
                                  title    = "What is this?",
                                  status   = "default",
                                  gradient = TRUE,
                                  "" )
                      ),

                    blueColumn(

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
