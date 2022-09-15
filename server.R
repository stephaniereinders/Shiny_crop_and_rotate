library(magick)

# Define a server for the Shiny app
function(input, output, session) {
  
  # READ: image
  image <- reactiveValues()
  image$current <- magick::image_read("sample_writing.png")

  # RENDER: image
  output$image <- renderImage({
    
    session_width = session$clientData$output_image_width
    
    tmpfile <- image$current %>%
      magick::image_resize(geometry_size_pixels(width=session_width)) %>%
      magick::image_write(tempfile(fileext='png'), format = 'png')
    
    # Return a list
    list(src = tmpfile, contentType = "image/png", width=session_width)
  }, deleteFile = FALSE)
}