library(magick)

# Define a server for the Shiny app
function(input, output, session) {
  
  # READ: image
  image <- reactiveValues()
  sample_image <- magick::image_read("samplewriting.png")
  image$current <- sample_image
  image$history <- list(sample_image)
  image$orig_width <- image_info(sample_image)$width
  image$orig_height <- image_info(sample_image)$height
  
  # BUTTON: rotate
  observeEvent(input$rotate, {
    
    # rotate
    image$current <- image$current %>%
      magick::image_rotate(degrees = input$rotate)
    
    # find dimensions of rotated image
    image$current_width <- image_info(image$current)$width
    image$current_height <- image_info(image$current)$height
    
    # add to image history
    image$history <- append(image$history, image$current)
  })
  
  # RENDER: image
  output$image <- renderImage({
    
    # write to temp file
    tmpfile <- image$current %>%
      magick::image_write(tempfile(fileext='png'), format = 'png')
      
    # return a list
    list(src = tmpfile, contentType = "image/png")
  }, deleteFile = FALSE)

  # BUTTON: crop
  observeEvent(input$crop, {
    
    xmin = input$crop_brush$xmin
    xmax = input$crop_brush$xmax
    ymin = input$crop_brush$ymin
    ymax = input$crop_brush$ymax
    
    xrange = (xmax - xmin)
    yrange = (ymax - ymin)
      
    # crop
    image$current <- image$current %>% 
      image_crop(geometry_area(width=xrange, height=yrange, x_off=xmin, y_off=ymin))
    image$history <- append(image$history, image$current)
  })
  
  # BUTTON: undo crop
  observeEvent(input$undo, {
    image$current <- tail(image$history, 2)[[1]]
    image$history <- head(image$history, -1)
  })
  
  # RENDER: image info
  output$orig_width <- renderText({image$orig_width})
  output$orig_height <- renderText({image$orig_height})
  output$current_width <- renderText({image$current_width})
  output$current_height <- renderText({image$current_height})
  
  # RENDER: crop brush info
  output$crop_brush_info <- renderPrint({
    cat("input$crop_brush:\n")
    str(input$crop_brush)
  })
  
}