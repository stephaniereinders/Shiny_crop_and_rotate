# Use a fluid Bootstrap layout
fluidPage(    
  
  titlePanel("Cropping and Rotating Images"),
  
  sidebarLayout(      
    
    sidebarPanel(
      h5("Original image width:"),
      textOutput("orig_width"),
      h5("Original image height:"),
      textOutput("orig_height"),
      h5("Rotated image width:"),
      textOutput("rotated_width"),
      h5("Rotated image height:"),
      textOutput("rotated_height"),
      br(),
      hr(),
      actionButton("crop", "Crop"),
      br(),
      hr(),
      numericInput("rotate", "Rotate", value=0, min=-90, max=90, step=1)
    ),

    mainPanel(
      imageOutput("image", brush = brushOpts(id = "crop_brush", resetOnNew = TRUE))
    )
  )
)