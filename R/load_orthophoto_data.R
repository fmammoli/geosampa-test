load_orthofoto_data <- function(files) {
  if (files |> length() == 0) {
    return("Error: empty file list.")
  }
  
  if (files |> length() == 1) {
    print("Only one orthophoto file to load")
    spat_rast <- terra::rast(files)
    return(spat_rast)
  }
  print("Loading collection of files")
  sprc <- terra::sprc(files)
  return(sprc)
}
