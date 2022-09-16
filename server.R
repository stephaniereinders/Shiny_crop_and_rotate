library(magick)

# Define a server for the Shiny app
function(input, output, session) {
  
  # READ: image
  image <- reactiveValues()
  current_image <- magick::image_read("sample_writing.png")
  image$current <- current_image
  image$crop_list <- list(current_image)
  
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
    image$current_width <- image_info(tmp)$width
    image$current_height <- image_info(tmp)$height
    
    # write to temp file
    tmpfile <- tmp %>%
      magick::image_write(tempfile(fileext='png'), format = 'png')
      
    # return a list
    list(src = tmpfile, contentType = "image/png")
  }, deleteFile = FALSE)
  
  # RENDER: image info
  output$orig_width <- renderText({image$orig_width})
  output$orig_height <- renderText({image$orig_height})
  output$current_width <- renderText({image$current_width})
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
    image$crop_list <- append(image$crop_list, image$current)
  })
  
  # BUTTON: undo crop
  observeEvent(input$undo_crop, {
    image$current <- tail(image$crop_list, 2)[[1]]
    image$crop_list <- head(image$crop_list, -1)
  })
  
}