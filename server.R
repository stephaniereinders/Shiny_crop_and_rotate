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
  image$display_cropped <- FALSE
  
  # OBSERVE: crop guides
  observeEvent(input$crop_brush, {
    # turn on crop button if the display image hasn't already been cropped
    if (!image$display_cropped){
      shinyjs::enable("crop")
    }
  })
  
  # BUTTON: rotate
  observeEvent(input$rotate, {
    # rotate
    # note: rotating a rotated image does not reset the image size so rotate the starting image
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
    
    # calculate scaling factor
    s <- image$display_width / image$window_width

    xmin = s*input$crop_brush$xmin
    xmax = s*input$crop_brush$xmax
    ymin = s*input$crop_brush$ymin
    ymax = s*input$crop_brush$ymax
    
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
    
    # turn off crop button
    shinyjs::disable("crop")
    
    # keep crop button from turning on if user selects area of image
    image$display_cropped <- TRUE  
  })
  
  # BUTTON: reset
  observeEvent(input$reset, {
    # reset to starting image
    image$display <- image$starting
    image$display_width <- image$starting_width
    image$display_height <- image$starting_height
    image$display_cropped <- FALSE
    
    # reset rotation to 0 degrees
    updateTextInput(session, "rotate", value=0)
    
    # turn off crop and reset buttons
    shinyjs::disable("crop")
    shinyjs::disable("reset")
  })
  
  # RENDER: image
  output$image <- renderImage({
    # find width of main window
    image$window_width <- session$clientData$output_image_width
    
    # write to temp file
    tmpfile <- image$display %>%
      magick::image_resize(geometry_size_pixels(width = image$window_width)) %>%
      magick::image_write(tempfile(fileext='png'), format = 'png')
    
    # return a list
    list(src = tmpfile, contentType = "image/png", width = image$window_width)
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