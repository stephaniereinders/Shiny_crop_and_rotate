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
    image$scaled_width = session$clientData$output_image_width
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
  
  # RENDER: image dimensions
  output$width <- renderText({image$width})
  output$height <- renderText({image$height})
  output$scaled_width <- renderText({image$scaled_width})
  output$scaled_height <- renderText({image$scaled_height})
  
}