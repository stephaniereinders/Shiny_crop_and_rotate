library(magick)

# Define a server for the Shiny app
function(input, output) {
  
  # READ: image
  image <- magick::image_read("sample_writing.png")
  
  # RENDER: image
  output$image <- renderImage({
    tmpfile <- image %>%
      magick::image_write(tempfile(fileext='png'), format = 'png')
    
    # Return a list
    list(src = tmpfile, contentType = "image/png")
  }, deleteFile = FALSE)
}