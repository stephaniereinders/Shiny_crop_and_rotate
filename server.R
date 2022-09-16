library(magick)

# Define a server for the Shiny app
function(input, output, session) {
  
  # READ: image
  image <- reactiveValues()
  image$current <- magick::image_read("sample_writing.png")
  
  # OBSERVE: image info
  observe({
    # Original image dimensions
    image$orig_width <- image_info(image$current)$width
    image$orig_height <- image_info(image$current)$height
  })
  
  # RENDER: image
  output$image <- renderImage({
    
    # rotate
    tmp <- image$current %>%
      magick::image_rotate(degrees = input$rotate)
    
    # find widths of full-size rotated image
    image$rotated_width <- image_info(tmp)$width
    
    # write to temp file
    tmpfile <- tmp %>%
      magick::image_write(tempfile(fileext='png'), format = 'png')
      
    # return a list
    list(src = tmpfile, contentType = "image/png")
  }, deleteFile = FALSE)
  
  # RENDER: image info
  output$orig_width <- renderText({image$orig_width})
  output$orig_height <- renderText({image$orig_height})
  output$rotated_width <- renderText({image$rotated_width})
  output$rotated_height <- renderText({image$rotated_height})

  # BUTTON: crop
  observeEvent(input$crop, {
    
    xmin = input$crop_brush$xmin
    xmax = input$crop_brush$xmax
    ymin = input$crop_brush$ymin
    ymax = input$crop_brush$ymax
    
    xrange = xmax - xmin
    yrange = ymax - ymin
      
    image$current <- image_crop(image$current, paste(xrange,'x', yrange, '+', xmin, '+', ymin))
  })
  
}