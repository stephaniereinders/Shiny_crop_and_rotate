library(magick)

# Define a server for the Shiny app
function(input, output, session) {
  
  # READ: image
  image <- reactiveValues()
  current_image <- magick::image_read("sample_writing.png")
  image$current <- current_image
  image$crop_list <- list(current_image)
  image$orig_width <- image_info(current_image)$width
  image$orig_height <- image_info(current_image)$height
  
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
  output$current_height <- renderText({image$current_height})

  # BUTTON: crop
  observeEvent(input$crop, {
    
    # calculate rotation scale factor ()
    image$rot_scale_factor <- image$orig_width / image$current_width
    
    xmin = input$crop_brush$xmin
    xmax = input$crop_brush$xmax
    ymin = input$crop_brush$ymin
    ymax = input$crop_brush$ymax
    
    xrange = (xmax - xmin)/image$rot_scale_factor 
    yrange = (ymax - ymin)/image$rot_scale_factor 
      
    image$current <- image_crop(image$current, geometry_area(width=xrange, height=yrange, x_off=xmin, y_off=ymin))
    image$crop_list <- append(image$crop_list, image$current)
  })
  
  # BUTTON: undo crop
  observeEvent(input$undo_crop, {
    image$current <- tail(image$crop_list, 2)[[1]]
    image$crop_list <- head(image$crop_list, -1)
  })
  
}