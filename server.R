library(magick)

# Define a server for the Shiny app
function(input, output, session) {
  
  # READ: image
  image <- reactiveValues()
  
  # starting image
  starting <- magick::image_read("samplewriting.png")
  image$starting <- starting
  image$starting_width <- image_info(starting)$width
  image$starting_height <- image_info(starting)$height
  
  # displayed image
  image$display <- starting
  image$display_width <- image_info(starting)$width
  image$display_heigth <- image_info(starting)$height
  
  # track image changes
  image$image_history <- list(starting)
  
  # BUTTON: rotate
  observeEvent(input$rotate, {
    
    # rotate
    image$display <- image$starting %>%
      magick::image_rotate(degrees = input$rotate)
    
    # find dimensions of rotated image
    image$display_width <- image_info(image$display)$width
    image$display_height <- image_info(image$display)$height
    
    # add to image history
    image$history <- append(image$history, image$display)
  })

  # BUTTON: crop
  observeEvent(input$crop, {
    
    x_off = (image$display_width - image$starting_width)/2
    y_off = (image$display_height - image$starting_height)/2
    
    xmin = input$crop_brush$xmin
    xmax = input$crop_brush$xmax
    ymin = input$crop_brush$ymin
    ymax = input$crop_brush$ymax
    
    xrange = (xmax - xmin)
    yrange = (ymax - ymin)
      
    # crop
    image$display <- image$display %>% 
      image_crop(geometry_area(width=xrange, height=yrange, x_off=xmin-x_off, y_off=ymin-y_off))
    image$history <- append(image$history, image$display)
  })
  
  # BUTTON: undo crop
  observeEvent(input$undo, {
    image$display <- image$starting
    updateTextInput(session, "rotate", value=0)
  })
  
  # RENDER: image
  output$image <- renderImage({
    
    # write to temp file
    tmpfile <- image$display %>%
      magick::image_write(tempfile(fileext='png'), format = 'png')
    
    # return a list
    list(src = tmpfile, contentType = "image/png")
  }, deleteFile = FALSE)
  
  # RENDER: image info
  output$starting_width <- renderText({image$starting_width})
  output$starting_height <- renderText({image$starting_height})
  output$display_width <- renderText({image$display_width})
  output$display_height <- renderText({image$display_height})
  
  # RENDER: crop brush info
  output$crop_brush_info <- renderPrint({
    cat("input$crop_brush:\n")
    str(input$crop_brush)
  })
  
}