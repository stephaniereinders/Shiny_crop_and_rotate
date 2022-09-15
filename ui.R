# Use a fluid Bootstrap layout
fluidPage(    
  
  titlePanel("Cropping and Rotating Images"),
  
  sidebarLayout(      
    
    sidebarPanel(
      
    ),

    mainPanel(
      imageOutput("image")
    )
  )
)