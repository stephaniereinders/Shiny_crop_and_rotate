# Use a fluid Bootstrap layout
fluidPage(    
  
  titlePanel("Cropping and Rotating Images"),
  
  sidebarLayout(      
    
    sidebarPanel(
      h5("Starting image width:"),
      textOutput("starting_width", inline = TRUE),
      h5("Starting image height:"),
      textOutput("starting_height"),
      h5("Display image width:"),
      textOutput("display_width"),
      h5("Display image height:"),
      textOutput("display_height"),
      br(),
      hr(),
      actionButton("crop", "Crop"),
      br(),
      hr(),
      numericInput("rotate", "Rotate", value=0, min=-90, max=90, step=1),
      hr(),
      actionButton("undo", "Undo"),
    ),

    mainPanel(
      imageOutput("image", brush = brushOpts(id = "crop_brush", resetOnNew = TRUE)),
      verbatimTextOutput("crop_brush_info")
    )
  )
)