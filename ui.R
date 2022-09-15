# Use a fluid Bootstrap layout
fluidPage(    
  
  titlePanel("Cropping and Rotating Images"),
  
  sidebarLayout(      
    
    sidebarPanel(
      h5("Original image width:"),
      textOutput("width"),
      h5("Original image height:"),
      textOutput("height"),
      h5("Scaled image width:"),
      textOutput("scaled_width"),
      h5("Scaled image height:"),
      textOutput("scaled_height"),
      br(),
      hr(),
      actionButton("crop", "Crop")
    ),

    mainPanel(
      imageOutput("image", brush = brushOpts(id = "crop_brush", resetOnNew = TRUE))
    )
  )
)