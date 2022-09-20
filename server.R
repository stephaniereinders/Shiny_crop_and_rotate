library(magick)
library(shinyjs)

# Define a server for the Shiny app
function(input, output, session) {
  # turn off crop and rest buttons
  shinyjs::disable("crop")
  shinyjs::disable("reset")
  
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
  
  # OBSERVE: crop guides
  observeEvent(input$crop_brush, {
    # turn on crop button
    shinyjs::enable("crop")
  })
  
  # BUTTON: rotate
  observeEvent(input$rotate, {
    # rotate
    # rotating a rotated image does not reset the image size so rotate the starting image
    image$display <- image$starting %>%  
      magick::image_rotate(degrees = input$rotate)
    
    # update
    image$display_width <- image_info(image$display)$width
    image$display_height <- image_info(image$display)$height
    
    # rotating will undo cropping so turn off crop button
    shinyjs::disable("crop")
    
    # turn on reset button
    if (input$rotate != 0){
      shinyjs::enable("reset")
    }
  })

  # BUTTON: crop
  observeEvent(input$crop, {
    
    # calculate offsets for rotated image
    if (input$rotate != 0){
      x_off = (image$display_width - image$starting_width)/2
      y_off = (image$display_height - image$starting_height)/2
    } else {
      x_off = y_off = 0
    }

    xmin = input$crop_brush$xmin
    xmax = input$crop_brush$xmax
    ymin = input$crop_brush$ymin
    ymax = input$crop_brush$ymax
    
    xrange = (xmax - xmin)
    yrange = (ymax - ymin)
      
    # crop
    image$display <- image$display %>% 
      image_crop(geometry_area(width=xrange, height=yrange, x_off=xmin-x_off, y_off=ymin-y_off))
    
    # update
    image$display_width <- image_info(image$display)$width
    image$display_height <- image_info(image$display)$height
    
    # turn on reset button
    shinyjs::enable("reset")
  })
  
  # BUTTON: reset
  observeEvent(input$reset, {
    # reset to starting image
    image$display <- image$starting
    
    # reset rotation to 0 degrees
    updateTextInput(session, "rotate", value=0)
    image$display_rotation <- 0
    
    # reset display dimensions
    image$display_width <- image$starting_width
    image$display_height <- image$starting_height
    
    # turn off crop and reset buttons
    shinyjs::disable("crop")
    shinyjs::disable("reset")
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