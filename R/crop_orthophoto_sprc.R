crop_orthophoto_sprc <- function(sprc, buffer) {
  cropped_collection <- terra::crop(sprc, buffer, snap = "in", mask = TRUE)

  return(cropped_collection)
}