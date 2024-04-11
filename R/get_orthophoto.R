#' Get orthophoto from a buffer
#'
#' @param buffer An sf buffer object
#' @return A cropped and mosaicked orthophoto
#' @importFrom purrr map discard
#' @importFrom terra crop mosaic
get_orthophoto <- function(buffer) {
  intersecting_quadricles <- get_intersecting_quadricles(buffer)

  orthophoto <- intersecting_quadricles$qmdt_cod |> 
    download_orthophoto_data() |>
    unlist() |>
    purrr::map(function(item) grep(pattern = "\\.jp2$", item, value = TRUE)) |>
    purrr::discard(function(item) length(item) == 0) |>
    unlist() |>
    load_orthofoto_data()
  
  if (is(orthophoto, "SpatRasterCollection")) {
    crop <- terra::crop(x = orthophoto, y = buffer, snap = "in")
    mosaic <- terra::mosaic(crop)
    return(mosaic)
  }
  crop <- terra::crop(x = orthophoto, y = buffer, snap = "in", mask = TRUE)
  return(crop)
}