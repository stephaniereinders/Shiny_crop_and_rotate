library(magick)

# Define a server for the Shiny app
function(input, output, session) {
  
  # READ: image
  image <- reactiveValues()
  image$current <- magick::image_read("sample_writing.png")
  
  # OBSERVE: image info
  observe({
    image$info <- image_info(image$current)
    
    # Original image dimensions
    image$width <- image$info$width
    image$height <- image$info$height
    
    # Scaled image width - scale image to fit in window width-wise
    image$scaled_width <- session$clientData$output_image_width
    
    # Calculate scale factor (width * scale_factor = scaled_width)
    image$scale_factor <- image$scaled_width / image$width
    })
  
  # RENDER: image
  output$image <- renderImage({
    
    # resize to fit window width-wise. maintain aspect ratio
    tmp <- image$current %>%
      magick::image_resize(geometry_size_pixels(width=image$scaled_width)) 
    
    # write to temp file
    tmpfile <- tmp %>%
      magick::image_write(tempfile(fileext='png'), format = 'png')
    
    # store scaled height value
    image$scaled_height <- image_info(tmp)$height
    
    # Return a list
    list(src = tmpfile, contentType = "image/png", width=image$scaled_width)
  }, deleteFile = FALSE)
  
  # RENDER: image info
  output$width <- renderText({image$width})
  output$height <- renderText({image$height})
  output$scaled_width <- renderText({image$scaled_width})
  output$scaled_height <- renderText({image$scaled_height})
  output$scale_factor <- renderText({image$scale_factor})
  
  # BUTTON: crop
  observeEvent(input$crop, {
    
    # Convert crop_brush coordinates back to original dimensions
    # (Proof. width * scale_factor = scaled_width => scaled_width / scale_factor = width.)
    xmin = input$crop_brush$xmin / image$scale_factor
    xmax = input$crop_brush$xmax / image$scale_factor
    ymin = input$crop_brush$ymin / image$scale_factor
    ymax = input$crop_brush$ymax / image$scale_factor
    
    xrange = xmax - xmin
    yrange = ymax - ymin
      
    image$current <- image_crop(image$current, paste(xrange,'x', yrange, '+', xmin, '+', ymin))
  })
  
}