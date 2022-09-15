# Use a fluid Bootstrap layout
fluidPage(    
  
  titlePanel("Cropping and Rotating Images"),
  
  sidebarLayout(      
    
    sidebarPanel(
      h5("Original image width:"),
      textOutput("width"),
      h5("Original image height:"),
      textOutput("height")
    ),

    mainPanel(
      imageOutput("image")
    )
  )
)